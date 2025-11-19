import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/data/enums/auth_status.dart';
import 'package:suefery_partner/data/models/user_model.dart';
import 'package:suefery_partner/data/services/auth_service.dart';
import 'package:suefery_partner/data/services/logging_service.dart';
import 'package:suefery_partner/locator.dart';
import '../../data/enums/user_role.dart';
import '../../data/services/user_service.dart';

final _log = LoggerRepo('LoginState');

class AuthState {
  final bool isLoading;
  final String errorMessage;
  final String email;
  final String password;
  final String confirmPassword;
  final AutovalidateMode autovalidateMode;
  final bool obscureText;
  final bool isLogin;
  final AuthStatus authState;
  final UserModel? user;
  
  const AuthState({
    this.isLoading = false,
    this.errorMessage = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.autovalidateMode = AutovalidateMode.disabled,
    this.obscureText = true,
    this.isLogin = true,
    this.authState = AuthStatus.inProgress,
    this.user,
    });
  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? email,
    String? password,
    String? confirmPassword,
    AutovalidateMode? autovalidateMode,
    bool? obscureText,
    bool? isLogin,
    AuthStatus? authState,
    UserModel? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,      
      errorMessage: errorMessage ?? this.errorMessage, 
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      obscureText: obscureText ?? this.obscureText,
      isLogin: isLogin ?? this.isLogin,
      authState: authState ?? this.authState,
      user: user ?? this.user,
    );
  }

}

class AuthCubit extends Cubit<AuthState> {

  final AuthService _authService = sl<AuthService>();
  late StreamSubscription<AuthStatus> _authStatusSubscription;

  late final StreamSubscription<UserModel?> authSubscription;
  User? get currentFirebaseUser => _authService.currentFirebaseUser;
  UserModel? get currentDbUser => _authService.currentAppUser;

  AuthCubit() : super(AuthState()) {
      _authStatusSubscription =
          _authService.onAuthStatusChanged().listen((authStatus) async {
        if (authStatus == AuthStatus.authenticated) {
          await _checkUserRole();
        } else {
          emit(state.copyWith(
              authState: authStatus,
              user: _authService.currentAppUser,
            ),
          );
        }
      });
    }

