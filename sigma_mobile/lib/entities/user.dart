/// Utilisateur citoyen (données minimales exposées par l'API).
class User {
  final int? id;
  final String email;
  final String? nomComplet;
  final String? telephone;
  final List<String> roles;

  const User({
    this.id,
    required this.email,
    this.nomComplet,
    this.telephone,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      email: json['email'] as String? ?? '',
      nomComplet: json['nom_complet'] as String? ?? json['nomComplet'] as String?,
      telephone: json['telephone'] as String?,
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}
