class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.role,
    this.avatarUrl,
    this.metadata,
  });

  final String id;
  final String fullName;
  final String email;
  final String? role;
  final String? avatarUrl;
  final Map<String, dynamic>? metadata;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      fullName:
          json['full_name']?.toString() ??
          json['name']?.toString() ??
          'Sinh vien',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString(),
      avatarUrl: json['avatar']?.toString(),
      metadata: json['student'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['student'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'role': role,
    'avatar': avatarUrl,
    if (metadata != null) 'student': metadata,
  };
}
