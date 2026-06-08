/// Dossier administratif tel qu'exposé par l'API (format application/json).
class Dossier {
  final int id;
  final String? numeroReference;
  final DateTime? dateDepot;
  final String statut;
  final String? description;
  final String? categorieIa;
  final double? scoreConfianceIa;

  const Dossier({
    required this.id,
    this.numeroReference,
    this.dateDepot,
    required this.statut,
    this.description,
    this.categorieIa,
    this.scoreConfianceIa,
  });

  /// La classification IA est-elle disponible ?
  bool get estClasse => categorieIa != null && categorieIa!.isNotEmpty;

  /// Score de confiance en pourcentage entier (ex: 0.98 -> 98).
  int get scorePourcent => ((scoreConfianceIa ?? 0) * 100).round();

  factory Dossier.fromJson(Map<String, dynamic> json) {
    return Dossier(
      id: json['id'] as int,
      numeroReference: json['numero_reference'] as String?,
      dateDepot: json['date_depot'] != null
          ? DateTime.tryParse(json['date_depot'] as String)
          : null,
      statut: json['statut'] as String? ?? 'BROUILLON',
      description: json['description'] as String?,
      categorieIa: json['categorieIa'] as String?,
      scoreConfianceIa: (json['scoreConfianceIa'] as num?)?.toDouble(),
    );
  }
}
