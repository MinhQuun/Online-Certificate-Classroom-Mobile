import 'courses_api.dart';
import 'models/course.dart';

class CoursesRepository {
  CoursesRepository({CoursesApi? api}) : _api = api ?? CoursesApi();

  final CoursesApi _api;

  Future<List<Course>> fetchCourses() => _api.fetchCourses();
}
