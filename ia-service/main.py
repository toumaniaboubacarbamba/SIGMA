"""
SIGMA — Microservice IA de classification des dossiers administratifs.

Service FastAPI exposant un endpoint POST /classify qui prend la description
textuelle d'un dossier, interroge l'API Mistral, et renvoie la catégorie
prédite parmi une liste fermée de 8 catégories, accompagnée d'un score de
confiance.

Appelé en serveur-à-serveur par le backend Symfony (via symfony/http-client),
jamais directement par le navigateur ou l'app mobile.
"""

from __future__ import annotations

import json
import logging
import os
from enum import Enum
from pathlib import Path

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

# --------------------------------------------------------------------------- #
# Configuration & chargement de l'environnement
# --------------------------------------------------------------------------- #

# La clé Mistral vit dans le .env à la RACINE du projet (un cran au-dessus de
# ia-service/). On le charge en premier, puis un éventuel .env local au service
# vient surcharger (pratique pour le dev / les tests).
_SERVICE_DIR = Path(__file__).resolve().parent
_ROOT_ENV = _SERVICE_DIR.parent / ".env"
load_dotenv(_ROOT_ENV)
load_dotenv(_SERVICE_DIR / ".env", override=True)

MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY", "").strip()
MISTRAL_MODEL = os.getenv("MISTRAL_MODEL", "mistral-small-latest").strip()
MISTRAL_API_URL = os.getenv(
    "MISTRAL_API_URL", "https://api.mistral.ai/v1/chat/completions"
).strip()
# Timeout réseau (secondes) pour l'appel à Mistral.
MISTRAL_TIMEOUT = float(os.getenv("MISTRAL_TIMEOUT", "30"))

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("sigma-ia")


# --------------------------------------------------------------------------- #
# Catégories métier (liste fermée)
# --------------------------------------------------------------------------- #

class Categorie(str, Enum):
    PENSION = "PENSION"
    RECRUTEMENT = "RECRUTEMENT"
    ETAT_CIVIL = "ETAT_CIVIL"
    MARCHE_PUBLIC = "MARCHE_PUBLIC"
    PERMIS_CONSTRUIRE = "PERMIS_CONSTRUIRE"
    DIPLOME = "DIPLOME"
    CONCESSION_FONCIERE = "CONCESSION_FONCIERE"
    AUTRE = "AUTRE"


_CATEGORIES_LISTE = ", ".join(c.value for c in Categorie)


# --------------------------------------------------------------------------- #
# Schémas d'entrée / sortie (contrat d'API)
# --------------------------------------------------------------------------- #

class ClassifyRequest(BaseModel):
    description: str = Field(
        ...,
        min_length=1,
        description="Description textuelle du dossier à classifier.",
    )


class ClassifyResponse(BaseModel):
    categorie: Categorie = Field(..., description="Catégorie prédite.")
    score_confiance: float = Field(
        ...,
        ge=0.0,
        le=1.0,
        description="Confiance auto-estimée du modèle, entre 0 et 1.",
    )


# --------------------------------------------------------------------------- #
# Prompt système
# --------------------------------------------------------------------------- #

_SYSTEM_PROMPT = (
    "Tu es un classificateur de dossiers administratifs pour l'application "
    "SIGMA. À partir de la description d'un dossier, tu dois le classer dans "
    "EXACTEMENT une des catégories suivantes :\n"
    f"{_CATEGORIES_LISTE}.\n\n"
    "Règles :\n"
    "- Réponds UNIQUEMENT par un objet JSON valide, sans texte autour.\n"
    '- Format exact : {"categorie": "<CATEGORIE>", "score_confiance": <nombre>}\n'
    "- <CATEGORIE> doit être l'une des valeurs listées, en MAJUSCULES.\n"
    "- score_confiance est un nombre entre 0 et 1 reflétant ta certitude.\n"
    "- Si aucune catégorie ne correspond clairement, utilise AUTRE."
)


# --------------------------------------------------------------------------- #
# Appel à l'API Mistral
# --------------------------------------------------------------------------- #

async def _classifier_via_mistral(description: str) -> ClassifyResponse:
    """Interroge Mistral et renvoie une réponse validée.

    Lève HTTPException en cas de problème de configuration (500), d'erreur de
    l'API Mistral (502) ou de réponse inexploitable (502).
    """
    if not MISTRAL_API_KEY:
        # Erreur de configuration côté serveur, pas une faute du client.
        raise HTTPException(
            status_code=500,
            detail="MISTRAL_API_KEY absente. Vérifie le .env à la racine du projet.",
        )

    payload = {
        "model": MISTRAL_MODEL,
        "temperature": 0,  # déterminisme : on veut une classification stable
        "response_format": {"type": "json_object"},
        "messages": [
            {"role": "system", "content": _SYSTEM_PROMPT},
            {"role": "user", "content": description},
        ],
    }
    headers = {
        "Authorization": f"Bearer {MISTRAL_API_KEY}",
        "Content-Type": "application/json",
    }

    try:
        async with httpx.AsyncClient(timeout=MISTRAL_TIMEOUT) as client:
            resp = await client.post(MISTRAL_API_URL, json=payload, headers=headers)
    except httpx.RequestError as exc:
        logger.error("Échec réseau vers Mistral : %s", exc)
        raise HTTPException(status_code=502, detail="Service Mistral injoignable.")

    if resp.status_code != 200:
        logger.error("Mistral a répondu %s : %s", resp.status_code, resp.text)
        raise HTTPException(
            status_code=502,
            detail=f"Erreur de l'API Mistral (HTTP {resp.status_code}).",
        )

    # Extraction du contenu généré.
    try:
        contenu = resp.json()["choices"][0]["message"]["content"]
        donnees = json.loads(contenu)
    except (KeyError, IndexError, json.JSONDecodeError) as exc:
        logger.error("Réponse Mistral inexploitable : %s", exc)
        raise HTTPException(
            status_code=502, detail="Réponse de Mistral inexploitable."
        )

    return _normaliser_resultat(donnees)


def _normaliser_resultat(donnees: dict) -> ClassifyResponse:
    """Sécurise la sortie du modèle : catégorie valide + score borné.

    Le modèle peut renvoyer une catégorie hors liste ou un score aberrant ;
    on retombe alors sur des valeurs sûres plutôt que de propager l'erreur.
    """
    brute = str(donnees.get("categorie", "")).strip().upper()
    try:
        categorie = Categorie(brute)
    except ValueError:
        logger.warning("Catégorie hors liste reçue (%r) → AUTRE.", brute)
        categorie = Categorie.AUTRE

    try:
        score = float(donnees.get("score_confiance", 0.0))
    except (TypeError, ValueError):
        score = 0.0
    score = max(0.0, min(1.0, score))  # bornage strict [0, 1]

    return ClassifyResponse(categorie=categorie, score_confiance=score)


# --------------------------------------------------------------------------- #
# Application FastAPI
# --------------------------------------------------------------------------- #

app = FastAPI(
    title="SIGMA — Service IA de classification",
    description="Classe les dossiers administratifs via l'API Mistral.",
    version="1.0.0",
)


@app.get("/health")
def health() -> dict:
    """Sonde de disponibilité. Indique aussi si la clé Mistral est configurée."""
    return {
        "status": "ok",
        "model": MISTRAL_MODEL,
        "mistral_key_configured": bool(MISTRAL_API_KEY),
    }


@app.post("/classify", response_model=ClassifyResponse)
async def classify(requete: ClassifyRequest) -> ClassifyResponse:
    """Classe la description d'un dossier dans une des 8 catégories SIGMA."""
    return await _classifier_via_mistral(requete.description)
