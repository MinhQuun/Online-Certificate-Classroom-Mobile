import 'package:flutter/foundation.dart';

import 'package:cert_classroom_mobile/features/courses/data/courses_repository.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';

class CoursesController extends ChangeNotifier {
  CoursesController({CoursesRepository? repository})
    : _repository = repository ?? CoursesRepository();

  final CoursesRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  List<CourseSummary> courses = const [];

  Future<void> loadCourses({bool refresh = false}) async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final items = await _repository.getCourses();
      courses = items;
    } catch (e) {
      errorMessage = 'Không thể tải danh sách khóa học';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
