# SIGMA — Microservice IA de classification

Microservice **FastAPI** qui classe automatiquement les dossiers administratifs
de SIGMA dans l'une de 8 catégories, en s'appuyant sur l'**API Mistral**.

Il est conçu pour être appelé en **serveur-à-serveur** par le backend Symfony
(via `symfony/http-client`), et non directement par le navigateur ou l'app
mobile.

## Catégories prédites

`PENSION`, `RECRUTEMENT`, `ETAT_CIVIL`, `MARCHE_PUBLIC`, `PERMIS_CONSTRUIRE`,
`DIPLOME`, `CONCESSION_FONCIERE`, `AUTRE`.

## Architecture

```
Flutter ──> Symfony (API Platform) ──HTTP──> ia-service (FastAPI) ──> API Mistral
```

## Prérequis

- Python 3.10+
- Une clé API Mistral renseignée dans le `.env` **à la racine du projet**
  (`../.env`) sous la variable `MISTRAL_API_KEY`.

## Installation

```bash
cd ia-service
python -m venv .venv
# Windows (PowerShell) :
.venv\Scripts\Activate.ps1
# Linux / macOS :
# source .venv/bin/activate

pip install -r requirements.txt
```

## Lancement

```bash
uvicorn main:app --reload --port 8001
```

Le service écoute alors sur `http://127.0.0.1:8001`.
Documentation interactive (Swagger) : `http://127.0.0.1:8001/docs`.

## Endpoints

### `GET /health`
Sonde de disponibilité.

```json
{ "status": "ok", "model": "mistral-small-latest", "mistral_key_configured": true }
```

### `POST /classify`
Classe la description d'un dossier.

**Requête :**
```json
{ "description": "Demande de pension de retraite après 35 ans de service public" }
```

**Réponse :**
```json
{ "categorie": "PENSION", "score_confiance": 0.97 }
```

## Configuration (variables d'environnement)

| Variable           | Défaut                                        | Rôle                                      |
| ------------------ | --------------------------------------------- | ----------------------------------------- |
| `MISTRAL_API_KEY`  | *(lu depuis `../.env`)*                       | Clé API Mistral. **Obligatoire.**         |
| `MISTRAL_MODEL`    | `mistral-small-latest`                        | Modèle utilisé pour la classification.    |
| `MISTRAL_API_URL`  | `https://api.mistral.ai/v1/chat/completions`  | Endpoint de l'API Mistral.                |
| `MISTRAL_TIMEOUT`  | `30`                                          | Timeout réseau (secondes).                |

Voir `.env.example` pour surcharger ces valeurs localement.

## Test rapide (curl)

```bash
curl -X POST http://127.0.0.1:8001/classify \
  -H "Content-Type: application/json" \
  -d "{\"description\": \"Appel d'offres pour la construction d'une route\"}"
```

## Notes de conception

- **Sortie sécurisée** : si le modèle renvoie une catégorie hors liste, le
  service retombe sur `AUTRE` ; le score est borné dans `[0, 1]`.
- **Déterminisme** : `temperature = 0` pour une classification stable.
- **JSON forcé** : appel Mistral avec `response_format: json_object`.
- La clé Mistral n'est jamais committée (`.env` est dans `.gitignore`).
