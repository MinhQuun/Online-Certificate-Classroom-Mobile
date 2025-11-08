import 'package:cert_classroom_mobile/core/network/api_client.dart';

class LessonsApi {
  LessonsApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> getLessonDetail(int id) async {
    final response = await _client.get('/lessons/$id');
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
    }
    return const {};
  }
}
