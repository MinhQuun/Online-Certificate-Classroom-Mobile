import 'package:cert_classroom_mobile/core/network/api_exceptions.dart';

import 'activation_api.dart';

class ActivationRepository {
  ActivationRepository({ActivationApi? api}) : _api = api ?? ActivationApi();

  final ActivationApi _api;

  Future<ActivationResult> activate(String code) async {
    final response = await _api.activate(code);
    final status = response['status']?.toString() ?? 'error';
    if (status != 'success') {
      throw ApiException(
        response['message']?.toString() ?? 'Không thể kích hoạt mã này.',
      );
    }
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return ActivationResult.fromJson(data);
    }
    throw ApiException('Không nhận được kết quả kích hoạt.');
  }
}

class ActivationResult {
  const ActivationResult({
    required this.courseId,
    required this.courseName,
    this.expiresAt,
  });

  final int courseId;
  final String courseName;
  final String? expiresAt;

  factory ActivationResult.fromJson(Map<String, dynamic> json) {
    return ActivationResult(
      courseId: _parseInt(json['course_id']),
      courseName: json['course_name']?.toString() ?? 'Khóa học',
      expiresAt: json['expires_at']?.toString(),
    );
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}
