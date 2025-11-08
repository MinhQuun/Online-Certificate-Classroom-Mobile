import 'package:flutter/foundation.dart';

import '../../data/auth_repository.dart';
import '../../data/models/auth_user.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  AuthUser? _user;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  AuthUser? get user => _user;

  /// Placeholder for reading persisted credentials later.
  Future<void> bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _repository.login(email: email, password: password);
      _user = user;
      _isLoggedIn = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }
}
