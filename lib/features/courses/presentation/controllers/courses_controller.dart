import 'package:flutter/foundation.dart';

import 'package:cert_classroom_mobile/features/courses/data/combos_repository.dart';
import 'package:cert_classroom_mobile/features/courses/data/courses_repository.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/combo.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';

class CoursesController extends ChangeNotifier {
  CoursesController({
    CoursesRepository? repository,
    CombosRepository? combosRepository,
  }) : _repository = repository ?? CoursesRepository(),
       _combosRepository = combosRepository ?? CombosRepository();

  final CoursesRepository _repository;
  final CombosRepository _combosRepository;

  bool isLoading = false;
  String? errorMessage;
  List<CourseSummary> courses = const [];
  List<CourseCombo> combos = const [];

  Future<void> loadCourses({bool refresh = false, String? search}) async {
    if (isLoading && !refresh) return;
    isLoading = true;
    errorMessage = null;
    if (!refresh) notifyListeners();
    try {
      courses = await _repository.getCourses(search: search);
      try {
        combos = await _combosRepository.getCombos(perPage: 6);
      } catch (_) {
        combos = const [];
      }
    } catch (e) {
      errorMessage = 'Không thể tải danh sách khóa học';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
