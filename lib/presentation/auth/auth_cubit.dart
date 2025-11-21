import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/data/enums/auth_status.dart';
import 'package:suefery_partner/data/models/user_model.dart';
import 'package:suefery_partner/data/services/auth_service.dart';
import 'package:suefery_partner/data/services/logging_service.dart';
import 'package:suefery_partner/locator.dart';
import '../../core/utils/geohash.dart';
import '../../data/enums/partner_status.dart';
import '../../data/enums/user_role.dart';

final _log = LoggerRepo('LoginState');

class AuthState {
  final bool isLoading;
  final String errorMessage;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final AutovalidateMode autovalidateMode;
  final bool obscureText;
  final bool isLogin;
  final AuthStatus authState;
  final UserModel? user;
  
  const AuthState({
    this.isLoading = false,
    this.errorMessage = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.phone = '',
    this.autovalidateMode = AutovalidateMode.disabled,
    this.obscureText = true,
    this.isLogin = true,
    this.authState = AuthStatus.inProgress,
    this.user,
    });
  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? confirmPassword,
    String? phone,
    AutovalidateMode? autovalidateMode,
    bool? obscureText,
    bool? isLogin,
    AuthStatus? authState,
    UserModel? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,      
      errorMessage: errorMessage ?? this.errorMessage, 
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phone: phone ?? this.phone,
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
      _authStatusSubscription = _authService.onAuthStatusChanged().listen((authStatus) async {
        emit(state.copyWith( authState: authStatus));
        _log.i('onAuthStatusChanged: user is ${authStatus.name}');  
        if (authStatus == AuthStatus.authenticated) {
          _log.i('onAuthStatusChanged: user authenticated checking user role');
          await _checkUserRole();
        }
      });
    }

  Future<void> _checkUserRole() async {
    _log.i('Checking user role...');
    emit(state.copyWith(
      isLoading: true,
      errorMessage: '',
    ));
    _log.i('Current Firebase User: ${currentFirebaseUser?.uid}');
    if (currentFirebaseUser == null) {
      _log.i('user is null');
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
            errorMessage: 'This app is for partners only.', authState: AuthStatus.unauthenticated
          ));
        }
      } else {
        // User document doesn't exist, log them out
          emit(state.copyWith(
                        isLoading: false,
                        errorMessage: 'User not found. Please contact support.', authState: AuthStatus.unauthenticated
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

  void updateFirsttName(String? firstName) {
    emit(state.copyWith(firstName: firstName));
  }

  void updateLastName(String? lastName) {
    emit(state.copyWith(lastName: lastName));
  }

  void updateEmail(String? email) {
    emit(state.copyWith(email: email));
  }

  void updatePhone(String? phone) {
    emit(state.copyWith(phone: phone));
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
        firstName: formState.firstName,
        lastName: formState.lastName,
        phone: formState.phone,
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
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      await _authService.reloadUser();
      
      // Manually check the verification status after reloading.
      final firebaseUser = _authService.currentFirebaseUser;
      if (firebaseUser != null && firebaseUser.emailVerified) {
        _log.i('Verification status check: Email is now verified. Emitting authenticated.');
        // The user is now verified, emit the authenticated state to trigger navigation.
        emit(state.copyWith(authState: AuthStatus.authenticated, isLoading: false));
      } else {
        _log.i('Verification status check: Email is still not verified.');
      }
    } catch (e) {
      final errorMessage = 'Failed to check status: ${e.toString()}';
      _log.e(errorMessage);
      emit(state.copyWith(errorMessage: errorMessage, isLoading: false));
    }finally{
      // The isLoading flag is now handled within the try/catch block.
    }

  }

  Future<void> sendEmailVerification() async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      await _authService.sendEmailVerification();
      // Listener will catch the verified state and transition to AuthAuthenticated
    } catch (e) {
      final errorMessage = 'Verification Email Failed: ${e.toString().split(':').last.trim()}';
      emit(state.copyWith(errorMessage: errorMessage));
      _log.e(errorMessage);
    }finally{
            Future.delayed(const Duration(seconds: 5), () {
          emit(state.copyWith(isLoading: false,errorMessage: ''));
      });
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

  Future<void> deleteUser() async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      await _authService.deleteUser();
      // The auth stream will automatically emit unauthenticated state upon success.
    } catch (e) {
      final errorMessage = 'Failed to delete account: ${e.toString()}';
      _log.e(errorMessage);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } finally {
      // Ensure loading is always turned off if the state is still Unauthenticated
    }
  }

  
  Future<void> completeSetup({
    required String storeName, 
    required String address, 
    required String city,
    required String bio,
    required String website,
    required List<String> tags,
    required double lat,
    required double lng,
  }) async {
    if (state.user == null) return;

    emit(state.copyWith(isLoading: true));
    try {
      final newStoreId = "${storeName.toLowerCase().replaceAll(' ', '_')}_${state.user!.id.substring(0,4)}";
      final geohash = GeohashUtils.encode(lat, lng);

      await _authService.updateUser(state.user!.id,
        storeId : newStoreId,
        address : address,
        city: city,
        bio: bio,
        website: website,
        tags: tags,
        lat: lat,
        lng : lng,
        creationTimestamp: DateTime.now(),
        geohash: geohash,
        partnerStatus: PartnerStatus.active, 
      );

    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: "Setup failed: $e"));
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