class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Vui long nhap email';
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Email khong hop le';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Vui long nhap mat khau';
    if (value.length < 6) {
      return 'Mat khau phai tu 6 ky tu';
    }
    return null;
  }
}
