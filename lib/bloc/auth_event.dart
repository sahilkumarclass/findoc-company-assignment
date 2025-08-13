import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmailChanged extends AuthEvent {
  final String email;
  EmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class PasswordChanged extends AuthEvent {
  final String password;
  PasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class LoginRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {}

class ToggleAuthMode extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}
