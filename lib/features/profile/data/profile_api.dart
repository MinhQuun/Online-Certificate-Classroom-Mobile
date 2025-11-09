import 'package:cert_classroom_mobile/core/network/api_client.dart';

class ProfileApi {
  ProfileApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _client.get('/student/profile');
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
    }
    return const {};
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    final response = await _client.put('/student/profile', body: body);
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
    }
    return const {};
  }

  Future<Map<String, dynamic>> fetchProgressOverview() async {
    final response = await _client.get('/student/progress/overview');
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
    }
    return const {};
  }
}
