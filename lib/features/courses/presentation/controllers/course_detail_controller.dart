import 'package:flutter/foundation.dart';

import 'package:cert_classroom_mobile/features/courses/data/courses_repository.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';

class CourseDetailController extends ChangeNotifier {
  CourseDetailController({
    required this.courseId,
    CoursesRepository? repository,
  }) : _repository = repository ?? CoursesRepository();

  final int courseId;
  final CoursesRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  CourseDetail? detail;

  Future<void> loadDetail({bool refresh = false}) async {
    if (isLoading && !refresh) return;
    isLoading = true;
    errorMessage = null;
    if (!refresh) notifyListeners();
    try {
      detail = await _repository.getCourseDetail(courseId);
    } catch (e) {
      errorMessage = 'Không thể tải thông tin khóa học';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
