import 'package:cert_classroom_mobile/features/auth/data/models/auth_user.dart';

/// Placeholder profile endpoint.
class ProfileApi {
  Future<AuthUser> fetchCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const AuthUser(
      id: 'student-01',
      fullName: 'Sinh vien demo',
      email: 'student@example.com',
      avatarUrl: null,
    );
  }
}
