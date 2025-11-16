import 'lessons_api.dart';
import 'models/lesson.dart';
import 'models/lesson_progress_update.dart';

class LessonsRepository {
  LessonsRepository({LessonsApi? api}) : _api = api ?? LessonsApi();

  final LessonsApi _api;

  Future<LessonDetail> getLessonDetail(int id) async {
    final data = await _api.getLessonDetail(id);
    return LessonDetail.fromJson(data);
  }

  Future<LessonProgressUpdateResult> updateLessonProgress(
    LessonProgressUpdateInput input,
  ) async {
    final data = await _api.updateLessonProgress(
      input.lessonId,
      input.toJson(),
    );
    return LessonProgressUpdateResult.fromJson(data);
  }
}
