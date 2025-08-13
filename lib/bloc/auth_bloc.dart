import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthBloc() : super(AuthState.initial()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<ToggleAuthMode>(_onToggleAuthMode);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  void _onEmailChanged(EmailChanged event, Emitter<AuthState> emit) {
    final emailValid = _isValidEmail(event.email);
    emit(state.copyWith(
      email: event.email,
      isEmailValid: emailValid,
      errorMessage: null,
    ));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    final passwordValid = _isValidPassword(event.password);
    emit(state.copyWith(
      password: event.password,
      isPasswordValid: passwordValid,
      errorMessage: null,
    ));
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    if (!_validateInputs()) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Please enter valid email and password',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: state.email.trim(),
        password: state.password,
      );
      if (result.user != null) {
        emit(state.copyWith(status: AuthStatus.success));
      } else {
        emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Login failed'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e.code);
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'An unexpected error occurred',
      ));
    }
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    if (!_validateInputs()) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Please enter valid email and password',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: state.email.trim(),
        password: state.password,
      );
      if (result.user != null) {
        emit(state.copyWith(status: AuthStatus.success));
      } else {
        emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Registration failed'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e.code);
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'An unexpected error occurred',
      ));
    }
  }

  void _onToggleAuthMode(ToggleAuthMode event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      isLoginMode: !state.isLoginMode,
      status: AuthStatus.initial,
      errorMessage: null,
    ));
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _firebaseAuth.signOut();
      emit(AuthState.initial());
    } catch (e) {
      // Handle logout error if needed
    }
  }

  void _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(state.copyWith(status: AuthStatus.initial));
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
      emit(state.copyWith(status: AuthStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: _getErrorMessage(e.code)));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Google sign-in failed'));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$')
        .hasMatch(password);
  }

  bool _validateInputs() {
    return state.isEmailValid &&
        state.isPasswordValid &&
        state.email.trim().isNotEmpty &&
        state.password.isNotEmpty;
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}
