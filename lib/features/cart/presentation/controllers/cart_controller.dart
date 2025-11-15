import 'package:flutter/foundation.dart';

import 'package:cert_classroom_mobile/features/cart/data/cart_repository.dart';
import 'package:cert_classroom_mobile/features/cart/data/models/cart_selection.dart';
import 'package:cert_classroom_mobile/features/cart/data/models/cart_snapshot.dart';
import 'package:cert_classroom_mobile/features/cart/data/models/checkout.dart';
import 'package:cert_classroom_mobile/shared/controllers/student_session_controller.dart';

class CartController extends ChangeNotifier {
  CartController({
    required StudentSessionController session,
    CartRepository? repository,
  }) : _session = session,
       _repository = repository ?? CartRepository() {
    _sessionListener = () {
      _pruneSelection();
      notifyListeners();
    };
    _session.addListener(_sessionListener!);
  }

  final StudentSessionController _session;
  final CartRepository _repository;

  final Set<int> selectedCourseIds = <int>{};
  final Set<int> selectedComboIds = <int>{};

  bool isMutating = false;
  String? errorMessage;
  VoidCallback? _sessionListener;

  CartSnapshot get snapshot => _session.cart ?? CartSnapshot.empty();

  bool get hasSelection =>
      selectedCourseIds.isNotEmpty || selectedComboIds.isNotEmpty;

  void toggleCourse(int courseId) {
    if (selectedCourseIds.contains(courseId)) {
      selectedCourseIds.remove(courseId);
    } else {
      selectedCourseIds.add(courseId);
    }
    notifyListeners();
  }

  void toggleCombo(int comboId) {
    if (selectedComboIds.contains(comboId)) {
      selectedComboIds.remove(comboId);
    } else {
      selectedComboIds.add(comboId);
    }
    notifyListeners();
  }

  void toggleAll(bool select) {
    if (select) {
      selectedCourseIds
        ..clear()
        ..addAll(snapshot.courseIds);
      selectedComboIds
        ..clear()
        ..addAll(snapshot.comboIds);
    } else {
      selectedCourseIds.clear();
      selectedComboIds.clear();
    }
    notifyListeners();
  }

  Future<void> removeSelected() async {
    if (!hasSelection) return;
    await _performMutation(() async {
      final selection = _currentSelection();
      await _session.removeSelected(selection);
      selectedCourseIds.clear();
      selectedComboIds.clear();
    });
  }

  Future<void> removeCourse(int courseId) async {
    await _performMutation(() async {
      await _session.removeCourseFromCart(courseId);
      selectedCourseIds.remove(courseId);
    });
  }

  Future<void> removeCombo(int comboId) async {
    await _performMutation(() async {
      await _session.removeComboFromCart(comboId);
      selectedComboIds.remove(comboId);
    });
  }

  Future<void> clearCart() async {
    await _performMutation(() async {
      await _session.clearCart();
      selectedCourseIds.clear();
      selectedComboIds.clear();
    });
  }

  Future<CheckoutPreview?> previewCheckout() async {
    if (snapshot.isEmpty) return null;
    final selection = hasSelection ? _currentSelection() : _fullSelection();
    if (selection.isEmpty) return null;
    try {
      final preview = await _repository.previewCheckout(selection);
      return preview;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<CheckoutResult?> completeCheckout(String method) async {
    final selection = hasSelection ? _currentSelection() : _fullSelection();
    if (selection.isEmpty) return null;
    try {
      final result = await _repository.completeCheckout(
        selection: selection,
        paymentMethod: method,
      );
      await _session.refreshCart(force: true);
      await _session.refreshEnrollments(force: true);
      selectedCourseIds.clear();
      selectedComboIds.clear();
      notifyListeners();
      return result;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  CartSelection _currentSelection() {
    return CartSelection(
      courseIds: selectedCourseIds.toList(),
      comboIds: selectedComboIds.toList(),
    );
  }

  CartSelection _fullSelection() {
    return CartSelection(
      courseIds: snapshot.courses.map((course) => course.id).toList(),
      comboIds: snapshot.combos.map((combo) => combo.id).toList(),
    );
  }

  Future<void> _performMutation(Future<void> Function() action) async {
    if (isMutating) return;
    isMutating = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } finally {
      isMutating = false;
      _pruneSelection();
      notifyListeners();
    }
  }

  void _pruneSelection() {
    final validCourseIds = snapshot.courseIds;
    selectedCourseIds.removeWhere((id) => !validCourseIds.contains(id));
    final validComboIds = snapshot.comboIds;
    selectedComboIds.removeWhere((id) => !validComboIds.contains(id));
  }

  @override
  void dispose() {
    if (_sessionListener != null) {
      _session.removeListener(_sessionListener!);
    }
    super.dispose();
  }
}
