import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';

class EnrolledCourse {
  const EnrolledCourse({
    required this.enrollmentId,
    required this.status,
    this.course,
    this.percentOverall,
    this.percentVideo,
    this.avgMiniTest,
    this.lastLesson,
    this.timeline,
  });

  final String enrollmentId;
  final String status;
  final CourseSummary? course;
  final double? percentOverall;
  final double? percentVideo;
  final double? avgMiniTest;
  final CourseLessonSummary? lastLesson;
  final EnrollmentTimeline? timeline;

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    final progress = json['progress'] as Map<String, dynamic>?;
    return EnrolledCourse(
      enrollmentId:
          json['enrollment_id']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      course:
          json['course'] is Map<String, dynamic>
              ? CourseSummary.fromJson(json['course'] as Map<String, dynamic>)
              : null,
      percentOverall: _parseDouble(progress?['percent_overall']),
      percentVideo: _parseDouble(progress?['percent_video']),
      avgMiniTest: _parseDouble(progress?['avg_minitest']),
      lastLesson:
          progress?['last_lesson'] is Map<String, dynamic>
              ? CourseLessonSummary.fromJson(
                progress?['last_lesson'] as Map<String, dynamic>,
              )
              : null,
      timeline:
          json['timeline'] is Map<String, dynamic>
              ? EnrollmentTimeline.fromJson(
                json['timeline'] as Map<String, dynamic>,
              )
              : null,
    );
  }
}

class EnrollmentTimeline {
  const EnrollmentTimeline({
    this.enrolledAt,
    this.activatedAt,
    this.expiresAt,
    this.updatedAt,
  });

  final String? enrolledAt;
  final String? activatedAt;
  final String? expiresAt;
  final String? updatedAt;

  factory EnrollmentTimeline.fromJson(Map<String, dynamic> json) {
    return EnrollmentTimeline(
      enrolledAt: json['enrolled_at']?.toString(),
      activatedAt: json['activated_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}
