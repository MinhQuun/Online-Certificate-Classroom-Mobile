import 'cart_api.dart';
import 'models/cart_selection.dart';
import 'models/cart_snapshot.dart';
import 'models/checkout.dart';

class CartRepository {
  CartRepository({CartApi? api}) : _api = api ?? CartApi();

  final CartApi _api;

  Future<CartSnapshot> fetchCart() async {
    final response = await _api.fetchCart();
    return _toSnapshot(response);
  }

  Future<CartMutationResult> addCourse(int courseId) async {
    final response = await _api.addCourse(courseId);
    return _toMutationResult(response);
  }

  Future<CartMutationResult> removeCourse(int courseId) async {
    final response = await _api.removeCourse(courseId);
    return _toMutationResult(response);
  }

  Future<CartMutationResult> addCombo(int comboId) async {
    final response = await _api.addCombo(comboId);
    return _toMutationResult(response);
  }

  Future<CartMutationResult> removeCombo(int comboId) async {
    final response = await _api.removeCombo(comboId);
    return _toMutationResult(response);
  }

  Future<CartMutationResult> removeSelected(CartSelection selection) async {
    final response = await _api.removeSelected(
      courseIds: selection.courseIds,
      comboIds: selection.comboIds,
    );
    return _toMutationResult(response);
  }

  Future<CartMutationResult> clearCart() async {
    final response = await _api.clearCart();
    return _toMutationResult(response);
  }

  Future<CheckoutPreview> previewCheckout(CartSelection selection) async {
    final response = await _api.checkoutPreview(_toSelectionPayload(selection));
    final data = _extractData(response);
    return CheckoutPreview.fromJson(data);
  }

  Future<CheckoutResult> completeCheckout({
    required CartSelection selection,
    required String paymentMethod,
  }) async {
    final payload = {
      ..._toSelectionPayload(selection),
      'payment_method': paymentMethod,
    };
    final response = await _api.checkoutComplete(payload);
    final data = _extractData(response);
    return CheckoutResult.fromJson(data);
  }

  CartSnapshot _toSnapshot(Map<String, dynamic> response) {
    final data = _extractData(response);
    if (data.isEmpty) return CartSnapshot.empty();
    return CartSnapshot.fromJson(data);
  }

  CartMutationResult _toMutationResult(Map<String, dynamic> response) {
    final snapshot = _toSnapshot(response);
    final status = response['status']?.toString() ?? 'success';
    final message = response['message']?.toString();
    return CartMutationResult(
      snapshot: snapshot,
      status: status,
      message: message,
    );
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return const {};
  }

  Map<String, dynamic> _toSelectionPayload(CartSelection selection) {
    final map = <String, dynamic>{};
    if (selection.courseIds.isNotEmpty) {
      map['courses'] = selection.courseIds;
    }
    if (selection.comboIds.isNotEmpty) {
      map['combos'] = selection.comboIds;
    }
    return map;
  }
}

class CartMutationResult {
  const CartMutationResult({
    required this.snapshot,
    required this.status,
    this.message,
  });

  final CartSnapshot snapshot;
  final String status;
  final String? message;

  bool get isSuccess => status.toLowerCase() == 'success';
}
