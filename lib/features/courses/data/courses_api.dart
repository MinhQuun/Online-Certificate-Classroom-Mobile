import 'package:cert_classroom_mobile/core/network/api_client.dart';

class CoursesApi {
  CoursesApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> getCourses({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _client.get(
      '/courses',
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );
    return _extractList(response);
  }

  Future<Map<String, dynamic>> getCourseDetail(int id) async {
    final response = await _client.get('/courses/$id');
    return _extractMap(response);
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    final data = _maybeData(response);
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      if (data['items'] is List) {
        return List<Map<String, dynamic>>.from(
          data['items'] as List,
        ).whereType<Map<String, dynamic>>().toList();
      }
      if (data['data'] is List) {
        return List<Map<String, dynamic>>.from(
          data['data'] as List,
        ).whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic response) {
    final data = _maybeData(response);
    if (data is Map<String, dynamic>) return data;
    return const {};
  }

  dynamic _maybeData(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response['data'] ?? response['payload'] ?? response;
    }
    return response;
  }
}
