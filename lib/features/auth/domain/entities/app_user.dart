import 'package:equatable/equatable.dart';

enum UserType { member, admin }

class AppUser extends Equatable {
  const AppUser({required this.username, required this.type});

  final String username;
  final UserType type;

  @override
  List<Object> get props => [username, type];
}
