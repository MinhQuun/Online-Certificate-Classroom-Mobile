import 'auth_api.dart';
import 'models/auth_user.dart';

class AuthRepository {
  AuthRepository({AuthApi? api}) : _api = api ?? AuthApi();

  final AuthApi _api;

  Future<AuthUser> login({required String email, required String password}) {
    return _api.login(email: email, password: password);
  }
}
