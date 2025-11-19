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
  String get submitQuote => 'Submit Quote to Customer';

  @override
  String get totalQuote => 'New Total';

  @override
  String get welcome => 'Welcome, Partner';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get loadingInventory => 'Loading inventory...';

  @override
  String orderNumber(String orderId) {
    return 'Order #$orderId';
  }

  @override
  String totalPrice(double total, String currency) {
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
  String currentLanguage(String languageCode) {
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
  String get verificationNeeded => 'Verification is needed to continue';

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

  @override
  String get addProduct => 'Add Product';

  @override
  String get productPriceHint => 'Price';

  @override
  String get productDescriptionHint => 'Description (optional)';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get priceInvalid => 'Please enter a valid price';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get update => 'Update';

  @override
  String get inStock => 'In Stock';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get loading => 'Loading...';

  @override
  String get noDraftOrders => 'No new quote requests.';

  @override
  String get acceptOrder => 'Accept';

  @override
  String get rejectOrder => 'Reject';

  @override
  String get draftOrders => 'New Requests';

  @override
  String get confirmedOrders => 'Confirmed Orders';

  @override
  String get orderReady => 'Mark as Ready';

  @override
  String get noConfirmedOrders => 'No confirmed orders to prepare.';

  @override
  String get quoteForOrder => 'Quote for Order';

  @override
  String get orderItems => 'Order Items';

  @override
  String get pricePerUnit => 'Price/Unit';

  @override
  String get setPrice => 'Set Price & Quote';

  @override
  String get itemStatus => 'Status';

  @override
  String get available => 'Available';

  @override
  String get order => 'Order';

  @override
  String get needsQuote => 'Needs Quote';

  @override
  String get notes => 'Notes';

  @override
  String get confirmQuote => 'Quote Confirm';

  @override
  String get productPrice => 'Product Price';

  @override
  String get productDescription => 'Product Description';

  @override
  String get productBrand => 'Product Brand';

  @override
  String get productPriceRequired => 'Product price is required';

  @override
  String get productDescriptionRequired => 'Product description is required';

  @override
  String get productBrandRequired => 'Product brand is required';

  @override
  String get productPriceInvalid => 'Product price is invalid';

  @override
  String get delete => 'Delete';
}
