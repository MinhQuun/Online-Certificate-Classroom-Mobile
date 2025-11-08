import 'models/lesson.dart';
import 'models/lesson_progress.dart';

class LessonsApi {
  Future<(List<Lesson>, LessonProgress)> fetchLessons(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return (Lesson.sample(courseId), LessonProgress.sample());
  }
}
