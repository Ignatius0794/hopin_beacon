import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:sandbox/core/exceptions/failures.dart';
import 'package:sandbox/core/usecases/use_case.dart';
import 'package:sandbox/features/auth/domain/entities/app_user.dart';
import 'package:sandbox/features/auth/domain/repositories/auth_repository.dart';

@injectable
class Login implements UseCase<AppUser, LoginParams> {
  const Login(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(LoginParams params) =>
      _repository.login(username: params.username, password: params.password);
}

class LoginParams extends Equatable {
  const LoginParams({required this.username, required this.password});

  final String username;
  final String password;

  @override
  List<Object> get props => [username, password];
}
