import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStatusChanged extends AuthEvent {
  final UserEntity? user;

  const AuthStatusChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLoginRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}
