// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'شريك سويفري';

  @override
  String get tabOrders => 'الطلبات';

  @override
  String get tabInventory => 'المخزون';

  @override
  String get newOrders => 'الطلبات الجديدة';

  @override
  String get preparing => 'قيد التحضير';

  @override
  String get noNewOrders => 'لا توجد طلبات جديدة في الوقت الحالي.';

  @override
  String get submitQuote => 'إرسال عرض السعر للعميل';

  @override
  String get totalQuote => 'الإجمالي الجديد';

  @override
  String get welcome => 'مرحباً بك، أيها الشريك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get loadingInventory => 'جاري تحميل المخزون...';

  @override
  String orderNumber(String orderId) {
    return 'طلب رقم $orderId';
  }

  @override
  String totalPrice(double total, String currency) {
    return 'الإجمالي: $total $currency';
  }

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get noUserLoggedIn => 'لا يوجد مستخدم مسجل الدخول.';

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
  String get verifyEmailBackButton => 'العودة لتسجيل الدخول';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String currentLanguage(String languageCode) {
    return 'الحالية: $languageCode';
  }

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get signUpTitle => 'إنشاء حساب سويفري';

  @override
  String get signUpDisclaimer =>
      'الحسابات الجديدة تكون \'عميل\' افتراضياً. حسابات الشريك/الرائد تتطلب فحصاً يدوياً بعد التسجيل.';

  @override
  String get emailHint => 'البريد الإلكتروني';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get confirmPasswordHint => 'تأكيد كلمة المرور';

  @override
  String get signUpButton => 'تسجيل';

  @override
  String get loginTextButton => 'هل لديك حساب بالفعل؟ سجل الدخول';

  @override
  String get loginTitle => 'تسجيل الدخول إلى سويفري';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get signUpTextButton => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get forgotPasswordButton => 'هل نسيت كلمة المرور؟';

  @override
  String get emailEmptyError => 'لا يمكن أن يكون البريد الإلكتروني فارغاً';

  @override
  String get passwordEmptyError => 'لا يمكن أن تكون كلمة المرور فارغة';

  @override
  String get passwordsDoNotMatchError => 'كلمتا المرور غير متطابقتين';

  @override
  String get passwordLengthError =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';

  @override
  String get orSignInWith => 'أو سجل الدخول بواسطة';

  @override
  String get verificationNeeded => 'التحقق مطلوب للمتابعة';

  @override
  String get checkStatusButton => 'تحقق من الحالة';

  @override
  String get toSignup => 'للتسجيل';

  @override
  String get toLogin => 'لتسجيل الدخول';

  @override
  String get googleSignin => 'تسجيل الدخول باستخدام جوجل';

  @override
  String get facebookSignin => 'تسجيل الدخول باستخدام فيسبوك';

  @override
  String get twitterSignin => 'تسجيل الدخول باستخدام تويتر';

  @override
  String get logInPrompt => 'تسجيل الدخول';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get productPriceHint => 'السعر';

  @override
  String get productDescriptionHint => 'الوصف (اختياري)';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get nameCannotBeEmpty => 'لا يمكن أن يكون الاسم فارغاً';

  @override
  String get priceInvalid => 'الرجاء إدخال سعر صالح';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get update => 'تحديث';

  @override
  String get inStock => 'متوفر في المخزون';

  @override
  String get outOfStock => 'غير متوفر';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get noDraftOrders => 'لا توجد طلبات عروض أسعار جديدة.';

  @override
  String get acceptOrder => 'قبول';

  @override
  String get rejectOrder => 'رفض';

  @override
  String get draftOrders => 'طلبات جديدة';

  @override
  String get confirmedOrders => 'الطلبات المؤكدة';

  @override
  String get orderReady => 'تحديد كجاهز';

  @override
  String get noConfirmedOrders => 'لا توجد طلبات مؤكدة للتحضير.';

  @override
  String get quoteForOrder => 'عرض سعر للطلب';

  @override
  String get orderItems => 'عناصر الطلب';

  @override
  String get pricePerUnit => 'السعر للوحدة';

  @override
  String get setPrice => 'تحديد السعر وعرضه';

  @override
  String get itemStatus => 'الحالة';

  @override
  String get available => 'متوفر';

  @override
  String get order => 'الطلب';

  @override
  String get needsQuote => 'يحتاج إلى عرض سعر';

  @override
  String get notes => 'ملاحظات';

  @override
  String get confirmQuote => 'تأكيد عرض السعر';

  @override
  String get productPrice => 'السعر';

  @override
  String get productDescription => 'وصف المنتج';

  @override
  String get productBrand => 'مصنع المنتج';

  @override
  String get productPriceRequired => 'السعر مطلوب';

  @override
  String get productDescriptionRequired => 'وصف المنتج مطلوب';

  @override
  String get productBrandRequired => ' مصنع المنتج مطلوب';

  @override
  String get productPriceInvalid => 'السعر غير صالح';

  @override
  String get delete => 'حذف';
}
