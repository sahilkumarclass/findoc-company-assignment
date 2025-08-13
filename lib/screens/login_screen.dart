import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.isSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
          if (state.isFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Invalid credentials")));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return TextField(
                    onChanged: (value) =>
                        context.read<LoginBloc>().add(EmailChanged(value)),
                    decoration: InputDecoration(
                      labelText: "Email",
                      errorText: state.isEmailValid ? null : "Invalid email",
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return TextField(
                    obscureText: true,
                    onChanged: (value) =>
                        context.read<LoginBloc>().add(PasswordChanged(value)),
                    decoration: InputDecoration(
                      labelText: "Password",
                      errorText:
                      state.isPasswordValid ? null : "Weak password",
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return state.isSubmitting
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () {
                      context.read<LoginBloc>().add(LoginSubmitted());
                    },
                    child: const Text("Login"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
