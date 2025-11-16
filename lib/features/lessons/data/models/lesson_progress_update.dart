import 'package:cert_classroom_mobile/features/lessons/data/models/lesson.dart';

class LessonProgressUpdateInput {
  const LessonProgressUpdateInput({
    required this.lessonId,
    required this.status,
    this.totalViewSeconds,
    this.videoProgressSeconds,
    this.videoDurationSeconds,
    this.watchCount,
    this.lastViewedAt,
    this.completedAt,
    this.coursePercentOverall,
    this.coursePercentVideo,
    this.markLastLesson = false,
  });

  final int lessonId;
  final String status;
  final int? totalViewSeconds;
  final int? videoProgressSeconds;
  final int? videoDurationSeconds;
  final int? watchCount;
  final String? lastViewedAt;
  final String? completedAt;
  final int? coursePercentOverall;
  final int? coursePercentVideo;
  final bool markLastLesson;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'status': status,
      if (totalViewSeconds != null) 'total_view_seconds': totalViewSeconds,
      if (videoProgressSeconds != null)
        'video_progress_seconds': videoProgressSeconds,
      if (videoDurationSeconds != null)
        'video_duration_seconds': videoDurationSeconds,
      if (watchCount != null) 'watch_count': watchCount,
      if (lastViewedAt != null) 'last_viewed_at': lastViewedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (markLastLesson) 'mark_last_lesson': true,
    };
    final courseProgress = <String, dynamic>{};
    if (coursePercentOverall != null) {
      courseProgress['percent_overall'] = coursePercentOverall;
    }
    if (coursePercentVideo != null) {
      courseProgress['percent_video'] = coursePercentVideo;
    }
    if (courseProgress.isNotEmpty) {
      payload['course_progress'] = courseProgress;
    }
    return payload;
  }
}

class LessonProgressUpdateResult {
  const LessonProgressUpdateResult({
    this.lessonProgress,
    this.coursePercentOverall,
    this.coursePercentVideo,
    this.lastLessonId,
  });

  final LessonProgress? lessonProgress;
  final int? coursePercentOverall;
  final int? coursePercentVideo;
  final int? lastLessonId;

  factory LessonProgressUpdateResult.fromJson(Map<String, dynamic> json) {
    final progress =
        json['progress'] is Map<String, dynamic>
            ? LessonProgress.fromJson(json['progress'] as Map<String, dynamic>)
            : null;
    final courseProgress = json['course_progress'] as Map<String, dynamic>? ?? {};
    return LessonProgressUpdateResult(
      lessonProgress: progress,
      coursePercentOverall: _parseOptionalInt(courseProgress['percent_overall']),
      coursePercentVideo: _parseOptionalInt(courseProgress['percent_video']),
      lastLessonId: _parseOptionalInt(courseProgress['last_lesson_id']),
    );
  }
}

int? _parseOptionalInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString());
}
