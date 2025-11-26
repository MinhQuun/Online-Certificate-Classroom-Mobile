class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.code,
    required this.status,
    required this.total,
    required this.items,
    this.paymentMethod,
    this.invoiceId,
    this.note,
    this.createdAt,
    this.paidAt,
  });

  final int id;
  final String code;
  final String status;
  final int total;
  final List<OrderItem> items;
  final String? paymentMethod;
  final String? invoiceId;
  final String? note;
  final DateTime? createdAt;
  final DateTime? paidAt;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: _parseInt(json['id']),
      code: json['code']?.toString() ??
          json['invoice_id']?.toString() ??
          json['invoice_code']?.toString() ??
          '#${json['id'] ?? '--'}',
      status: json['status']?.toString().toUpperCase() ?? 'PENDING',
      total: _parseInt(
        json['total'] ??
            json['grand_total'] ??
            json['total_amount'] ??
            json['amount'] ??
            json['pay_amount'] ??
            json['paid_amount'],
      ),
      items: _parseItems(json),
      paymentMethod: json['payment_method']?.toString() ??
          json['payment_type']?.toString(),
      invoiceId: json['invoice_id']?.toString(),
      note: json['note']?.toString(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      paidAt: _parseDate(json['paid_at'] ?? json['paidAt']),
    );
  }
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    this.coverImage,
    this.quantity = 1,
  });

  final int id;
  final String title;
  final String type;
  final int price;
  final String? coverImage;
  final int quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: _parseInt(json['id'] ?? json['course_id'] ?? json['combo_id']),
      title: json['title']?.toString() ??
          json['name']?.toString() ??
          'Sản phẩm',
      type: (json['type'] ??
              json['item_type'] ??
              (json['combo_id'] != null ? 'combo' : 'course'))
          .toString(),
      price: _parseInt(
        json['price'] ??
            json['amount'] ??
            json['total'] ??
            json['line_total'] ??
            json['sale_price'],
      ),
      coverImage: json['cover_image']?.toString() ??
          json['cover']?.toString() ??
          json['thumbnail']?.toString(),
      quantity: _parseInt(json['quantity'] ?? 1),
    );
  }
}

List<OrderItem> _parseItems(Map<String, dynamic> json) {
  final sources = [
    json['items'],
    json['order_items'],
    json['details'],
  ];
  for (final source in sources) {
    if (source is List) {
      return source
          .whereType<Map<String, dynamic>>()
          .map(OrderItem.fromJson)
          .toList();
    }
  }
  return const [];
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  final raw = value.toString();
  final cleaned = raw.replaceAll(RegExp(r'[^0-9.,-]'), '');
  if (cleaned.isEmpty) return 0;
  final normalized = cleaned.replaceAll('.', '').replaceAll(',', '');
  final parsed = int.tryParse(normalized);
  if (parsed != null) return parsed;
  final asDouble = double.tryParse(cleaned.replaceAll(',', '.'));
  return asDouble?.round() ?? 0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return null;
  }
}
