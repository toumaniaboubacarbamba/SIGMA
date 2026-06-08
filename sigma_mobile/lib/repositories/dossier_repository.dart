import '../engines/api_client.dart';
import '../entities/dossier.dart';

class DossierRepository {
  final ApiClient _api;

  DossierRepository(this._api);

  /// Liste des dossiers du citoyen connecté (filtrage côté serveur).
  Future<List<Dossier>> fetchAll() async {
    final res = await _api.dio.get('/dossiers');
    final data = res.data;
    final List items = data is List
        ? data
        : (data['hydra:member'] ?? data['member'] ?? <dynamic>[]) as List;
    return items
        .map((e) => Dossier.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Dossier> fetchOne(int id) async {
    final res = await _api.dio.get('/dossiers/$id');
    return Dossier.fromJson(res.data as Map<String, dynamic>);
  }

  /// Crée un dossier. Seule la description est envoyée : le propriétaire et le
  /// statut sont gérés côté serveur, et la classification IA est déclenchée
  /// automatiquement en arrière-plan.
  Future<Dossier> create({required String description}) async {
    final res = await _api.dio.post('/dossiers', data: {'description': description});
    return Dossier.fromJson(res.data as Map<String, dynamic>);
  }
}
