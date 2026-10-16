import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:sandbox/features/auth/domain/entities/app_user.dart';
import 'package:sandbox/features/auth/domain/usecases/login.dart';

enum AuthStatus { initial, loading, authenticated, failure }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.initial, this.user});

  final AuthStatus status;
  final AppUser? user;

  @override
  List<Object?> get props => [status, user];
}

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._login) : super(const AuthState());

  final Login _login;

  Future<bool> login(String username, String password) async {
    emit(const AuthState(status: AuthStatus.loading));
    final result = await _login(
      LoginParams(username: username, password: password),
    );
    return result.fold(
      (_) {
        emit(const AuthState(status: AuthStatus.failure));
        return false;
      },
      (user) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
        return true;
      },
    );
  }

  void logout() => emit(const AuthState());
}
