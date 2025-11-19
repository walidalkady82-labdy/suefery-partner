import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/authentication_exception.dart';
import '../enums/auth_status.dart';
import '../enums/partner_status.dart';
import '../models/user_model.dart';
import '../repositories/i_repo_auth.dart';
import '../repositories/i_repo_firestore.dart';
import 'logging_service.dart';
import 'pref_service.dart';

/// Manages all authentication-related business logic.
///
/// This service coordinates the [IRepoAuth] (for data access)
/// and the [PrefService] (for session persistence) to perform
/// sign-in, sign-out, and session management tasks.
class AuthService{
  final IRepoAuth _authRepository;
  final PrefService _prefRepo;
  final IRepoFirestore _firestoreRepo;
  Timer? _keepAliveTimer; // NEW: Timer for S3 Keep-Alive
  final _log = LoggerRepo('AuthService'); // Assuming LoggerRepo exists

  /// {@macro authentication_service}
  ///
  /// Requires an [IRepoAuth] and [PrefService] for its
  /// dependencies (this is called Dependency Injection).
  AuthService(this._authRepository,this._firestoreRepo, this._prefRepo);
  User? get currentFirebaseUser {
    final firebaseUser = _authRepository.currentUser;
    if (firebaseUser == null) return null;
    return firebaseUser;
  }
  /// Gets the current [UserModel] by mapping the repository's [User].
  /// Returns `null` if no user is signed in.
  UserModel? get currentAppUser {
    final firebaseUser = _authRepository.currentUser;
    if (firebaseUser == null) return null;
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  /// Exposes a stream of [AppUser?]
  ///
  /// This maps the repository's Firebase [User?] stream to your
  /// app's internal [AppUser?] model.
  Stream<AuthStatus> onAuthStatusChanged() {
    return _authRepository.authStateChanges.map((User? user) {
      if (user != null) {
        // --- S3 (Keep-Alive) LOGIC START ---
        // User is logged in, start the keep-alive timer
        startKeepAlive(user.uid);
        // --- S3 LOGIC END ---
        return AuthStatus.authenticated;
      } else {
        // --- S3 (Keep-Alive) LOGIC START ---
        // User is logged out, stop the timer
        stopKeepAlive();
        // --- S3 LOGIC END ---
        return AuthStatus.unauthenticated;
      }
    });
  }
   // --- NEW: S3 (Keep-Alive) HELPER METHODS ---
  void startKeepAlive(String partnerId) {
    _keepAliveTimer?.cancel(); // Cancel any existing timer
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _updateKeepAlive(partnerId);
    });
    // Send one ping immediately on login
    _updateKeepAlive(partnerId);
  }

  void stopKeepAlive() {
    _keepAliveTimer?.cancel();
  }

  /// NEW: Pings Firestore to update 'last_seen' and 'status'
  Future<void> _updateKeepAlive(String partnerId) async {
    try {
      // Use an "upsert" operation (update or create) to prevent "not-found" errors.
      // This sets the document with the provided data, merging it with existing
      // data if the document already exists. If it doesn't exist, it's created.
      await _firestoreRepo.setDocument(
        'partners',
        partnerId,
        {
          'status': PartnerStatus.active.name,
          'last_seen': DateTime.now().toIso8601String(),
        },
        merge: true, // This is the key to making it an upsert.
      );
      _log.i('Keep-Alive Ping: Partner $partnerId is online.');
    } catch (e) {
      _log.e('Failed to update keep-alive: $e');
    }
  }
  
  // --- END S3 HELPER METHODS ---


  /// Handles the business logic for Google Sign-In.
  Future<UserModel?> signInWithGoogle() async {
    try {
      final userCredential = await _authRepository.logInWithGoogle();
      final user = userCredential.user;

      if (user != null) {
        final bool isNewUser =
            userCredential.additionalUserInfo?.isNewUser ?? false;
        await _prefRepo.setIsFirstLogin(isNewUser);
        await _handleSuccessfulLogin(user);
        return UserModel.fromFirebaseUser(user);
      }
      return null;
    } catch (e) {
      _log.e("Google Sign-In Error: $e");
      rethrow;
    }
  }

  /// Handles the business logic for Email/Pass Sign-Up.
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _authRepository.signUp(
        email: email,
        password: password,
      );
      final user = userCredential?.user;

      if (user != null) {
        await _prefRepo.setIsFirstLogin(true);
        await _handleSuccessfulLogin(user);
        return UserModel.fromFirebaseUser(user);
      }
      return null;
    } 
    on FirebaseAuthException catch (e) {
      _log.e("Registration Error: $e");
      throw AuthenticationFailure(e.message ?? 'Sign-in failed');
    }
    catch (e) {
      _log.e("Registration Error: $e");
      rethrow;
    }
  }

  /// Handles the business logic for Email/Pass Sign-In.
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _log.i("signInWithEmailAndPassword called for user: $email");
      // Await the UserCredential first, then get the user. This is cleaner and safer.
      final userCredential = await _authRepository.logInWithEmailAndPassword(
        email: email,
        password: password,
      ); 
      
      _log.i("UserCredential received successfully.");
      final user = userCredential.user;
      
      if (user == null) return null; // Guard against a null user.

      _log.i("Handling successful login for user: ${user.email}");
      await _handleSuccessfulLogin(user);
      return UserModel.fromFirebaseUser(user);
    } on TimeoutException {
      _log.e("Login Error: Timeout. The request took too long.");
      // Re-throwing a custom, more specific exception for the UI layer.
      throw LoginEmailPassFirebaseFailure('Login timed out. Please check your network connection and try again.');
    } on FirebaseAuthException catch (e) {
      _log.e("Login Error: ${e.code} , ${e.message}");
      // This error often means the user signed up with a different provider (e.g., Google).
      if (e.code == 'invalid-credential') {
        throw LoginEmailPassFirebaseFailure(
          'This account might have been created using a different sign-in method. Please try signing in with Google.',
        );
      }
      throw LoginEmailPassFirebaseFailure.fromCode(e.code);
    } catch (e) {
      _log.e("Login Error: $e");
      rethrow;
    }
  }

  /// Centralized logic to run after any successful login.
  /// Saves token and login state to preferences.
  Future<void> _handleSuccessfulLogin(User user) async {
    _log.i("Entering _handleSuccessfulLogin for user: ${user.email}");
    final token = await user.getIdToken();
    if (token != null) {
      await _prefRepo.setUserAuthToken(token);
    }
    // For email/pass sign-in, they are never a "new" user in this context.
    await _prefRepo.setIsFirstLogin(false);
    await _prefRepo.setUserLoggedInTime(DateTime.now());
    await _prefRepo.setUserIsLoggedin(true);
    _log.i("Exiting _handleSuccessfulLogin for user: ${user.email}");
  }

  /// Checks if the user's session is still valid on app start.
  Future<bool> isUserLoggedIn() async {
    final bool isUserLoggedin = _prefRepo.isUserLoggedin;
    final bool hasAuthUser = _authRepository.currentUser != null;

    if (!isUserLoggedin || !hasAuthUser) {
      _log.i('User is not logged in');
      return false;
    }

    try {
      _log.i('Trying to refresh user session...');
      await _authRepository.reloadUser();
      _log.i('User reload is successful');
      return true; // Successfully re-authenticated.
    } catch (e) {
      // Re-authentication failed (e.g., token expired, user disabled)
      _log.i('User reload failed, session is invalid: $e');
      await _clearUserSession(); // Session is invalid, clear it
      return false;
    }
  }

  /// Signs the user out and clears their session data from preferences.
  Future<bool> logOut() async {
    try {
      await _authRepository.logOut();
    } catch (e) {
      _log.e('Error during sign out: $e');
      // Still proceed to clear local session
    }
    await _clearUserSession();
    final bool isLoggedin = await _prefRepo.isUserLoggedin;
    return !isLoggedin; // Return true if logged out successfully
  }

  /// Centralized logic to clear user data from prefs.
  Future<void> _clearUserSession() async {
    await _prefRepo.setUserLoggedOffTime(DateTime.now());
    await _prefRepo.setUserIsLoggedin(false);
    await _prefRepo.setUserAuthToken(null);
  }

  /// Sends a password reset email.
  Future<void> resetPass(String email) async {
    try {
      if (email.isNotEmpty) {
        await _authRepository.sendPasswordResetEmail(email);
      }
    } on Exception catch (e) {
      _log.e('Error resetting pass: $e');
      rethrow;
    }
  }

  /// Updates the user's password using a reset code.
  Future<void> updatePass(
      {required String code, required String newPassword}) async {
    try {
      await _authRepository.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } catch (e) {
      _log.e('Error confirming pass reset: $e');
      rethrow;
    }
  }

  /// Sends a verification email to the current user.
  Future<void> sendEmailVerification() async {
    try {
      await _authRepository.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      _log.e("Registration Error: $e");
      throw AuthenticationFailure(e.message ?? 'send verification email failed');
    }
    catch (e) {
      _log.e('Error sending verification email: $e');
      rethrow;
    }
  }

   /// Deletes the current user's account and clears their local session.
  Future<void> deleteUser() async {
    try {
      _log.i('Attempting to delete user account...');
      await _authRepository.deleteUser();
      _log.i('User account deleted successfully from provider.');
      // After successful deletion, clear all local data
      await _clearUserSession();
    } on FirebaseAuthException catch (e) {
      _log.e('Error deleting user: ${e.code} - ${e.message}');
      // A common error is 'requires-recent-login', which you can
      // handle in your UI by prompting the user to re-authenticate.
      rethrow;
    }
  }

  /// Re-authenticates the current user by prompting for their password.
  /// Use this before performing sensitive operations.
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _authRepository.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user or user email available for re-authentication.');
      }

      // Create the credential object
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      // Pass the credential to the repository
      await _authRepository.reauthenticateWithCredential(credential);
      _log.i('User re-authenticated successfully.');
    } catch (e) {
      _log.e('Error during password re-authentication: $e');
      rethrow;
    }
  }

  /// Re-authenticates the current user using their Google account.
  Future<void> reauthenticateWithGoogle() async {
    try {
      // 1. Ask the repository for a Google Auth Credential.
      // This moves the `GoogleSignIn` logic into the repository layer.
      final credential = await _authRepository.logInWithGoogle();
      // 2. Pass the credential to the repository's re-authentication method.
      await _authRepository.reauthenticateWithCredential(credential.credential!);
      _log.i('User re-authenticated successfully with Google.'); 
    } catch (e) {
      _log.e('Error during Google re-authentication: $e');
      rethrow;
    }
  }
  Future<void> reloadUser() async {
    try {
      await _authRepository.reloadUser();
    }catch (e) {
      _log.e('Error during reloading user: $e');
      rethrow;
    }
  }
}