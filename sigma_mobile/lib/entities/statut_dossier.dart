import 'package:flutter/material.dart';

/// Métadonnées d'affichage pour les statuts de dossier (alignées sur l'enum
/// backend StatutDossier et la charte Stitch).
class StatutInfo {
  final String label;
  final Color color; // couleur du texte / accent
  final Color background; // fond du badge

  const StatutInfo(this.label, this.color, this.background);
}

class DossierStatut {
  /// Chemin nominal du workflow (utilisé pour la timeline du détail).
  static const parcours = <String>[
    'SOUMIS',
    'EN_ANALYSE',
    'RECEVABLE',
    'SIGNATURE_DIR',
    'APPROUVE',
  ];

  static const Map<String, StatutInfo> _map = {
    'BROUILLON': StatutInfo('Brouillon', Color(0xFF5D5F5F), Color(0xFFE7E8E9)),
    'SOUMIS': StatutInfo('Soumis', Color(0xFF005323), Color(0xFFD3FFD5)),
    'EN_ANALYSE': StatutInfo('En analyse', Color(0xFF1D4ED8), Color(0xFFDBEAFE)),
    'INCOMPLET': StatutInfo('Incomplet', Color(0xFFB45309), Color(0xFFFEF3C7)),
    'RECEVABLE': StatutInfo('Recevable', Color(0xFFB45309), Color(0xFFFEF3C7)),
    'SIGNATURE_DIR': StatutInfo('Signature direction', Color(0xFF6D28D9), Color(0xFFEDE9FE)),
    'APPROUVE': StatutInfo('Approuvé', Color(0xFF00652C), Color(0xFFD3FFD5)),
    'REJETE': StatutInfo('Rejeté', Color(0xFFBA1A1A), Color(0xFFFFDAD6)),
  };

  static StatutInfo of(String statut) =>
      _map[statut] ?? const StatutInfo('Inconnu', Color(0xFF5D5F5F), Color(0xFFE7E8E9));

  /// Index du statut dans le parcours nominal, -1 si hors parcours.
  static int parcoursIndex(String statut) => parcours.indexOf(statut);
}

/// Métadonnées d'affichage pour les 8 catégories IA.
class CategorieInfo {
  final String label;
  final IconData icon;

  const CategorieInfo(this.label, this.icon);
}

class CategorieIa {
  static const Map<String, CategorieInfo> _map = {
    'PENSION': CategorieInfo('Pension', Icons.savings_outlined),
    'RECRUTEMENT': CategorieInfo('Recrutement', Icons.work_outline),
    'ETAT_CIVIL': CategorieInfo('État civil', Icons.badge_outlined),
    'MARCHE_PUBLIC': CategorieInfo('Marché public', Icons.gavel_outlined),
    'PERMIS_CONSTRUIRE': CategorieInfo('Permis de construire', Icons.home_work_outlined),
    'DIPLOME': CategorieInfo('Diplôme', Icons.school_outlined),
    'CONCESSION_FONCIERE': CategorieInfo('Concession foncière', Icons.terrain_outlined),
    'AUTRE': CategorieInfo('Autre', Icons.category_outlined),
  };

  static CategorieInfo of(String categorie) =>
      _map[categorie] ?? CategorieInfo(categorie, Icons.category_outlined);
}
