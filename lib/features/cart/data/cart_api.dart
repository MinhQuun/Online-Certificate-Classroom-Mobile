import 'package:cert_classroom_mobile/core/network/api_client.dart';

class CartApi {
  CartApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchCart() async {
    final response = await _client.get('/student/cart');
    return _ensureMap(response);
  }

  Future<Map<String, dynamic>> addCourse(int courseId) async {
    final response = await _client.post(
      '/student/cart/courses',
      body: {'course_id': courseId},
    );
    return _ensureMap(response);
  }

  Future<Map<String, dynamic>> addCombo(int comboId) async {
    final response = await _client.post(
      '/student/cart/combos',
      body: {'combo_id': comboId},
    );
    return _ensureMap(response);
  }

  Future<Map<String, dynamic>> removeCourse(int courseId) async {
    final response = await _client.delete('/student/cart/courses/$courseId');
    return _ensureMap(response);
  }

  Future<Map<String, dynamic>> removeCombo(int comboId) async {
    final response = await _client.delete('/student/cart/combos/$comboId');
    return _ensureMap(response);
  }

  Future<Map<String, dynamic>> removeSelected({
    List<int>? courseIds,
    List<int>? comboIds,
  }) async {
    final response = await _client.post(
      '/student/cart/remove-selected',
      body: {
        if (courseIds != null) 'selected_courses': courseIds,
        if (comboIds != null) 'selected_combos': comboIds,
      },
    );
    return _ensureMap(response);
  }

  Future<Map<String, dynamic>> clearCart() async {
    final response = await _client.delete('/student/cart');
    return _ensureMap(response);
  }

  Future<Map<String, dynamic>> checkoutPreview(
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post(
      '/student/checkout/preview',
      body: payload,
    );
    return _ensureMap(response);
  }

  Future<Map<String, dynamic>> checkoutComplete(
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post(
      '/student/checkout/complete',
      body: payload,
    );
    return _ensureMap(response);
  }

  Map<String, dynamic> _ensureMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }
    return const {};
  }
}
