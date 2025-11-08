import 'lessons_api.dart';
import 'models/lesson.dart';
import 'models/lesson_progress.dart';

class LessonsRepository {
  LessonsRepository({LessonsApi? api}) : _api = api ?? LessonsApi();

  final LessonsApi _api;

  Future<(List<Lesson>, LessonProgress)> fetchLessons(String courseId) {
    return _api.fetchLessons(courseId);
  }
}
