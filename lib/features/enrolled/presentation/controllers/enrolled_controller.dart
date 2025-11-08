import 'package:flutter/foundation.dart';

import 'package:cert_classroom_mobile/features/enrolled/data/enrolled_repository.dart';
import 'package:cert_classroom_mobile/features/enrolled/data/models/enrolled_course.dart';

class EnrolledController extends ChangeNotifier {
  EnrolledController({EnrolledRepository? repository})
    : _repository = repository ?? EnrolledRepository();

  final EnrolledRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  List<EnrolledCourse> courses = const [];

  Future<void> loadEnrolled() async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      courses = await _repository.getEnrolledCourses();
    } catch (e) {
      errorMessage = 'Không thể tải khóa học đã tham gia';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
