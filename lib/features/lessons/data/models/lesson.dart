class LessonDetail {
  const LessonDetail({
    required this.lesson,
    this.course,
    this.chapter,
    this.materials = const [],
    this.miniTests = const [],
    this.progress,
    this.permissions,
  });

  final LessonInfo lesson;
  final LessonCourse? course;
  final LessonChapter? chapter;
  final List<LessonMaterial> materials;
  final List<LessonMiniTest> miniTests;
  final LessonProgress? progress;
  final LessonPermissions? permissions;

  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    return LessonDetail(
      lesson: LessonInfo.fromJson(
        json['lesson'] as Map<String, dynamic>? ?? const {},
      ),
      course:
          json['course'] is Map<String, dynamic>
              ? LessonCourse.fromJson(json['course'] as Map<String, dynamic>)
              : null,
      chapter:
          json['chapter'] is Map<String, dynamic>
              ? LessonChapter.fromJson(json['chapter'] as Map<String, dynamic>)
              : null,
      materials:
          (json['materials'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(LessonMaterial.fromJson)
              .toList(),
      miniTests:
          (json['mini_tests'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(LessonMiniTest.fromJson)
              .toList(),
      progress:
          json['progress'] is Map<String, dynamic>
              ? LessonProgress.fromJson(json['progress'] as Map<String, dynamic>)
              : null,
      permissions:
          json['permissions'] is Map<String, dynamic>
              ? LessonPermissions.fromJson(
                json['permissions'] as Map<String, dynamic>,
              )
              : null,
    );
  }
}

class LessonInfo {
  const LessonInfo({
    required this.id,
    required this.title,
    this.description,
    this.order,
    this.type,
  });

  final int id;
  final String title;
  final String? description;
  final int? order;
  final String? type;

  factory LessonInfo.fromJson(Map<String, dynamic> json) {
    return LessonInfo(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Bài học',
      description: json['description']?.toString(),
      order: _parseInt(json['order']),
      type: json['type']?.toString(),
    );
  }
}

class LessonCourse {
  const LessonCourse({
    required this.id,
    required this.title,
    this.coverImage,
    this.lessonsTotal,
    this.teacherName,
    this.categoryName,
  });

  final int id;
  final String title;
  final String? coverImage;
  final int? lessonsTotal;
  final String? teacherName;
  final String? categoryName;

  factory LessonCourse.fromJson(Map<String, dynamic> json) {
    return LessonCourse(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Khóa học',
      coverImage: json['cover_image']?.toString(),
      lessonsTotal: _parseInt(json['lessons_total']),
      teacherName: json['teacher']?['name']?.toString(),
      categoryName: json['category']?['name']?.toString(),
    );
  }
}

class LessonChapter {
  const LessonChapter({
    required this.id,
    required this.title,
    this.lessonsCount,
  });

  final int id;
  final String title;
  final int? lessonsCount;

  factory LessonChapter.fromJson(Map<String, dynamic> json) {
    return LessonChapter(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Chương',
      lessonsCount: _parseInt(json['lessons_count']),
    );
  }
}

class LessonMaterial {
  const LessonMaterial({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    this.size,
    this.description,
    this.mimeType,
  });

  final int id;
  final String title;
  final String type;
  final String url;
  final String? size;
  final String? description;
  final String? mimeType;

  factory LessonMaterial.fromJson(Map<String, dynamic> json) {
    return LessonMaterial(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Tài liệu',
      type: json['type']?.toString() ?? 'file',
      url:
          json['download_url']?.toString() ??
          json['url']?.toString() ??
          json['link']?.toString() ??
          '',
      size: json['size']?.toString(),
      description: json['description']?.toString(),
      mimeType: json['mime_type']?.toString(),
    );
  }
}

class LessonMiniTest {
  const LessonMiniTest({
    required this.id,
    required this.title,
    this.order,
    this.skill,
    this.timeLimit,
    this.attemptsAllowed,
    this.bestScore,
    this.attemptsUsed,
  });

  final int id;
  final String title;
  final int? order;
  final String? skill;
  final int? timeLimit;
  final int? attemptsAllowed;
  final double? bestScore;
  final int? attemptsUsed;

  factory LessonMiniTest.fromJson(Map<String, dynamic> json) {
    return LessonMiniTest(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Mini test',
      order: _parseInt(json['order']),
      skill: json['skill']?.toString(),
      timeLimit: _parseInt(json['time_limit']),
      attemptsAllowed: _parseInt(json['attempts_allowed']),
      bestScore: _parseDouble(json['best_score']),
      attemptsUsed: _parseInt(json['attempts_used']),
    );
  }
}

class LessonProgress {
  const LessonProgress({
    required this.status,
    this.totalViewSeconds,
    this.videoProgressSeconds,
    this.videoDurationSeconds,
    this.watchCount,
    this.lastViewedAt,
    this.completedAt,
    this.note,
  });

  final String status;
  final int? totalViewSeconds;
  final int? videoProgressSeconds;
  final int? videoDurationSeconds;
  final int? watchCount;
  final String? lastViewedAt;
  final String? completedAt;
  final String? note;

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      status: json['status']?.toString() ?? 'NOT_STARTED',
      totalViewSeconds: _parseInt(json['total_view_seconds']),
      videoProgressSeconds: _parseInt(json['video_progress_seconds']),
      videoDurationSeconds: _parseInt(json['video_duration_seconds']),
      watchCount: _parseInt(json['watch_count']),
      lastViewedAt: json['last_viewed_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      note: json['note']?.toString(),
    );
  }
}

class LessonPermissions {
  const LessonPermissions({
    this.isEnrolled,
    this.canAccess,
    this.isPreview,
    this.discussionsTotal,
  });

  final bool? isEnrolled;
  final bool? canAccess;
  final bool? isPreview;
  final int? discussionsTotal;

  factory LessonPermissions.fromJson(Map<String, dynamic> json) {
    return LessonPermissions(
      isEnrolled: json['is_enrolled'] as bool?,
      canAccess: json['can_access'] as bool?,
      isPreview: json['is_preview'] as bool?,
      discussionsTotal: _parseInt(json['discussions_total']),
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
