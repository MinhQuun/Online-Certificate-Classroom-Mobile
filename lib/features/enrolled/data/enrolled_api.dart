import 'package:cert_classroom_mobile/core/network/api_client.dart';

class EnrolledApi {
  EnrolledApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> getEnrolledCourses({
    String status = 'all',
  }) async {
    final response = await _client.get(
      '/student/courses/enrolled',
      queryParameters: {'status': status},
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    return const {};
  }
}
