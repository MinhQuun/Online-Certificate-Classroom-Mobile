import 'package:flutter/foundation.dart';

import 'package:cert_classroom_mobile/features/profile/data/models/profile.dart';
import 'package:cert_classroom_mobile/features/profile/data/models/progress_overview.dart';
import 'package:cert_classroom_mobile/features/profile/data/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepository();

  final ProfileRepository _repository;

  bool isLoading = false;
  bool isSaving = false;
  bool isProgressLoading = false;
  String? errorMessage;
  String? successMessage;
  String? progressError;
  Profile? profile;
  ProgressOverview? progress;

  Future<void> loadProfile({bool refresh = false}) async {
    if (isLoading && !refresh) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await _repository.fetchProfile();
    } catch (e) {
      errorMessage = 'Không thể tải thông tin cá nhân';
    } finally {
      isLoading = false;
      notifyListeners();
    }
    await loadProgressOverview(refresh: refresh);
  }

  Future<bool> updateProfile(ProfileUpdateInput input) async {
    if (isSaving) return false;
    isSaving = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
    try {
      profile = await _repository.updateProfile(input);
      successMessage = 'Cập nhật thành công';
      return true;
    } catch (e) {
      errorMessage = 'Cập nhật thất bại';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> loadProgressOverview({bool refresh = false}) async {
    if (isProgressLoading && !refresh) return;
    isProgressLoading = true;
    progressError = null;
    notifyListeners();
    try {
      progress = await _repository.fetchProgressOverview();
    } catch (e) {
      progressError = 'Không thể tải tiến độ học tập';
      progress = null;
    } finally {
      isProgressLoading = false;
      notifyListeners();
    }
  }
}
