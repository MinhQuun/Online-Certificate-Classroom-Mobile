class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.dateOfBirth,
  });

  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final DateTime? dateOfBirth;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: _parseInt(json['id']),
      fullName: json['full_name']?.toString() ?? 'Sinh viên',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      dateOfBirth: _parseDate(json['date_of_birth']),
    );
  }
}

class ProfileUpdateInput {
  ProfileUpdateInput({
    required this.fullName,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.currentPassword,
    this.newPassword,
    this.confirmPassword,
  });

  final String fullName;
  final String email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? currentPassword;
  final String? newPassword;
  final String? confirmPassword;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth == null
          ? null
          : '${dateOfBirth!.year.toString().padLeft(4, '0')}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}',
    }..removeWhere(
        (key, value) => value == null || (value is String && value.isEmpty),
      );

    if ((newPassword ?? '').isNotEmpty) {
      payload['current_password'] = currentPassword;
      payload['new_password'] = newPassword;
      payload['new_password_confirmation'] = confirmPassword ?? newPassword;
    }
    return payload;
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
