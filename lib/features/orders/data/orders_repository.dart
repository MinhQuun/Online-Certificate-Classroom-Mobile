import 'package:cert_classroom_mobile/core/network/api_exceptions.dart';

import 'models/order.dart';
import 'orders_api.dart';

class OrdersRepository {
  OrdersRepository({OrdersApi? api}) : _api = api ?? OrdersApi();

  final OrdersApi _api;

  Future<List<OrderSummary>> fetchOrders({String status = 'all'}) async {
    try {
      final data = await _api.fetchOrders(status: status);
      return data.map(OrderSummary.fromJson).toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Không thể tải lịch sử đơn hàng. Vui lòng thử lại.');
    }
  }

  Future<OrderSummary?> fetchOrderDetail(int id) async {
    try {
      final data = await _api.fetchOrderDetail(id);
      if (data.isEmpty) return null;
      return OrderSummary.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Không thể tải chi tiết đơn hàng');
    }
  }
}
