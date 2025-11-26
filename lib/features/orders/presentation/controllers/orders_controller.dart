import 'package:flutter/foundation.dart';

import 'package:cert_classroom_mobile/core/network/api_exceptions.dart';
import 'package:cert_classroom_mobile/features/orders/data/models/order.dart';
import 'package:cert_classroom_mobile/features/orders/data/orders_repository.dart';

class OrdersController extends ChangeNotifier {
  OrdersController({OrdersRepository? repository})
      : _repository = repository ?? OrdersRepository();

  final OrdersRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  List<OrderSummary> orders = [];
  String activeFilter = 'all';

  Future<void> loadOrders({String? status, bool refresh = false}) async {
    if (isLoading && !refresh) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final filter = status ?? activeFilter;
    try {
      final data = await _repository.fetchOrders(status: filter);
      orders = data;
      activeFilter = filter;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Không thể tải lịch sử đơn hàng';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
