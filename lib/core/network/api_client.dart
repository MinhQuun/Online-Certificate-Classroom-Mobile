import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:cert_classroom_mobile/core/config/app_config.dart';
import 'package:cert_classroom_mobile/core/network/api_exceptions.dart';

typedef TokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({http.Client? httpClient, TokenProvider? tokenProvider})
    : _httpClient = httpClient ?? http.Client(),
      _tokenProvider = tokenProvider;

  final http.Client _httpClient;
  final TokenProvider? _tokenProvider;

  static TokenProvider? _globalTokenProvider;

  static void setGlobalTokenProvider(TokenProvider provider) {
    _globalTokenProvider = provider;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _request(
      method: 'POST',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _request(
      method: 'PUT',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _request(
      method: 'DELETE',
      path: path,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<dynamic> _request({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final requestHeaders = await _buildHeaders(headers);
    http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _httpClient.get(uri, headers: requestHeaders);
          break;
        case 'POST':
          response = await _httpClient.post(
            uri,
            headers: requestHeaders,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await _httpClient.put(
            uri,
            headers: requestHeaders,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await _httpClient.delete(uri, headers: requestHeaders);
          break;
        default:
          throw ApiException('HTTP method $method is not supported');
      }
    } on SocketException {
      throw NetworkException(
        'Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng.',
      );
    }

    return _handleResponse(response);
  }

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    Map<String, String?>? cleanedQuery;
    if (query != null) {
      cleanedQuery = query.map(
        (key, value) => MapEntry(key, value?.toString()),
      );
      cleanedQuery.removeWhere((_, value) => value == null);
    }

    Map<String, String>? finalQuery;
    if (cleanedQuery != null) {
      finalQuery = cleanedQuery.map((key, value) => MapEntry(key, value ?? ''));
    }

    return Uri.parse(
      '${AppConfig.baseUrl}$normalizedPath',
    ).replace(queryParameters: finalQuery);
  }

  Future<Map<String, String>> _buildHeaders(Map<String, String>? extra) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (extra != null) ...extra,
    };
    final token = await _loadToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String?> _loadToken() async {
    final provider = _tokenProvider ?? _globalTokenProvider;
    return provider?.call();
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final dynamic decoded =
        response.body.isEmpty ? null : jsonDecode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    final message = _extractMessage(decoded);
    if (statusCode == 401) {
      throw UnauthorizedException(message);
    }
    throw ApiException(message, statusCode: statusCode);
  }

  String _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      return decoded['message']?.toString() ??
          decoded['error']?.toString() ??
          'Yêu cầu thất bại, vui lòng thử lại.';
    }
    return 'Yêu cầu thất bại, vui lòng thử lại.';
  }
}
