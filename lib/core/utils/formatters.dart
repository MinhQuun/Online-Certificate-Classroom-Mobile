import 'package:intl/intl.dart';

String formatCurrency(
  num? value, {
  String currency = 'VND',
  bool compact = false,
}) {
  if (value == null) return 'Liên hệ';
  final formatter = NumberFormat.currency(
    locale: 'vi_VN',
    decimalDigits: 0,
    name: currency,
    symbol: currency == 'VND' ? '₫' : '$currency ',
  );
  final formatted = formatter.format(value);
  if (!compact) return formatted;
  if (formatted.endsWith('.00')) {
    return formatted.replaceAll('.00', '');
  }
  return formatted;
}

String formatDecimal(num? value) {
  if (value == null) return '--';
  final formatter = NumberFormat.decimalPattern('vi_VN');
  return formatter.format(value);
}

String? formatDateLabel(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  try {
    final dt = DateTime.parse(iso);
    return DateFormat('dd/MM/yyyy').format(dt);
  } catch (_) {
    return null;
  }
}
