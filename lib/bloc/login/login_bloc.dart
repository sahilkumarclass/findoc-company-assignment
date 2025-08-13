import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState.initial()) {
    on<EmailChanged>((event, emit) {
      final isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          .hasMatch(event.email);
      emit(state.copyWith(email: event.email, isEmailValid: isValidEmail));
    });

    on<PasswordChanged>((event, emit) {
      final isValidPassword = RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$')
          .hasMatch(event.password);
      emit(state.copyWith(
          password: event.password, isPasswordValid: isValidPassword));
    });

    on<LoginSubmitted>((event, emit) async {
      if (state.isEmailValid && state.isPasswordValid
          && state.email.isNotEmpty && state.password.isNotEmpty) {
        emit(state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false));

        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));

        // Assume success if email/password are valid
        emit(state.copyWith(
            isSubmitting: false, isSuccess: true, isFailure: false));
      } else {
        emit(state.copyWith(isFailure: true, isSuccess: false));
      }
    });
  }
}
