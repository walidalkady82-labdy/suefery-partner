import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/presentation/auth/verification_screen.dart';
import '../../data/enums/auth_status.dart';
import '../home/home_screen.dart';
import 'auth_cubit.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';
import 'store_setup_screen.dart';

class AuthWrapper extends StatelessWidget{
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;

        // 1. Loading Check
        if (state.authState == AuthStatus.inProgress || (state.isLoading && user == null)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Awaiting Verification Check
        if (state.authState == AuthStatus.awaitingVerification) {
          // Ensure we have an email to show on the verification screen.
          return VerificationScreen(email: user?.email ?? 'your email');
        }

        // 3. Authenticated Check
        if (state.authState == AuthStatus.authenticated && user != null) {
          // If authenticated, but setup isn't done -> Go to Setup
          if (!user.isSetupComplete) {
            return const StoreSetupScreen();
          }
          // Otherwise -> Go Home
          return const HomeScreen();
        }

        // 4. Unauthenticated -> Show Login or Signup
        if (state.isLogin) {
          return const LoginScreen();
        }
        return const SignUpScreen();
      }
    );
  }
}