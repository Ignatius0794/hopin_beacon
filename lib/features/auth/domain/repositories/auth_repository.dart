import 'package:dartz/dartz.dart';

import 'package:sandbox/core/exceptions/failures.dart';
import 'package:sandbox/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> login({
    required String username,
    required String password,
  });
}
