import 'enrolled_api.dart';
import 'models/enrolled_course.dart';
import 'models/enrolled_response.dart';

class EnrolledRepository {
  EnrolledRepository({EnrolledApi? api}) : _api = api ?? EnrolledApi();

  final EnrolledApi _api;

  Future<EnrolledResponse> getEnrolledCourses({String status = 'all'}) async {
    final response = await _api.getEnrolledCourses(status: status);
    final data = response['data'] as Map<String, dynamic>? ?? const {};
    final items =
        (data['items'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(EnrolledCourse.fromJson)
            .toList();
    final summaryMap = data['summary'] as Map<String, dynamic>? ?? const {};
    final summary = EnrolledSummary.fromJson(summaryMap);
    final filters = data['filters'] as Map<String, dynamic>? ?? const {};
    final filter = filters['status']?.toString() ?? status;
    return EnrolledResponse(courses: items, summary: summary, filter: filter);
  }
}
