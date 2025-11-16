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

  static const List<String> _comboPreferredOrder = [
    'TOEIC Foundation Full Pack (405-600)',
    'TOEIC Intermediate Full Pack (605-780)',
    'TOEIC Advanced Full Pack (785-990)',
  ];

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
        final fetched = await _combosRepository.getCombos(perPage: 6);
        combos = _sortCombos(fetched);
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

  List<CourseCombo> _sortCombos(List<CourseCombo> combos) {
    final sorted = [...combos];
    sorted.sort((a, b) {
      final idxA = _comboPreferredOrder.indexOf(a.name);
      final idxB = _comboPreferredOrder.indexOf(b.name);
      if (idxA != idxB) {
        final safeA = idxA == -1 ? _comboPreferredOrder.length : idxA;
        final safeB = idxB == -1 ? _comboPreferredOrder.length : idxB;
        if (safeA != safeB) return safeA.compareTo(safeB);
      }
      return a.name.compareTo(b.name);
    });
    return sorted;
  }
}
