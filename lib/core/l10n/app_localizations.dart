import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The main title for the complete multi-role application.
  ///
  /// In en, this message translates to:
  /// **'Suefery Partner'**
  String get appTitle;

  /// No description provided for @tabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get tabOrders;

  /// No description provided for @tabInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get tabInventory;

  /// No description provided for @newOrders.
  ///
  /// In en, this message translates to:
  /// **'New Orders'**
  String get newOrders;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// No description provided for @noNewOrders.
  ///
  /// In en, this message translates to:
  /// **'No new orders at the moment.'**
  String get noNewOrders;

  /// No description provided for @acceptOrder.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptOrder;

  /// No description provided for @rejectOrder.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectOrder;

  /// No description provided for @orderReady.
  ///
  /// In en, this message translates to:
  /// **'Mark as Ready'**
  String get orderReady;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @loadingInventory.
  ///
  /// In en, this message translates to:
  /// **'Loading inventory...'**
  String get loadingInventory;

  /// Title for an order with its ID
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId}'**
  String orderNumber(Object orderId);

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total: {total} {currency}'**
  String totalPrice(Object currency, Object total);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @noUserLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'No user logged in.'**
  String get noUserLoggedIn;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No Email'**
  String get noEmail;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'A verification link has been sent to your email address. Please click the link to continue.'**
  String get verifyEmailBody;

  /// No description provided for @verifyEmailResendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get verifyEmailResendButton;

  /// No description provided for @verifyEmailBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get verifyEmailBackButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current: {languageCode}'**
  String currentLanguage(Object languageCode);

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create SUEFERY Account'**
  String get signUpTitle;

  /// No description provided for @signUpDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'New accounts default to Customer role. Rider/Partner accounts require manual vetting after sign-up.'**
  String get signUpDisclaimer;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordHint;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @loginTextButton.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get loginTextButton;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to SUEFERY'**
  String get loginTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @signUpTextButton.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get signUpTextButton;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordButton;

  /// No description provided for @emailEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get emailEmptyError;

  /// No description provided for @passwordEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordEmptyError;

  /// No description provided for @passwordsDoNotMatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatchError;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordLengthError;

  /// No description provided for @orSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Or sign in with'**
  String get orSignInWith;

  /// No description provided for @verificationNeeded.
  ///
  /// In en, this message translates to:
  /// **'Vreification is needed to continue'**
  String get verificationNeeded;

  /// No description provided for @checkStatusButton.
  ///
  /// In en, this message translates to:
  /// **'Check Status'**
  String get checkStatusButton;

  /// No description provided for @toSignup.
  ///
  /// In en, this message translates to:
  /// **'To Signup'**
  String get toSignup;

  /// No description provided for @toLogin.
  ///
  /// In en, this message translates to:
  /// **'To Login'**
  String get toLogin;

  /// No description provided for @googleSignin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleSignin;

  /// No description provided for @facebookSignin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Facebook'**
  String get facebookSignin;

  /// No description provided for @twitterSignin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Twitter'**
  String get twitterSignin;

  /// No description provided for @logInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get logInPrompt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
