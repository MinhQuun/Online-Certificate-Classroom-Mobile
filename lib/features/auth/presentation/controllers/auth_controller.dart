import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:cert_classroom_mobile/core/network/api_exceptions.dart';
import 'package:cert_classroom_mobile/features/auth/data/auth_repository.dart';
import 'package:cert_classroom_mobile/features/auth/data/models/auth_user.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool _isLoading = false;
  AuthUser? _user;
  String? _token;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  AuthUser? get user => _user;
  bool get isLoggedIn =>
      _user != null && (_token != null && _token!.isNotEmpty);
  String? get errorMessage => _errorMessage;

  Future<bool> bootstrap() async {
    _setLoading(true);
    _errorMessage = null;
    bool success = false;
    try {
      final token = await _repository.getToken();
      if (token == null) {
        _user = null;
        _token = null;
        return false;
      }
      final currentUser = await _repository.loadCurrentUser();
      if (currentUser != null) {
        _user = currentUser;
        _token = token;
        success = true;
      } else {
        await _repository.clearToken();
        _user = null;
        _token = null;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      await _repository.clearToken();
      _user = null;
      _token = null;
    } catch (_) {
      _errorMessage = 'Không thể xác thực. Vui lòng đăng nhập lại.';
      await _repository.clearToken();
      _user = null;
      _token = null;
    } finally {
      _setLoading(false);
    }
    return success;
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final loggedInUser = await _repository.login(
        email: email,
        password: password,
      );
      _user = loggedInUser;
      _token = await _repository.getToken();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Đăng nhập thất bại, vui lòng thử lại.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _repository.logout();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _user = null;
      _token = null;
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    _notifySafely();
  }

  void _notifySafely() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}