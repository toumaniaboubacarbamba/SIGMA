import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'token_storage.dart';

/// Configuration réseau centralisée.
///
/// - Bureau (Windows/macOS/Linux) ou iOS simulateur : `https://localhost:8000`
/// - Émulateur Android : remplacer par `https://10.0.2.2:8000`
/// - Web (Chrome) : lancer le serveur sans TLS (`symfony serve --no-tls`)
///   et utiliser `http://localhost:8000`
class ApiConfig {
  static const String host = 'https://localhost:8000';
  static const String baseUrl = '$host/api';
}

/// Client HTTP partagé : injecte le JWT et tolère le certificat auto-signé
/// du serveur de développement.
class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient(this.tokenStorage)
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient();
        // Dev uniquement : accepte le certificat auto-signé de `symfony serve`.
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }
}
