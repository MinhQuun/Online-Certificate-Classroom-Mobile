import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';

class CourseCombo {
  const CourseCombo({
    required this.id,
    required this.name,
    this.description,
    this.coverImage,
    this.price,
    this.coursesCount,
    this.promotion,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String? description;
  final String? coverImage;
  final ComboPrice? price;
  final int? coursesCount;
  final CoursePromotion? promotion;
  final bool isActive;

  factory CourseCombo.fromJson(Map<String, dynamic> json) {
    return CourseCombo(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? 'Combo',
      description: json['description']?.toString(),
      coverImage: json['cover_image']?.toString(),
      price:
          json['price'] is Map<String, dynamic>
              ? ComboPrice.fromJson(json['price'] as Map<String, dynamic>)
              : null,
      coursesCount: _parseInt(json['courses_count']),
      promotion:
          json['promotion'] is Map<String, dynamic>
              ? CoursePromotion.fromJson(
                json['promotion'] as Map<String, dynamic>,
              )
              : null,
      isActive: json['active'] == true,
    );
  }
}

class ComboPrice {
  const ComboPrice({
    this.original,
    this.sale,
    this.saving,
    this.savingPercent,
    this.currency,
  });

  final double? original;
  final double? sale;
  final double? saving;
  final double? savingPercent;
  final String? currency;

  factory ComboPrice.fromJson(Map<String, dynamic> json) {
    return ComboPrice(
      original: _parseDouble(json['original']),
      sale: _parseDouble(json['sale']),
      saving: _parseDouble(json['saving']),
      savingPercent: _parseDouble(json['saving_percent']),
      currency: json['currency']?.toString(),
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
