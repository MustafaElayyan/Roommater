import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final httpClient = http.Client();
  ref.onDispose(httpClient.close);

  return ApiClient(
    httpClient: httpClient,
    secureStorage: ref.watch(secureStorageProvider),
    config: ApiClientConfig(
      baseUrl: ApiClientConfig.defaultBaseUrlForCurrentPlatform(),
    ),
  );
});

class ApiClientConfig {
  const ApiClientConfig({
    this.baseUrl = androidEmulatorBaseUrl,
    this.jwtTokenKey = 'auth_jwt',
    this.timeout = const Duration(seconds: 30),
  });

  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:5073/api/';
  static const String localhostBaseUrl = 'http://localhost:5073/api/';
  // For physical devices, replace with your machine LAN IP (example below).
  static const String physicalDeviceBaseUrlExample =
      'http://192.168.1.100:5073/api/';

  static String defaultBaseUrlForCurrentPlatform() {
    if (kIsWeb) return localhostBaseUrl;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => androidEmulatorBaseUrl,
      _ => localhostBaseUrl,
    };
  }

  final String baseUrl;
  final String jwtTokenKey;
  final Duration timeout;
}

class ApiClient {
  ApiClient({
    required http.Client httpClient,
    required FlutterSecureStorage secureStorage,
    required ApiClientConfig config,
  })  : _httpClient = httpClient,
        _secureStorage = secureStorage,
        _config = config;

  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage;
  final ApiClientConfig _config;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final data = await _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
    if (data is Map<String, dynamic>) return data;
    throw const AppException('Unexpected API response format.');
  }

  Future<List<dynamic>> getJsonList(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final data = await _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
    if (data is List<dynamic>) return data;
    throw const AppException('Unexpected API response format.');
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final data = await _request(
      method: 'POST',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
    if (data is Map<String, dynamic>) return data;
    throw const AppException('Unexpected API response format.');
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final data = await _request(
      method: 'PUT',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
    if (data is Map<String, dynamic>) return data;
    throw const AppException('Unexpected API response format.');
  }

  Future<void> delete(
    String path, {
    bool requiresAuth = true,
  }) async {
    await _request(
      method: 'DELETE',
      path: path,
      requiresAuth: requiresAuth,
    );
  }

  Future<void> writeToken(String token) {
    return _secureStorage.write(key: _config.jwtTokenKey, value: token);
  }

  Future<void> clearToken() {
    return _secureStorage.delete(key: _config.jwtTokenKey);
  }

  Future<dynamic> _request({
    required String method,
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    required bool requiresAuth,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _buildHeaders(requiresAuth);

    final response = switch (method) {
      'GET' => await _httpClient
          .get(uri, headers: headers)
          .timeout(_config.timeout),
      'POST' => await _httpClient
          .post(uri, headers: headers, body: jsonEncode(body ?? const {}))
          .timeout(_config.timeout),
      'PUT' => await _httpClient
          .put(uri, headers: headers, body: jsonEncode(body ?? const {}))
          .timeout(_config.timeout),
      'DELETE' => await _httpClient
          .delete(uri, headers: headers)
          .timeout(_config.timeout),
      _ => throw AppException('Unsupported method: $method'),
    };

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty || response.statusCode == 204) return null;
      return jsonDecode(response.body);
    }

    throw AppException(_extractErrorMessage(response));
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final resolvedUri = Uri.parse(_config.baseUrl).resolve(path);
    if (queryParameters == null || queryParameters.isEmpty) return resolvedUri;
    final params = queryParameters.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return resolvedUri.replace(queryParameters: params);
  }

  Future<Map<String, String>> _buildHeaders(bool requiresAuth) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (!requiresAuth) return headers;

    final token = await _secureStorage.read(key: _config.jwtTokenKey);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ??
            decoded['error'] ??
            decoded['title'] ??
            decoded['detail'];
        if (message is String && message.isNotEmpty) return message;
      }
    } catch (_) {
      // Ignore parsing errors and fallback to status message.
    }

    return 'Request failed (${response.statusCode}).';
  }
}
