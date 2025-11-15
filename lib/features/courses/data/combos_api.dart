import 'package:cert_classroom_mobile/core/network/api_client.dart';

class CombosApi {
  CombosApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> getCombos({
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await _client.get(
      '/student/combos',
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );
    return _extractList(response);
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final items = data['items'];
        if (items is List) {
          return items.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    return const [];
  }
}