  Future<void> _checkUserRole() async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: '',
    ));
    if (currentFirebaseUser == null) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'User not found. Please contact support.',
        ),
      );
      return;
    }

    try {
      if (currentDbUser != null) {
        if (currentDbUser?.role == UserRole.partner) {
          emit(
            state.copyWith(
              isLoading: false,
              authState: AuthStatus.authenticated,
              user: currentDbUser,
            )
          );
        } else {
          // Not a partner, log them out
          await _authService.logOut();
          emit(
            state.copyWith(
            isLoading: false,
            errorMessage: 'This app is for partners only.'
          ));
        }
      } else {
        // User document doesn't exist, log them out
        await _authService.logOut();
        emit(state.copyWith(
            isLoading: false,
            errorMessage: 'User not found. Please contact support.'
        ));
      }
    } catch (e) {
      emit(state.copyWith(
            isLoading: false,
            errorMessage:
        e.toString()
      ));
    }
  }

  // void _onAuthStateChanged(UserModel? user) {
  //   if (user != null) {
  //     emit(state.copyWith(authState: AuthStatus.authenticated, user: user));
  //   } else {
  //     emit(state.copyWith(authState: AuthStatus.authenticated, user: null));
  //   }
  //}

  void updateLoadingState(bool loadingState){
    emit(state.copyWith(isLoading: loadingState));
  }

  void updateEmail(String? email) {
    emit(state.copyWith(email: email));
  }

  void updatePassword(String? password) {
    emit(state.copyWith(password: password));
  }

  void updateConfirmPassword(String? confirmPassword) {
    emit(state.copyWith(confirmPassword: confirmPassword));
  }

  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  void toggleObscureText() {
    final currentFormState = state;
    emit(currentFormState.copyWith(obscureText: !currentFormState.obscureText));
  }

  void reset() {
    emit(const AuthState());
  }

  void togglePage() {
    final currentFormState = state;
    emit(currentFormState.copyWith(isLogin: !currentFormState.isLogin));
  }

  Future<void> signIn() async {
    final formState = state;
    emit(formState.copyWith(isLoading: true, errorMessage: ''));

    try {
      await _authService.signInWithEmailAndPassword(
        email: formState.email.trim(),
        password: formState.password,
      );
      // On success, the auth stream will emit Authenticated state.
    } catch (e) {
      final errorMessage = e.toString();
      _log.e('Login Failed: $errorMessage');
      emit(state.copyWith(errorMessage: errorMessage, isLoading: false));
      
      // Optional: Reset error after a delay
      Future.delayed(const Duration(seconds: 5), () {
        if (state.authState== AuthStatus.unauthenticated && state.errorMessage == errorMessage) {
          emit(state.copyWith(errorMessage: ''));
        }
      });
    } finally {
      // Ensure loading is always turned off if the state is still Unauthenticated
      if (state.authState== AuthStatus.unauthenticated) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }
  
  Future<void> signInWithGoogle() async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      await _authService.signInWithGoogle();
      // On success, the auth stream will emit Authenticated state.
    } catch (e) {
      final errorMessage = e.toString();
      _log.e('Google Login Failed: $errorMessage');
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } finally {
      if (state.authState == AuthStatus.unauthenticated) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  Future<void> signUp() async{
    final formState = state;
    if (formState.password != formState.confirmPassword) {
      emit(formState.copyWith(errorMessage: 'Passwords do not match.'));
      return; 
    }
    if (formState.password.length < 6) {
      emit(formState.copyWith(errorMessage: 'Password must be at least 6 characters.'));
      return;
    }

    emit(formState.copyWith(isLoading: true, errorMessage: ''));
    try {
      await _authService.signUpWithEmailAndPassword(
        email: formState.email.trim(),
        password: formState.password,
      );
      // On success, the auth state stream will handle navigation.
    } catch (e) {
      final errorMessage = e.toString();
      _log.e('Sign Up Failed: $errorMessage');
      emit(state.copyWith(errorMessage: errorMessage));
    } finally {
      if (state.authState== AuthStatus.unauthenticated) {
        emit(state.copyWith(isLoading: false));
      }
    }
}

  Future<void> signOut() async {
    try {
      await _authService.logOut();
    } catch (e) {
      final errorMessage = 'Sign Out Failed: ${e.toString().split(':').last.trim()}';
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      _log.e(errorMessage);
    }
  }

  Future<void> checkVerificationStatus() async {
    final formState = state;
    emit(formState.copyWith(isLoading: true, errorMessage: ''));
    try {
      await _authService.reloadUser();
      // Listener will catch the verified state and transition to AuthAuthenticated
    } catch (e) {
      final errorMessage = 'Sign Out Failed: ${e.toString().split(':').last.trim()}';
      emit(formState.copyWith(isLoading: false, errorMessage: errorMessage));
      _log.e(errorMessage);
    }
  }

  Future<void> sendEmailVerification() async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      await _authService.sendEmailVerification();
      // Listener will catch the verified state and transition to AuthAuthenticated
    } catch (e) {
      final errorMessage = 'Verification Email Failed: ${e.toString().split(':').last.trim()}';
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
      _log.e(errorMessage);
    }
  }
  
  Future<void> logOut() async {
    try {
      await _authService.logOut();
    }catch (e){
      final errorMessage = 'Verification Email Failed: ${e.toString().split(':').last.trim()}';
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
      _log.e(errorMessage);
    }
  }
  
  @override
  Future<void> close() {
    _authStatusSubscription.cancel();
    // NEW: Stop the keep-alive timer on Cubit close
    _authService.stopKeepAlive();
    return super.close();
  }

}