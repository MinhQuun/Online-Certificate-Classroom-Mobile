enum CourseUserState { addable, inCart, activated }

class CourseSummary {
  const CourseSummary({
    required this.id,
    required this.title,
    this.slug,
    this.coverImage,
    this.shortDescription,
    this.price,
    this.lessonsCount,
    this.teacherName,
    this.categoryName,
    this.userState = CourseUserState.addable,
  });

  final int id;
  final String title;
  final String? slug;
  final String? coverImage;
  final String? shortDescription;
  final CoursePrice? price;
  final int? lessonsCount;
  final String? teacherName;
  final String? categoryName;
  final CourseUserState userState;

  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    final priceJson = json['price'];
    return CourseSummary(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Khóa học',
      slug: json['slug']?.toString(),
      coverImage:
          json['cover_image']?.toString() ??
          json['thumbnail']?.toString() ??
          json['image']?.toString(),
      shortDescription: json['short_description']?.toString(),
      price:
          priceJson is Map<String, dynamic>
              ? CoursePrice.fromJson(priceJson)
              : null,
      lessonsCount: _parseInt(json['lessons_count']),
      teacherName: json['teacher']?['name']?.toString(),
      categoryName: json['category']?['name']?.toString(),
      userState: CourseUserState.addable,
    );
  }

  CourseSummary copyWithState(CourseUserState nextState) {
    return CourseSummary(
      id: id,
      title: title,
      slug: slug,
      coverImage: coverImage,
      shortDescription: shortDescription,
      price: price,
      lessonsCount: lessonsCount,
      teacherName: teacherName,
      categoryName: categoryName,
      userState: nextState,
    );
  }
}

class CourseDetail {
  const CourseDetail({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    this.price,
    this.categoryName,
    this.teacherName,
    this.chapters = const [],
    this.durationDays,
    this.startDate,
    this.endDate,
    this.miniTests = const [],
    this.promotion,
  });

  final int id;
  final String title;
  final String? description;
  final String? coverImage;
  final CoursePrice? price;
  final String? categoryName;
  final String? teacherName;
  final List<CourseChapter> chapters;
  final int? durationDays;
  final String? startDate;
  final String? endDate;
  final List<CourseMiniTest> miniTests;
  final CoursePromotion? promotion;

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Khóa học',
      description: json['description']?.toString(),
      coverImage:
          json['cover_image']?.toString() ??
          json['thumbnail']?.toString() ??
          json['image']?.toString(),
      price:
          json['price'] is Map<String, dynamic>
              ? CoursePrice.fromJson(json['price'] as Map<String, dynamic>)
              : null,
      categoryName: json['category']?['name']?.toString(),
      teacherName: json['teacher']?['name']?.toString(),
      chapters:
          (json['chapters'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(CourseChapter.fromJson)
              .toList(),
      durationDays: _parseInt(json['duration_days']),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      miniTests:
          (json['mini_tests'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(CourseMiniTest.fromJson)
              .toList(),
      promotion:
          json['active_promotion'] is Map<String, dynamic>
              ? CoursePromotion.fromJson(
                json['active_promotion'] as Map<String, dynamic>,
              )
              : null,
    );
  }
}

class CoursePrice {
  const CoursePrice({this.original, this.sale, this.currency, this.saving});

  final double? original;
  final double? sale;
  final String? currency;
  final double? saving;

  factory CoursePrice.fromJson(Map<String, dynamic> json) {
    return CoursePrice(
      original: _parseDouble(json['original']),
      sale: _parseDouble(json['sale']),
      currency: json['currency']?.toString(),
      saving: _parseDouble(json['saving']),
    );
  }
}

class CourseChapter {
  const CourseChapter({
    required this.id,
    required this.title,
    this.order,
    this.lessons = const [],
  });

  final int id;
  final String title;
  final int? order;
  final List<CourseLessonSummary> lessons;

  factory CourseChapter.fromJson(Map<String, dynamic> json) {
    return CourseChapter(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Chương',
      order: _parseInt(json['order']),
      lessons:
          (json['lessons'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(CourseLessonSummary.fromJson)
              .toList(),
    );
  }
}

class CourseLessonSummary {
  const CourseLessonSummary({
    required this.id,
    required this.title,
    this.order,
    this.type,
  });

  final int id;
  final String title;
  final int? order;
  final String? type;

  factory CourseLessonSummary.fromJson(Map<String, dynamic> json) {
    return CourseLessonSummary(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Bài học',
      order: _parseInt(json['order']),
      type: json['type']?.toString(),
    );
  }
}

class CourseMiniTest {
  const CourseMiniTest({
    required this.id,
    required this.title,
    this.order,
    this.skill,
    this.timeLimit,
    this.attemptsAllowed,
  });

  final int id;
  final String title;
  final int? order;
  final String? skill;
  final int? timeLimit;
  final int? attemptsAllowed;

  factory CourseMiniTest.fromJson(Map<String, dynamic> json) {
    return CourseMiniTest(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Mini test',
      order: _parseInt(json['order']),
      skill: json['skill']?.toString(),
      timeLimit: _parseInt(json['time_limit']),
      attemptsAllowed: _parseInt(json['attempts_allowed']),
    );
  }
}

class CoursePromotion {
  const CoursePromotion({
    required this.id,
    this.name,
    this.type,
    this.value,
    this.expiresAt,
  });

  final int id;
  final String? name;
  final String? type;
  final double? value;
  final String? expiresAt;

  factory CoursePromotion.fromJson(Map<String, dynamic> json) {
    return CoursePromotion(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      type: json['type']?.toString(),
      value: _parseDouble(json['value']),
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

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}
