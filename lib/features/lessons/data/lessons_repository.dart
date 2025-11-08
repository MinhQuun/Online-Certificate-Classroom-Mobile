import 'lessons_api.dart';
import 'models/lesson.dart';

class LessonsRepository {
  LessonsRepository({LessonsApi? api}) : _api = api ?? LessonsApi();

  final LessonsApi _api;

  Future<LessonDetail> getLessonDetail(int id) async {
    final data = await _api.getLessonDetail(id);
    return LessonDetail.fromJson(data);
  }
}
