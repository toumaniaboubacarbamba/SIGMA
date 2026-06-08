import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage sécurisé du JWT (Keychain / Keystore / DPAPI selon la plateforme).
class TokenStorage {
  static const _tokenKey = 'sigma_jwt_token';
  static const _emailKey = 'sigma_user_email';

  final FlutterSecureStorage _storage;

  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveEmail(String email) =>
      _storage.write(key: _emailKey, value: email);

  Future<String?> getEmail() => _storage.read(key: _emailKey);

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
  }
}
