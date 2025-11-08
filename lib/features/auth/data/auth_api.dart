import 'models/auth_user.dart';

/// Placeholder remote data source for the authentication flow.
class AuthApi {
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return AuthUser(
      id: 'fake-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Sinh vien Minh Quan',
      email: email,
      avatarUrl:
          'https://avatars.githubusercontent.com/u/9919?s=280&v=4',
    );
  }
}
