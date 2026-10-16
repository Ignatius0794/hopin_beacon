import 'package:injectable/injectable.dart';

import 'package:sandbox/features/auth/data/models/app_user_model.dart';

@injectable
class AuthLocalDataSource {
  Future<AppUserModel> login({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    return AppUserModel(
      username: normalizedUsername,
      type: normalizedUsername.toLowerCase() == 'admin' ? 'admin' : 'member',
    );
  }
}
