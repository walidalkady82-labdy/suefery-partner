// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Suefery Partner';

  @override
  String get tabOrders => 'Orders';

  @override
  String get tabInventory => 'Inventory';

  @override
  String get newOrders => 'New Orders';

  @override
  String get preparing => 'Preparing';

  @override
  String get noNewOrders => 'No new orders at the moment.';

  @override
  String get acceptOrder => 'Accept';

  @override
  String get rejectOrder => 'Reject';

  @override
  String get orderReady => 'Mark as Ready';

  @override
  String get inStock => 'In Stock';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get welcome => 'Welcome!';

  @override
  String get loadingInventory => 'Loading inventory...';

  @override
  String orderNumber(Object orderId) {
    return 'Order #$orderId';
  }

  @override
  String totalPrice(Object currency, Object total) {
    return 'Total: $total $currency';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get noUserLoggedIn => 'No user logged in.';

  @override
  String get noName => 'No Name';

  @override
  String get noEmail => 'No Email';

  @override
  String get verifyEmailTitle => 'Verify Your Email';

  @override
  String get verifyEmailBody =>
      'A verification link has been sent to your email address. Please click the link to continue.';

  @override
  String get verifyEmailResendButton => 'Resend Email';

  @override
  String get verifyEmailBackButton => 'Back to Login';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String currentLanguage(Object languageCode) {
    return 'Current: $languageCode';
  }

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get signUpTitle => 'Create SUEFERY Account';

  @override
  String get signUpDisclaimer =>
      'New accounts default to Customer role. Rider/Partner accounts require manual vetting after sign-up.';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get confirmPasswordHint => 'Confirm Password';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get loginTextButton => 'Already have an account? Login';

  @override
  String get loginTitle => 'Login to SUEFERY';

  @override
  String get loginButton => 'Login';

  @override
  String get signUpTextButton => 'Don\'t have an account? Sign Up';

  @override
  String get forgotPasswordButton => 'Forgot Password?';

  @override
  String get emailEmptyError => 'Email cannot be empty';

  @override
  String get passwordEmptyError => 'Password cannot be empty';

  @override
  String get passwordsDoNotMatchError => 'Passwords do not match';

  @override
  String get passwordLengthError => 'Password must be at least 6 characters.';

  @override
  String get orSignInWith => 'Or sign in with';

  @override
  String get verificationNeeded => 'Vreification is needed to continue';

  @override
  String get checkStatusButton => 'Check Status';

  @override
  String get toSignup => 'To Signup';

  @override
  String get toLogin => 'To Login';

  @override
  String get googleSignin => 'Sign in with Google';

  @override
  String get facebookSignin => 'Sign in with Facebook';

  @override
  String get twitterSignin => 'Sign in with Twitter';

  @override
  String get logInPrompt => 'Login';
}
