// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'شريك سفري';

  @override
  String get tabOrders => 'الطلبات';

  @override
  String get tabInventory => 'المخزون';

  @override
  String get newOrders => 'طلبات جديدة';

  @override
  String get preparing => 'قيد التجهيز';

  @override
  String get noNewOrders => 'لا توجد طلبات جديدة في الوقت الحالي.';

  @override
  String get acceptOrder => 'قبول';

  @override
  String get rejectOrder => 'رفض';

  @override
  String get orderReady => 'تحديد كجاهز';

  @override
  String get inStock => 'متوفر';

  @override
  String get outOfStock => 'غير متوفر';

  @override
  String get welcome => 'أهلاً بك!';

  @override
  String get loadingInventory => 'جاري تحميل المخزون...';

  @override
  String orderNumber(Object orderId) {
    return 'طلب رقم #$orderId';
  }

  @override
  String totalPrice(Object currency, Object total) {
    return 'الإجمالي: $total $currency';
  }

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get noUserLoggedIn => 'لم يتم تسجيل دخول أي مستخدم.';

  @override
  String get noName => 'لا يوجد اسم';

  @override
  String get noEmail => 'لا يوجد بريد إلكتروني';

  @override
  String get verifyEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get verifyEmailBody =>
      'تم إرسال رابط التحقق إلى عنوان بريدك الإلكتروني. يرجى النقر على الرابط للمتابعة.';

  @override
  String get verifyEmailResendButton => 'إعادة إرسال البريد الإلكتروني';

  @override
  String get verifyEmailBackButton => 'العودة إلى تسجيل الدخول';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String currentLanguage(Object languageCode) {
    return 'الحالية: $languageCode';
  }

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get signUpTitle => 'إنشاء حساب سفري';

  @override
  String get signUpDisclaimer =>
      'يتم تعيين الحسابات الجديدة كعميل افتراضيًا. تتطلب حسابات السائقين والشركاء فحصًا يدويًا بعد التسجيل.';

  @override
  String get emailHint => 'البريد الإلكتروني';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get confirmPasswordHint => 'تأكيد كلمة المرور';

  @override
  String get signUpButton => 'إنشاء حساب';

  @override
  String get loginTextButton => 'لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get loginTitle => 'تسجيل الدخول إلى سفري';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get signUpTextButton => 'ليس لديك حساب؟ إنشاء حساب';

  @override
  String get forgotPasswordButton => 'هل نسيت كلمة المرور؟';

  @override
  String get emailEmptyError => 'لا يمكن أن يكون البريد الإلكتروني فارغًا';

  @override
  String get passwordEmptyError => 'لا يمكن أن تكون كلمة المرور فارغة';

  @override
  String get passwordsDoNotMatchError => 'كلمات المرور غير متطابقة';

  @override
  String get passwordLengthError =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';

  @override
  String get orSignInWith => 'أو سجل الدخول باستخدام';

  @override
  String get verificationNeeded => 'يجب التحقق';

  @override
  String get checkStatusButton => 'تحقق من حالة الطلب';

  @override
  String get toSignup => 'الاشتراك';

  @override
  String get toLogin => 'تسجيل الدخول';

  @override
  String get googleSignin => 'تسجيل الدخول باستخدام جوجل';

  @override
  String get facebookSignin => 'تسجيل الدخول باستخدام فيسبوك';

  @override
  String get twitterSignin => 'تسجيل الدخول باستخدام تويتر';

  @override
  String get logInPrompt => 'تسجيل الدخول';
}
