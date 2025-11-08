import 'package:cert_classroom_mobile/features/auth/data/models/auth_user.dart';

import 'profile_api.dart';

class ProfileRepository {
  ProfileRepository({ProfileApi? api}) : _api = api ?? ProfileApi();

  final ProfileApi _api;

  Future<AuthUser> fetchProfile() => _api.fetchCurrentUser();
}
