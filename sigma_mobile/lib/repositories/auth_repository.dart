import 'package:dio/dio.dart';

import '../engines/api_client.dart';
import '../engines/token_storage.dart';

/// Erreur d'authentification présentable à l'utilisateur.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthRepository {
  final ApiClient _api;
  final TokenStorage _storage;

  AuthRepository(this._api, this._storage);

  TokenStorage get storage => _storage;

  Future<void> login(String email, String password) async {
    try {
      final res = await _api.dio.post(
        '/login',
        data: {'username': email, 'password': password},
      );
      final token = res.data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw AuthException('Réponse inattendue du serveur.');
      }
      await _storage.saveToken(token);
      await _storage.saveEmail(email);
    } on DioException catch (e) {
      throw AuthException(_messageFromDio(e, defaut: 'Identifiants invalides.'));
    }
  }

  Future<void> register({
    required String nomComplet,
    required String email,
    required String password,
    String? telephone,
  }) async {
    try {
      await _api.dio.post(
        '/register',
        data: {
          'nom_complet': nomComplet,
          'email': email,
          'password': password,
          if (telephone != null && telephone.isNotEmpty) 'telephone': telephone,
        },
      );
    } on DioException catch (e) {
      throw AuthException(
        _messageFromDio(e, defaut: 'Inscription impossible. Réessayez.'),
      );
    }
  }

  Future<bool> hasToken() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> currentEmail() => _storage.getEmail();

  Future<void> logout() => _storage.clear();

  String _messageFromDio(DioException e, {required String defaut}) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (e.response?.statusCode == 401) {
      return 'Identifiants invalides ou compte désactivé.';
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Serveur injoignable. Vérifiez votre connexion.';
    }
    return defaut;
  }
}
