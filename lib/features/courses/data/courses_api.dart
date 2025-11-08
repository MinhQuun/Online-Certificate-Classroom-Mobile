import 'models/course.dart';

/// Fake remote source for the course catalog.
class CoursesApi {
  Future<List<Course>> fetchCourses() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Course.sample();
  }
}
