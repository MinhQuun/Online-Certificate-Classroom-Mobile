import 'package:cert_classroom_mobile/core/network/api_client.dart';

class ActivationApi {
  ActivationApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> activate(String code) async {
    final response = await _client.post(
      '/student/activations',
      body: {'code': code},
    );
    return _ensureMap(response);
  }

  Map<String, dynamic> _ensureMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    return const {};
  }
}
