import 'package:flutter/foundation.dart';

import 'package:cert_classroom_mobile/features/enrolled/data/enrolled_repository.dart';
import 'package:cert_classroom_mobile/features/enrolled/data/models/enrolled_course.dart';
import 'package:cert_classroom_mobile/features/enrolled/data/models/enrolled_response.dart';

class EnrolledController extends ChangeNotifier {
  EnrolledController({EnrolledRepository? repository})
    : _repository = repository ?? EnrolledRepository();

  final EnrolledRepository _repository;

  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  List<EnrolledCourse> courses = const [];
  EnrolledSummary summary = const EnrolledSummary(
    all: 0,
    active: 0,
    pending: 0,
    expired: 0,
  );
  String activeFilter = 'all';

  Future<void> loadEnrolled({
    String status = 'all',
    bool refresh = false,
  }) async {
    if (isLoading && !refresh) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await _repository.getEnrolledCourses(status: status);
      courses = response.courses;
      summary = response.summary;
      activeFilter = response.filter;
      hasLoaded = true;
    } catch (error) {
      errorMessage = 'Không thể tải danh sách khóa học của bạn';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
