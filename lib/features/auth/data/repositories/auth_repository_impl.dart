import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:sandbox/core/exceptions/failures.dart';
import 'package:sandbox/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:sandbox/features/auth/data/mappers/app_user_mapper.dart';
import 'package:sandbox/features/auth/domain/entities/app_user.dart';
import 'package:sandbox/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthLocalDataSource _dataSource;

  @override
  Future<Either<Failure, AppUser>> login({
    required String username,
    required String password,
  }) async {
    try {
      final model = await _dataSource.login(
        username: username,
        password: password,
      );
      return Right(model.toEntity());
    } catch (_) {
      return Left(AuthenticationFailure());
    }
  }
}
