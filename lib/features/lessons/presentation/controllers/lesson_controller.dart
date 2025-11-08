import 'package:flutter/foundation.dart';

import 'package:cert_classroom_mobile/features/lessons/data/lessons_repository.dart';
import 'package:cert_classroom_mobile/features/lessons/data/models/lesson.dart';

class LessonController extends ChangeNotifier {
  LessonController({
    required this.lessonId,
    LessonsRepository? repository,
  }) : _repository = repository ?? LessonsRepository();

  final int lessonId;
  final LessonsRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  LessonDetail? lesson;

  Future<void> loadLesson({bool refresh = false}) async {
    if (isLoading && !refresh) return;
    isLoading = true;
    errorMessage = null;
    if (!refresh) notifyListeners();
    try {
      lesson = await _repository.getLessonDetail(lessonId);
    } catch (e) {
      errorMessage = 'Không thể tải bài học';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
