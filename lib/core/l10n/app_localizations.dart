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

  /// Label for the Orders navigation tab.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get tabOrders;

  /// Label for the Inventory navigation tab.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get tabInventory;

  /// Section title for recently received orders.
  ///
  /// In en, this message translates to:
  /// **'New Orders'**
  String get newOrders;

  /// Label for orders that are currently being prepared.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// Message shown when there are no new orders.
  ///
  /// In en, this message translates to:
  /// **'No new orders at the moment.'**
  String get noNewOrders;

  /// Button text to send the final quote price back to the customer.
  ///
  /// In en, this message translates to:
  /// **'Submit Quote to Customer'**
  String get submitQuote;

  /// Label for the newly calculated total price after quoting.
  ///
  /// In en, this message translates to:
  /// **'New Total'**
  String get totalQuote;

  /// A general greeting message.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Partner'**
  String get welcome;

  /// Label for the email input field.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for the password input field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// General action or button text for logging in.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Button text to log out of the application.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Loading state message while fetching product inventory.
  ///
  /// In en, this message translates to:
  /// **'Loading inventory...'**
  String get loadingInventory;

  /// Title for an order with its ID
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId}'**
  String orderNumber(String orderId);

  /// The combined total price of an order with its currency.
  ///
  /// In en, this message translates to:
  /// **'Total: {total} {currency}'**
  String totalPrice(double total, String currency);

  /// Title for the user profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Message shown when no user session is active.
  ///
  /// In en, this message translates to:
  /// **'No user logged in.'**
  String get noUserLoggedIn;

  /// Placeholder text when a user's name is not available.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// Placeholder text when a user's email is not available.
  ///
  /// In en, this message translates to:
  /// **'No Email'**
  String get noEmail;

  /// Title for the email verification screen.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// Instructional text about the email verification process.
  ///
  /// In en, this message translates to:
  /// **'A verification link has been sent to your email address. Please click the link to continue.'**
  String get verifyEmailBody;

  /// Button text to resend the verification email.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get verifyEmailResendButton;

  /// Button text to return to the login screen.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get verifyEmailBackButton;

  /// Title for the application settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Label for the language selection option.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// Shows the currently selected language code.
  ///
  /// In en, this message translates to:
  /// **'Current: {languageCode}'**
  String currentLanguage(String languageCode);

  /// Toggle switch label for dark mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Title for the language selection dialog.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Title for the sign-up screen.
  ///
  /// In en, this message translates to:
  /// **'Create SUEFERY Account'**
  String get signUpTitle;

  /// A notice explaining role default and vetting process.
  ///
  /// In en, this message translates to:
  /// **'New accounts default to Customer role. Rider/Partner accounts require manual vetting after sign-up.'**
  String get signUpDisclaimer;

  /// Hint text for the email input field (can be the same as 'email').
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// Hint text for the password input field (can be the same as 'password').
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// Hint text for the confirm password input field.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordHint;

  /// Button text to complete the sign-up process.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// Prompt for users with existing accounts.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get loginTextButton;

  /// Title for the login screen.
  ///
  /// In en, this message translates to:
  /// **'Login to SUEFERY'**
  String get loginTitle;

  /// Primary button for submitting login credentials (can be the same as 'login').
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// Prompt for users who need to create an account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get signUpTextButton;

  /// Button/link to initiate the forgot password flow.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordButton;

  /// Error message when the email field is left blank.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get emailEmptyError;

  /// Error message when the password field is left blank.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordEmptyError;

  /// Error message when confirm password does not match the original password.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatchError;

  /// Error message for passwords that are too short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordLengthError;

  /// Separator text before social sign-in options.
  ///
  /// In en, this message translates to:
  /// **'Or sign in with'**
  String get orSignInWith;

  /// Status message indicating the user must verify their account.
  ///
  /// In en, this message translates to:
  /// **'Verification is needed to continue'**
  String get verificationNeeded;

  /// Button to check the current status of the account/verification.
  ///
  /// In en, this message translates to:
  /// **'Check Status'**
  String get checkStatusButton;

  /// Generic navigation text to the signup page.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get toSignup;

  /// Generic navigation text to the login page.
  ///
  /// In en, this message translates to:
  /// **'To Login'**
  String get toLogin;

  /// Button text for signing in using Google.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleSignin;

  /// Button text for signing in using Facebook.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Facebook'**
  String get facebookSignin;

  /// Button text for signing in using Twitter.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Twitter'**
  String get twitterSignin;

  /// A simplified prompt for the login action.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get logInPrompt;

  /// Button or title for adding a new product to inventory.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// Hint text for the product price input.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productPriceHint;

  /// Hint text for the product description input.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get productDescriptionHint;

  /// Generic button text to save changes.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Generic button text to cancel an action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Error message for when a required name field is empty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// Error message for invalid price input.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get priceInvalid;

  /// Title or button to edit an existing product.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// Button text to update changes (often used instead of 'Save' for edits).
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Status label for a product that is available.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// Status label for a product that is unavailable.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// Generic loading indicator text.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Message shown when there are no new orders requiring a quote.
  ///
  /// In en, this message translates to:
  /// **'No new quote requests.'**
  String get noDraftOrders;

  /// Button text to accept a new order request.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptOrder;

  /// Button text to reject a new order request.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectOrder;

  /// Section or filter for orders that need a quote/review.
  ///
  /// In en, this message translates to:
  /// **'New Requests'**
  String get draftOrders;

  /// Section or filter for orders that have been accepted and are ready for preparation.
  ///
  /// In en, this message translates to:
  /// **'Confirmed Orders'**
  String get confirmedOrders;

  /// Button to change the status of a confirmed order to 'Ready for Pickup/Delivery'.
  ///
  /// In en, this message translates to:
  /// **'Mark as Ready'**
  String get orderReady;

  /// Message shown when there are no confirmed orders.
  ///
  /// In en, this message translates to:
  /// **'No confirmed orders to prepare.'**
  String get noConfirmedOrders;

  /// Title for the screen where the partner submits an order quote.
  ///
  /// In en, this message translates to:
  /// **'Quote for Order'**
  String get quoteForOrder;

  /// Section title listing the items within an order.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItems;

  /// Label for the unit price of an item.
  ///
  /// In en, this message translates to:
  /// **'Price/Unit'**
  String get pricePerUnit;

  /// Action button to finalize item prices and submit the quote.
  ///
  /// In en, this message translates to:
  /// **'Set Price & Quote'**
  String get setPrice;

  /// Label for the availability status of an order item.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get itemStatus;

  /// Status label indicating an item is currently available in stock.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Generic noun for an order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// Status label for an order or item that requires the partner to provide a price quote.
  ///
  /// In en, this message translates to:
  /// **'Needs Quote'**
  String get needsQuote;

  /// extra notes about the order
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Confirm on quoted items
  ///
  /// In en, this message translates to:
  /// **'Quote Confirm'**
  String get confirmQuote;

  /// Price of the product
  ///
  /// In en, this message translates to:
  /// **'Product Price'**
  String get productPrice;

  /// Description of the product
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get productDescription;

  /// Brand of the product
  ///
  /// In en, this message translates to:
  /// **'Product Brand'**
  String get productBrand;

  /// Missing product price error message
  ///
  /// In en, this message translates to:
  /// **'Product price is required'**
  String get productPriceRequired;

  /// Missing product description error message
  ///
  /// In en, this message translates to:
  /// **'Product description is required'**
  String get productDescriptionRequired;

  /// Missing product brand error message
  ///
  /// In en, this message translates to:
  /// **'Product brand is required'**
  String get productBrandRequired;

  /// Invalide product price error message
  ///
  /// In en, this message translates to:
  /// **'Product price is invalid'**
  String get productPriceInvalid;

  /// Delete button message
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// First name TextFormField
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// Last name TextFormField
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// Email TextFormField
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Password TextFormField
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Confirm Password TextFormField
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// Missing first name error message
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// Phone TextFormField
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// Missing phone number error message
  ///
  /// In en, this message translates to:
  /// **'phone number name is required'**
  String get phoneRequired;

  /// Missingrror message
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// Address TextFormField
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// Missing address error message
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// City TextFormField
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// Missing city error message
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get cityRequired;

  /// State TextFormField
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateLabel;

  /// Missing state error message
  ///
  /// In en, this message translates to:
  /// **'State is required'**
  String get stateRequired;

  /// Country TextFormField
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// Missing country error message
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get countryRequired;

  /// Zip Code TextFormField
  ///
  /// In en, this message translates to:
  /// **'Zip Code'**
  String get zipCodeLabel;

  /// Missing zip code error message
  ///
  /// In en, this message translates to:
  /// **'Zip Code is required'**
  String get zipCodeRequired;

  /// Delete Account label
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete Account label confirmation
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete Account'**
  String get deleteAccountConfirmation;

  /// Display name label
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// Display delete account hint
  ///
  /// In en, this message translates to:
  /// **'Please type DELETE to confirm.'**
  String get deleteAccountHint;

  /// Display title of setup store screen
  ///
  /// In en, this message translates to:
  /// **'Setup Your Store'**
  String get setupStoreScreenTitle;

  /// Display message of setup store screen
  ///
  /// In en, this message translates to:
  /// **'One Last Step!'**
  String get setupStoreMainMessage;

  /// Display message of setup store screen
  ///
  /// In en, this message translates to:
  /// **'We need your store details to connect you with customers nearby.'**
  String get setupStoreMain1Message;

  /// Display label of store name
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeNameLabel;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup Your Store'**
  String get setupTitle;

  /// No description provided for @stepInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get stepInfo;

  /// No description provided for @stepLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get stepLocation;

  /// No description provided for @stepTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get stepTags;

  /// No description provided for @oneLastStep.
  ///
  /// In en, this message translates to:
  /// **'One Last Step!'**
  String get oneLastStep;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We need your store details to connect you with customers nearby.'**
  String get setupSubtitle;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeName;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio / Slogan'**
  String get bioLabel;

  /// No description provided for @websiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website (Optional)'**
  String get websiteLabel;

  /// No description provided for @coordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Coordinates (Lat/Lng)'**
  String get coordsLabel;

  /// No description provided for @coordTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Use Google Maps to find your exact coordinates.'**
  String get coordTip;

  /// No description provided for @tagsTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you sell?'**
  String get tagsTitle;

  /// No description provided for @tagsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'e.g., Grocery, Pharmacy, Snacks'**
  String get tagsSubtitle;

  /// No description provided for @addTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add a tag...'**
  String get addTagHint;

  /// No description provided for @noTags.
  ///
  /// In en, this message translates to:
  /// **'No tags added yet.'**
  String get noTags;

  /// No description provided for @completeSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetup;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @revenueThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Revenue (Month)'**
  String get revenueThisMonth;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// No description provided for @mostWantedItems.
  ///
  /// In en, this message translates to:
  /// **'Most Wanted Items'**
  String get mostWantedItems;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data available yet.'**
  String get noDataYet;

  /// No description provided for @partnerPerformance.
  ///
  /// In en, this message translates to:
  /// **'Partner Score'**
  String get partnerPerformance;

  /// No description provided for @statusExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get statusExcellent;

  /// No description provided for @statusGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get statusGood;

  /// No description provided for @statusAtRisk.
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get statusAtRisk;

  /// No description provided for @fulfillmentRate.
  ///
  /// In en, this message translates to:
  /// **'Fulfillment Rate'**
  String get fulfillmentRate;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'High fulfillment boosts your ranking in S3 Dispatch.'**
  String get keepItUp;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @tabAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get tabAnalysis;
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
