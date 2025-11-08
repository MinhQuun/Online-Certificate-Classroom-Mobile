import 'enrolled_api.dart';
import 'models/enrolled_course.dart';

class EnrolledRepository {
  EnrolledRepository({EnrolledApi? api}) : _api = api ?? EnrolledApi();

  final EnrolledApi _api;

  Future<List<EnrolledCourse>> getEnrolledCourses() async {
    final data = await _api.getEnrolledCourses();
    return data.map(EnrolledCourse.fromJson).toList();
  }
}
