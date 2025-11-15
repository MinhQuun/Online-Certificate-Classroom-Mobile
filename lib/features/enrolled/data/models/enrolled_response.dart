import 'enrolled_course.dart';

class EnrolledResponse {
  const EnrolledResponse({
    required this.courses,
    required this.summary,
    required this.filter,
  });

  final List<EnrolledCourse> courses;
  final EnrolledSummary summary;
  final String filter;
}

class EnrolledSummary {
  const EnrolledSummary({
    required this.all,
    required this.active,
    required this.pending,
    required this.expired,
  });

  final int all;
  final int active;
  final int pending;
  final int expired;

  factory EnrolledSummary.fromJson(Map<String, dynamic> json) {
    return EnrolledSummary(
      all: _parseInt(json['all']),
      active: _parseInt(json['active']),
      pending: _parseInt(json['pending']),
      expired: _parseInt(json['expired']),
    );
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}
