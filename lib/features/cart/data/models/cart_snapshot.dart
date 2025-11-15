class CartSnapshot {
  const CartSnapshot({
    required this.courses,
    required this.combos,
    required this.counts,
    required this.totals,
  });

  final List<CartCourseItem> courses;
  final List<CartComboItem> combos;
  final CartCounts counts;
  final CartTotals totals;

  bool get isEmpty => counts.total == 0;

  Set<int> get courseIds => courses.map((e) => e.id).toSet();
  Set<int> get comboIds => combos.map((e) => e.id).toSet();

  factory CartSnapshot.fromJson(Map<String, dynamic> json) {
    return CartSnapshot(
      courses:
          (json['courses'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(CartCourseItem.fromJson)
              .toList(),
      combos:
          (json['combos'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(CartComboItem.fromJson)
              .toList(),
      counts: CartCounts.fromJson(
        json['counts'] as Map<String, dynamic>? ?? const {},
      ),
      totals: CartTotals.fromJson(
        json['totals'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  static CartSnapshot empty() {
    return CartSnapshot(
      courses: const [],
      combos: const [],
      counts: const CartCounts(courses: 0, combos: 0, total: 0),
      totals: const CartTotals(courses: 0, combos: 0, grand: 0),
    );
  }
}

class CartCourseItem {
  const CartCourseItem({
    required this.id,
    required this.title,
    this.slug,
    this.price = 0,
    this.coverImage,
    this.teacher,
  });

  final int id;
  final String title;
  final String? slug;
  final int price;
  final String? coverImage;
  final String? teacher;

  factory CartCourseItem.fromJson(Map<String, dynamic> json) {
    return CartCourseItem(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Khóa học',
      slug: json['slug']?.toString(),
      price: _parseInt(json['price']),
      coverImage: json['cover_image']?.toString(),
      teacher: json['teacher']?.toString(),
    );
  }
}

class CartComboItem {
  const CartComboItem({
    required this.id,
    required this.title,
    this.slug,
    this.price = 0,
    this.originalPrice,
    this.coverImage,
    this.courseCount,
  });

  final int id;
  final String title;
  final String? slug;
  final int price;
  final int? originalPrice;
  final String? coverImage;
  final int? courseCount;

  factory CartComboItem.fromJson(Map<String, dynamic> json) {
    return CartComboItem(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Combo',
      slug: json['slug']?.toString(),
      price: _parseInt(json['price']),
      originalPrice:
          json['original_price'] == null
              ? null
              : _parseInt(json['original_price']),
      coverImage: json['cover_image']?.toString(),
      courseCount: _parseInt(json['course_count']),
    );
  }
}

class CartCounts {
  const CartCounts({
    required this.courses,
    required this.combos,
    required this.total,
  });

  final int courses;
  final int combos;
  final int total;

  factory CartCounts.fromJson(Map<String, dynamic> json) {
    return CartCounts(
      courses: _parseInt(json['courses']),
      combos: _parseInt(json['combos']),
      total: _parseInt(json['total']),
    );
  }
}

class CartTotals {
  const CartTotals({
    required this.courses,
    required this.combos,
    required this.grand,
  });

  final int courses;
  final int combos;
  final int grand;

  factory CartTotals.fromJson(Map<String, dynamic> json) {
    return CartTotals(
      courses: _parseInt(json['courses']),
      combos: _parseInt(json['combos']),
      grand: _parseInt(json['grand']),
    );
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}
