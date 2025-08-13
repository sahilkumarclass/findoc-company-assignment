import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  final String email;
  final String password;
  final bool isEmailValid;
  final bool isPasswordValid;
  final AuthStatus status;
  final bool isLoginMode;
  final String? errorMessage;

  const AuthState({
    required this.email,
    required this.password,
    required this.isEmailValid,
    required this.isPasswordValid,
    required this.status,
    required this.isLoginMode,
    this.errorMessage,
  });

  factory AuthState.initial() {
    return const AuthState(
      email: '',
      password: '',
      isEmailValid: true,
      isPasswordValid: true,
      status: AuthStatus.initial,
      isLoginMode: true,
      errorMessage: null,
    );
  }

  AuthState copyWith({
    String? email,
    String? password,
    bool? isEmailValid,
    bool? isPasswordValid,
    AuthStatus? status,
    bool? isLoginMode,
    String? errorMessage,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      status: status ?? this.status,
      isLoginMode: isLoginMode ?? this.isLoginMode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    isEmailValid,
    isPasswordValid,
    status,
    isLoginMode,
    errorMessage
  ];
}