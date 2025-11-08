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

  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    final priceJson = json['price'];
    return CourseSummary(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Khoa hoc',
      slug: json['slug']?.toString(),
      coverImage:
          json['cover_image']?.toString() ??
          json['thumbnail']?.toString() ??
          json['image']?.toString(),
      shortDescription: json['short_description']?.toString(),
      price:
          priceJson is Map<String, dynamic> ? CoursePrice.fromJson(priceJson) : null,
      lessonsCount: _parseInt(json['lessons_count']),
      teacherName: json['teacher']?['name']?.toString(),
      categoryName: json['category']?['name']?.toString(),
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
  });

  final int id;
  final String title;
  final String? description;
  final String? coverImage;
  final CoursePrice? price;
  final String? categoryName;
  final String? teacherName;
  final List<CourseChapter> chapters;

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Khoa hoc',
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
      title: json['title']?.toString() ?? 'Chuong',
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
      title: json['title']?.toString() ?? 'Bai hoc',
      order: _parseInt(json['order']),
      type: json['type']?.toString(),
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
