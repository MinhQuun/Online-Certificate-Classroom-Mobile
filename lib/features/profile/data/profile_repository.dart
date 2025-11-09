import 'models/profile.dart';
import 'models/progress_overview.dart';
import 'profile_api.dart';

class ProfileRepository {
  ProfileRepository({ProfileApi? api}) : _api = api ?? ProfileApi();

  final ProfileApi _api;

  Future<Profile> fetchProfile() async {
    final json = await _api.fetchProfile();
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final student = json['student'] as Map<String, dynamic>? ?? const {};
    final merged = {
      ...student,
      ...user,
      'full_name': user['full_name'] ?? student['full_name'],
      'email': user['email'],
      'phone': user['phone'],
      'date_of_birth': student['date_of_birth'] ?? user['date_of_birth'],
    };
    return Profile.fromJson(merged);
  }

  Future<Profile> updateProfile(ProfileUpdateInput input) async {
    final json = await _api.updateProfile(input.toJson());
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final student = json['student'] as Map<String, dynamic>? ?? const {};
    final merged = {
      ...student,
      ...user,
      'full_name': user['full_name'] ?? student['full_name'],
      'email': user['email'],
      'phone': user['phone'],
      'date_of_birth': student['date_of_birth'] ?? user['date_of_birth'],
    };
    return Profile.fromJson(merged);
  }

  Future<ProgressOverview?> fetchProgressOverview() async {
    final json = await _api.fetchProgressOverview();
    if (json.isEmpty) return null;
    return ProgressOverview.fromJson(json);
  }
}
