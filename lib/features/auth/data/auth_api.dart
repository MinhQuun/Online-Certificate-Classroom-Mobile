import 'package:cert_classroom_mobile/core/network/api_client.dart';
import 'package:cert_classroom_mobile/core/network/api_exceptions.dart';

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final response = await _client.post(
      '/student/login',
      body: {
        'email': email,
        'password': password,
        'device_name': deviceName,
      },
    );
    return _extractData(response);
  }

  Future<void> logout() async {
    final response = await _client.post('/student/logout');
    _ensureSuccess(response);
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _client.get('/student/profile');
    return _extractData(response);
  }

  Map<String, dynamic> _extractData(dynamic response) {
    _ensureSuccess(response);
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return <String, dynamic>{};
    }
    throw ApiException('Phan hoi khong hop le tu may chu');
  }

  void _ensureSuccess(dynamic response) {
    if (response is Map<String, dynamic>) {
      final status = response['status']?.toString();
      if (status != null && status != 'success') {
        final message =
            response['message']?.toString() ?? 'Yeu cau that bai, thu lai sau.';
        throw ApiException(message);
      }
      return;
    }
    throw ApiException('Phan hoi khong hop le tu may chu');
  }
}
