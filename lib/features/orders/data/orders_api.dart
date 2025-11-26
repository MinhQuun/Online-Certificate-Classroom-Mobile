import 'package:cert_classroom_mobile/core/network/api_client.dart';

class OrdersApi {
  OrdersApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> fetchOrders({String status = 'all'}) async {
    final response = await _client.get(
      '/student/orders',
      queryParameters: {
        if (status != 'all') 'status': status,
      },
    );
    return _extractList(response);
  }

  Future<Map<String, dynamic>> fetchOrderDetail(int id) async {
    final response = await _client.get('/student/orders/$id');
    return _extractMap(response);
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    final data = _maybeData(response);
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final candidates = [
        data['items'],
        data['orders'],
        data['data'],
        (data['orders'] is Map ? (data['orders'] as Map)['data'] : null),
        (data['data'] is Map ? (data['data'] as Map)['data'] : null),
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          return List<Map<String, dynamic>>.from(candidate)
              .whereType<Map<String, dynamic>>()
              .toList();
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic response) {
    final data = _maybeData(response);
    if (data is Map<String, dynamic>) {
      if (data['order'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['order'] as Map);
      }
      return data;
    }
    return const {};
  }

  dynamic _maybeData(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response['data'] ?? response['payload'] ?? response;
    }
    return response;
  }
}
