class CheckoutPreview {
  const CheckoutPreview({
    required this.courses,
    required this.combos,
    required this.courseTotal,
    required this.comboTotal,
    required this.total,
  });

  final List<CheckoutLineItem> courses;
  final List<CheckoutLineItem> combos;
  final int courseTotal;
  final int comboTotal;
  final int total;

  factory CheckoutPreview.fromJson(Map<String, dynamic> json) {
    return CheckoutPreview(
      courses:
          (json['courses'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(CheckoutLineItem.fromJson)
              .toList(),
      combos:
          (json['combos'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(CheckoutLineItem.fromJson)
              .toList(),
      courseTotal: _parseInt(json['course_total']),
      comboTotal: _parseInt(json['combo_total']),
      total: _parseInt(json['total']),
    );
  }
}

class CheckoutResult extends CheckoutPreview {
  CheckoutResult({
    required super.courses,
    required super.combos,
    required super.courseTotal,
    required super.comboTotal,
    required super.total,
    required this.paymentMethod,
    this.invoiceId,
    this.pendingActivationCourses = const [],
    this.pendingActivationCombos = const [],
    this.alreadyActiveCourses = const [],
  });

  final String paymentMethod;
  final String? invoiceId;
  final List<int> pendingActivationCourses;
  final List<int> pendingActivationCombos;
  final List<int> alreadyActiveCourses;

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    return CheckoutResult(
      courses:
          (json['courses'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(CheckoutLineItem.fromJson)
              .toList(),
      combos:
          (json['combos'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(CheckoutLineItem.fromJson)
              .toList(),
      courseTotal: _parseInt(json['course_total']),
      comboTotal: _parseInt(json['combo_total']),
      total: _parseInt(json['total']),
      paymentMethod: json['payment_method']?.toString() ?? 'qr',
      invoiceId: json['invoice_id']?.toString(),
      pendingActivationCourses:
          (json['pending_activation_courses'] as List<dynamic>? ?? [])
              .map(_parseInt)
              .toList(),
      pendingActivationCombos:
          (json['pending_activation_combos'] as List<dynamic>? ?? [])
              .map(_parseInt)
              .toList(),
      alreadyActiveCourses:
          (json['already_active_courses'] as List<dynamic>? ?? [])
              .map(_parseInt)
              .toList(),
    );
  }
}

class CheckoutLineItem {
  const CheckoutLineItem({
    required this.id,
    required this.title,
    this.slug,
    this.cover,
    this.price = 0,
  });

  final int id;
  final String title;
  final String? slug;
  final String? cover;
  final int price;

  factory CheckoutLineItem.fromJson(Map<String, dynamic> json) {
    return CheckoutLineItem(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? 'Sản phẩm',
      slug: json['slug']?.toString(),
      cover: json['cover_image']?.toString() ?? json['cover']?.toString(),
      price: _parseInt(json['price']),
    );
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}
