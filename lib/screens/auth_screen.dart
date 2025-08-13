import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Findoc Financial'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state.status == AuthStatus.failure) {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(state.errorMessage ?? 'Authentication Failed'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    state.isLoginMode ? 'Welcome Back!' : 'Create Account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    onChanged: (email) =>
                        context.read<AuthBloc>().add(EmailChanged(email)),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: state.email.isNotEmpty && !state.isEmailValid
                          ? 'Please enter a valid email address'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    onChanged: (password) =>
                        context.read<AuthBloc>().add(PasswordChanged(password)),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: state.password.isNotEmpty && !state.isPasswordValid
                          ? 'Password must be at least 8 characters with uppercase, lowercase, number & symbol'
                          : null,
                      helperText: state.isLoginMode
                          ? null
                          : 'Min 8 chars, uppercase, lowercase, number & symbol',
                      helperMaxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 30),
                   SizedBox(
                    height: 50,
                    child: state.status == AuthStatus.loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: () {
                        if (state.isLoginMode) {
                          context.read<AuthBloc>().add(LoginRequested());
                        } else {
                          context.read<AuthBloc>().add(RegisterRequested());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        state.isLoginMode ? 'Login' : 'Register',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: state.status == AuthStatus.loading
                          ? null
                          : () => context
                              .read<AuthBloc>()
                              .add(GoogleSignInRequested()),
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(ToggleAuthMode());
                      _emailController.clear();
                      _passwordController.clear();
                    },
                    child: Text(
                      state.isLoginMode
                          ? 'Don\'t have an account? Create one'
                          : 'Already have an account? Login',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
