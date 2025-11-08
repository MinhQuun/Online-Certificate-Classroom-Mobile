import 'package:cert_classroom_mobile/core/network/api_client.dart';

class EnrolledApi {
  EnrolledApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> getEnrolledCourses() async {
    final response = await _client.get('/student/courses/enrolled');
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final items = data['items'];
        if (items is List) {
          return items.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    return const [];
  }
}
