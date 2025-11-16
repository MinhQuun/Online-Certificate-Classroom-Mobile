import 'package:flutter/foundation.dart';

import 'package:cert_classroom_mobile/core/network/api_exceptions.dart';
import 'package:cert_classroom_mobile/features/cart/data/cart_repository.dart';
import 'package:cert_classroom_mobile/features/cart/data/models/cart_selection.dart';
import 'package:cert_classroom_mobile/features/cart/data/models/cart_snapshot.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';
import 'package:cert_classroom_mobile/features/enrolled/data/enrolled_repository.dart';
import 'package:cert_classroom_mobile/features/enrolled/data/models/enrolled_course.dart';

class StudentSessionController extends ChangeNotifier {
  StudentSessionController({
    CartRepository? cartRepository,
    EnrolledRepository? enrolledRepository,
  }) : _cartRepository = cartRepository ?? CartRepository(),
       _enrolledRepository = enrolledRepository ?? EnrolledRepository();

  final CartRepository _cartRepository;
  final EnrolledRepository _enrolledRepository;

  CartSnapshot? _cart;
  bool _cartLoading = false;
  bool _enrollmentLoading = false;
  bool _bootstrapped = false;
  String? lastError;

  Set<int> _cartCourseIds = {};
  Set<int> _activatedCourseIds = {};
  final Map<int, EnrolledCourse> _enrollmentsByCourse = {};

  CartSnapshot? get cart => _cart;
  bool get isBootstrapped => _bootstrapped;
  bool get isLoading => _cartLoading || _enrollmentLoading;
  bool get isCartLoading => _cartLoading;
  bool get isEnrollmentLoading => _enrollmentLoading;
  int get cartCount => _cart?.counts.total ?? 0;
  double? progressPercentForCourse(int courseId) {
    return _enrollmentsByCourse[courseId]?.percentOverall;
  }

  CourseLessonSummary? resumeLessonForCourse(int courseId) {
    return _enrollmentsByCourse[courseId]?.lastLesson;
  }

  Future<void> refreshAll({bool force = false}) async {
    if (_bootstrapped && !force && isLoading) {
      return;
    }
    await Future.wait([
      refreshCart(force: force),
      refreshEnrollments(force: force),
    ]);
    _bootstrapped = true;
  }

  Future<void> refreshCart({bool force = false}) async {
    if (_cartLoading && !force) return;
    _cartLoading = true;
    notifyListeners();
    try {
      final snapshot = await _cartRepository.fetchCart();
      _applyCartSnapshot(snapshot);
    } on ApiException catch (error) {
      lastError = error.message;
    } finally {
      _cartLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshEnrollments({bool force = false}) async {
    if (_enrollmentLoading && !force) return;
    _enrollmentLoading = true;
    notifyListeners();
    try {
      final response = await _enrolledRepository.getEnrolledCourses();
      _syncEnrollmentSets(response.courses);
    } on ApiException catch (error) {
      lastError = error.message;
    } finally {
      _enrollmentLoading = false;
      notifyListeners();
    }
  }

  Future<CartMutationResult> addCourseToCart(int courseId) async {
    final result = await _cartRepository.addCourse(courseId);
    _applyCartSnapshot(result.snapshot);
    return result;
  }

  Future<CartMutationResult> removeCourseFromCart(int courseId) async {
    final result = await _cartRepository.removeCourse(courseId);
    _applyCartSnapshot(result.snapshot);
    return result;
  }

  Future<CartMutationResult> addComboToCart(int comboId) async {
    final result = await _cartRepository.addCombo(comboId);
    _applyCartSnapshot(result.snapshot);
    return result;
  }

  Future<CartMutationResult> removeComboFromCart(int comboId) async {
    final result = await _cartRepository.removeCombo(comboId);
    _applyCartSnapshot(result.snapshot);
    return result;
  }

  Future<CartMutationResult> removeSelected(CartSelection selection) async {
    final result = await _cartRepository.removeSelected(selection);
    _applyCartSnapshot(result.snapshot);
    return result;
  }

  Future<CartMutationResult> clearCart() async {
    final result = await _cartRepository.clearCart();
    _applyCartSnapshot(result.snapshot);
    return result;
  }

  void applyCheckoutResult(CartSnapshot snapshot) {
    _applyCartSnapshot(snapshot);
  }

  CourseUserState stateForCourse(int courseId) {
    if (_activatedCourseIds.contains(courseId)) {
      return CourseUserState.activated;
    }
    if (_cartCourseIds.contains(courseId)) {
      return CourseUserState.inCart;
    }
    return CourseUserState.addable;
  }

  void reset() {
    _cart = null;
    _cartCourseIds = {};
    _activatedCourseIds = {};
    _enrollmentsByCourse.clear();
    lastError = null;
    _bootstrapped = false;
    notifyListeners();
  }

  void _applyCartSnapshot(CartSnapshot snapshot) {
    _cart = snapshot;
    _cartCourseIds = snapshot.courseIds;
    notifyListeners();
  }

  void _syncEnrollmentSets(List<EnrolledCourse> courses) {
    final activated = <int>{};
    final mapped = <int, EnrolledCourse>{};
    for (final enrollment in courses) {
      final summary = enrollment.course;
      if (summary == null) continue;
      final courseId = summary.id;
      mapped[courseId] = enrollment;
      final status = enrollment.status.toUpperCase();
      if (_isAccessibleStatus(status)) {
        activated.add(courseId);
      }
    }
    _activatedCourseIds = activated;
    _enrollmentsByCourse
      ..clear()
      ..addAll(mapped);
    notifyListeners();
  }

  void updateCourseSnapshot({
    required int courseId,
    double? percentOverall,
    CourseLessonSummary? lastLesson,
  }) {
    if (percentOverall == null && lastLesson == null) return;
    final existing = _enrollmentsByCourse[courseId];
    if (existing == null) {
      _enrollmentsByCourse[courseId] = EnrolledCourse(
        enrollmentId: '$courseId',
        status: 'ACTIVE',
        course: CourseSummary(id: courseId, title: 'Khóa học'),
        percentOverall: percentOverall,
        percentVideo: null,
        avgMiniTest: null,
        lastLesson: lastLesson,
        timeline: null,
      );
    } else {
      _enrollmentsByCourse[courseId] = EnrolledCourse(
        enrollmentId: existing.enrollmentId,
        status: existing.status,
        course: existing.course,
        percentOverall: percentOverall ?? existing.percentOverall,
        percentVideo: existing.percentVideo,
        avgMiniTest: existing.avgMiniTest,
        lastLesson: lastLesson ?? existing.lastLesson,
        timeline: existing.timeline,
      );
    }
    _activatedCourseIds.add(courseId);
    notifyListeners();
  }

  bool _isAccessibleStatus(String status) {
    switch (status) {
      case 'ACTIVE':
      case 'OWNED':
      case 'ENROLLED':
      case 'IN_PROGRESS':
      case 'COMPLETED':
      case 'PENDING':
      case 'PAID':
        return true;
      default:
        return false;
    }
  }
}
