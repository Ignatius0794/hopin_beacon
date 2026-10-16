import 'package:sandbox/features/auth/data/models/app_user_model.dart';
import 'package:sandbox/features/auth/domain/entities/app_user.dart';

extension AppUserMapper on AppUserModel {
  AppUser toEntity() => AppUser(
        username: username,
        type: type == 'admin' ? UserType.admin : UserType.member,
      );
}
