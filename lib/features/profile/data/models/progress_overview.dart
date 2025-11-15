class ProgressOverview {
  const ProgressOverview({
    required this.totalCourses,
    required this.averageProgress,
    required this.totalLearningHours,
    required this.courses,
  });

  final int totalCourses;
  final int? averageProgress;
  final double totalLearningHours;
  final List<CourseProgressSnapshot> courses;

  factory ProgressOverview.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? const {};
    final coursesJson = json['courses'] as List<dynamic>? ?? const [];
    return ProgressOverview(
      totalCourses: _parseInt(summary['total_courses']),
      averageProgress:
          summary['average_progress'] == null
              ? null
              : _parseInt(summary['average_progress']),
      totalLearningHours: _parseDouble(summary['total_learning_hours']) ?? 0,
      courses:
          coursesJson
              .whereType<Map<String, dynamic>>()
              .map(CourseProgressSnapshot.fromJson)
              .toList(),
    );
  }
}

class CourseProgressSnapshot {
  const CourseProgressSnapshot({
    required this.courseId,
    required this.title,
    this.slug,
    this.coverImage,
    this.categoryName,
    this.teacherName,
    required this.overallPercent,
    this.videoPercent,
    required this.lessonsDone,
    required this.lessonsTotal,
    this.bestMiniTestScore,
    this.lastLessonTitle,
    required this.status,
  });

  final int courseId;
  final String title;
  final String? slug;
  final String? coverImage;
  final String? categoryName;
  final String? teacherName;
  final int overallPercent;
  final int? videoPercent;
  final int lessonsDone;
  final int lessonsTotal;
  final double? bestMiniTestScore;
  final String? lastLessonTitle;
  final String status;

  factory CourseProgressSnapshot.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>? ?? const {};
    final metrics = json['metrics'] as Map<String, dynamic>? ?? const {};
    final progress = json['progress'] as Map<String, dynamic>? ?? const {};
    final category = course['category'] as Map<String, dynamic>?;
    final teacher = course['teacher'] as Map<String, dynamic>?;
    final lastLesson =
        progress['last_lesson'] as Map<String, dynamic>? ?? const {};

    return CourseProgressSnapshot(
      courseId: _parseInt(course['id']),
      title: course['title']?.toString() ?? 'Khóa học',
      slug: course['slug']?.toString(),
      coverImage: course['cover']?.toString(),
      categoryName: category?['name']?.toString(),
      teacherName: teacher?['name']?.toString(),
      overallPercent: _parseInt(metrics['overall_percent']),
      videoPercent:
          metrics['video_percent'] == null
              ? null
              : _parseInt(metrics['video_percent']),
      lessonsDone: _parseInt(metrics['lessons_done']),
      lessonsTotal: _parseInt(metrics['lessons_total']),
      bestMiniTestScore: _parseDouble(metrics['best_minitest_score']),
      lastLessonTitle: lastLesson['title']?.toString(),
      status: progress['status']?.toString() ?? 'PENDING',
    );
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}
