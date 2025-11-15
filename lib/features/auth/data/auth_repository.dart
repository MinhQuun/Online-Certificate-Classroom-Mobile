import 'package:shared_preferences/shared_preferences.dart';

import 'package:cert_classroom_mobile/core/network/api_client.dart';
import 'package:cert_classroom_mobile/core/network/api_exceptions.dart';
import 'package:cert_classroom_mobile/features/auth/data/auth_api.dart';
import 'package:cert_classroom_mobile/features/auth/data/models/auth_user.dart';

class AuthRepository {
  AuthRepository({
    AuthApi? api,
    SharedPreferences? preferences,
  })  : _api = api ?? AuthApi(),
        _preferences = preferences {
    ApiClient.setGlobalTokenProvider(() => getToken());
  }

  static const String _tokenKey = 'auth_access_token';
  static const String _deviceName = 'flutter-mobile';

  final AuthApi _api;
  SharedPreferences? _preferences;
  String? _cachedToken;

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.login(
      email: email,
      password: password,
      deviceName: _deviceName,
    );

    final token = data['access_token']?.toString();
    if (token == null || token.isEmpty) {
      throw ApiException('Không nhận được access token từ máy chủ.');
    }
    await _persistToken(token);

    final userJson = _extractUserMap(data);
    return AuthUser.fromJson(userJson);
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } on UnauthorizedException {
      // Token is invalid/expired. Proceed with clearing local state.
    } finally {
      await clearToken();
    }
  }

  Future<AuthUser?> loadCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    final data = await _api.fetchProfile();
    final userJson = _extractUserMap(data);
    return AuthUser.fromJson(userJson);
  }

  Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }
    final prefs = await _preferencesInstance;
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    final prefs = await _preferencesInstance;
    await prefs.remove(_tokenKey);
  }

  Future<void> _persistToken(String token) async {
    _cachedToken = token;
    final prefs = await _preferencesInstance;
    await prefs.setString(_tokenKey, token);
  }

  Future<SharedPreferences> get _preferencesInstance async {
    if (_preferences != null) return _preferences!;
    _preferences = await SharedPreferences.getInstance();
    return _preferences!;
  }

  Map<String, dynamic> _extractUserMap(Map<String, dynamic> data) {
    final user = data['user'];
    if (user is Map<String, dynamic>) {
      return Map<String, dynamic>.from(user);
    }
    return data;
  }
}
