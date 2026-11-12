// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_generated.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'دوكافو';

  @override
  String get appTagline => 'أدر متجرك من أي مكان.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get create => 'إنشاء';

  @override
  String get search => 'بحث';

  @override
  String get close => 'إغلاق';

  @override
  String get done => 'تم';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get noData => 'لا يوجد شيء بعد';

  @override
  String get errorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get errorNetwork =>
      'تعذر الوصول إلى الخادم. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get offlineTitle => 'أنت غير متصل';

  @override
  String get offlineBody =>
      'نعرض ما تم حفظه على هذا الجهاز. الإجراءات التي تحتاج إلى الخادم متوقفة مؤقتًا.';

  @override
  String get offlineSyncingTitle => 'عاد الاتصال';

  @override
  String offlineSyncingBody(Object count) {
    return 'جارٍ مزامنة $count تغيير محفوظ…';
  }

  @override
  String get offlineRefreshing => 'جارٍ تحديث أحدث البيانات…';

  @override
  String get offlineBackOnline => 'عاد الاتصال بالإنترنت';

  @override
  String get offlineBackOnlineBody =>
      'جارٍ مزامنة التغييرات المحفوظة وسيتم تحديث الشاشات.';

  @override
  String get offlineActionBlocked => 'هذا الإجراء يحتاج إلى اتصال بالإنترنت.';

  @override
  String get offlineNoSavedData => 'لا توجد نسخة محفوظة بعد';

  @override
  String get offlineNoSavedDataBody =>
      'اتصل بالإنترنت مرة واحدة لتبقى هذه الشاشة متاحة دون اتصال.';

  @override
  String get offlineQueued => 'تم الحفظ للمزامنة لاحقًا';

  @override
  String offlinePendingChanges(Object count) {
    return '$count تغيير في انتظار المزامنة';
  }

  @override
  String get requiredField => 'هذا الحقل مطلوب.';

  @override
  String get invalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get passwordTooShort => 'استخدم 8 أحرف على الأقل.';

  @override
  String get all => 'الكل';

  @override
  String get none => 'بدون';

  @override
  String get optional => 'اختياري';

  @override
  String get actions => 'الإجراءات';

  @override
  String get confirm => 'تأكيد';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get apply => 'تطبيق';

  @override
  String get clear => 'مسح';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get filter => 'تصفية';

  @override
  String get filters => 'التصفية';

  @override
  String get refresh => 'تحديث';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get total => 'الإجمالي';

  @override
  String get status => 'الحالة';

  @override
  String get name => 'الاسم';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'الهاتف';

  @override
  String get notes => 'ملاحظات';

  @override
  String get description => 'الوصف';

  @override
  String get price => 'السعر';

  @override
  String get cost => 'التكلفة';

  @override
  String get sku => 'رمز المنتج';

  @override
  String get category => 'الفئة';

  @override
  String get categories => 'الفئات';

  @override
  String get product => 'المنتج';

  @override
  String get products => 'المنتجات';

  @override
  String get order => 'الطلب';

  @override
  String get orders => 'الطلبات';

  @override
  String get customer => 'العميل';

  @override
  String get customers => 'العملاء';

  @override
  String get inventory => 'المخزون';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get conversations => 'المحادثات';

  @override
  String get inbox => 'المحادثات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get analytics => 'التحليلات';

  @override
  String get more => 'المزيد';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول لإدارة متجرك.';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signingIn => 'جارٍ تسجيل الدخول…';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get tenantSetupTitle => 'أنشئ مساحة عملك';

  @override
  String get tenantSetupSubtitle =>
      'أخبرنا باسم نشاطك التجاري. يمكنك دعوة فريقك لاحقًا.';

  @override
  String get workspaceName => 'اسم مساحة العمل';

  @override
  String get storeName => 'اسم المتجر';

  @override
  String get createWorkspace => 'إنشاء مساحة العمل';

  @override
  String get switchWorkspace => 'تبديل مساحة العمل';

  @override
  String get selectWorkspace => 'اختر مساحة عمل';

  @override
  String get noWorkspace => 'ليس لديك مساحة عمل بعد.';

  @override
  String get sessionExpired => 'انتهت جلستك. سجّل الدخول مرة أخرى.';

  @override
  String get unauthorized => 'انتهت جلستك. سجّل الدخول مرة أخرى.';

  @override
  String get forbidden => 'ليس لديك إذن للقيام بذلك.';

  @override
  String get notFound => 'لم نتمكن من العثور على ما تبحث عنه.';

  @override
  String get serverError => 'حدث خطأ من جانبنا. حاول مرة أخرى.';

  @override
  String get validationError => 'بعض التفاصيل تحتاج إلى مراجعة.';

  @override
  String get signedOut => 'تم تسجيل خروجك.';

  @override
  String get signOutConfirm => 'تسجيل الخروج؟';

  @override
  String get signOutMessage =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى على هذا الجهاز.';

  @override
  String get dashboardTitle => 'نظرة عامة';

  @override
  String get revenueToday => 'إيرادات اليوم';

  @override
  String get ordersToday => 'طلبات اليوم';

  @override
  String get averageOrderValue => 'متوسط الطلب';

  @override
  String get revenueMonth => 'إيرادات هذا الشهر';

  @override
  String get ordersMonth => 'طلبات هذا الشهر';

  @override
  String get openConversations => 'محادثات مفتوحة';

  @override
  String get lowStockItems => 'مخزون منخفض';

  @override
  String get activeCustomers => 'عملاء نشطون';

  @override
  String get awaitingFulfilment => 'بانتظار التنفيذ';

  @override
  String get revenueTrend => 'اتجاه الإيرادات';

  @override
  String get topProducts => 'أفضل المنتجات';

  @override
  String get deadStock => 'مخزون راكد';

  @override
  String get noTopProducts => 'لا مبيعات في هذه الفترة بعد.';

  @override
  String get noDeadStock => 'لا يوجد مخزون راكد. ممتاز.';

  @override
  String get last30Days => 'آخر 30 يومًا';

  @override
  String get units => 'وحدة';

  @override
  String get stock => 'المخزون';

  @override
  String get lowStock => 'مخزون منخفض';

  @override
  String get outOfStock => 'نفد المخزون';

  @override
  String get inStock => 'متوفر';

  @override
  String get adjustStock => 'تعديل المخزون';

  @override
  String get receiveStock => 'استلام مخزون';

  @override
  String get movements => 'الحركات';

  @override
  String get quantity => 'الكمية';

  @override
  String get newQuantity => 'الكمية الجديدة';

  @override
  String get note => 'ملاحظة';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get createProduct => 'منتج جديد';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get productStatus => 'الحالة';

  @override
  String get draft => 'مسودة';

  @override
  String get active => 'نشط';

  @override
  String get archived => 'مؤرشف';

  @override
  String get inactive => 'غير نشط';

  @override
  String get blocked => 'محظور';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get confirmed => 'مؤكد';

  @override
  String get processing => 'قيد المعالجة';

  @override
  String get shipped => 'تم الشحن';

  @override
  String get delivered => 'تم التسليم';

  @override
  String get cancelled => 'ملغى';

  @override
  String get unpaid => 'غير مدفوع';

  @override
  String get partiallyPaid => 'مدفوع جزئيًا';

  @override
  String get paid => 'مدفوع';

  @override
  String get refunded => 'مسترد';

  @override
  String get orderNumber => 'رقم الطلب';

  @override
  String get paymentStatus => 'الدفع';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get discount => 'الخصم';

  @override
  String get tax => 'الضريبة';

  @override
  String get shipping => 'الشحن';

  @override
  String get grandTotal => 'الإجمالي';

  @override
  String get items => 'العناصر';

  @override
  String get customerName => 'اسم العميل';

  @override
  String get customerPhone => 'هاتف العميل';

  @override
  String get changeStatus => 'تغيير الحالة';

  @override
  String get allowedTransitions => 'الإجراءات المتاحة';

  @override
  String get orderTimeline => 'السجل';

  @override
  String get createOrder => 'طلب جديد';

  @override
  String get selectCustomer => 'اختر عميلًا';

  @override
  String get selectProduct => 'اختر منتجًا';

  @override
  String get variant => 'الخيار';

  @override
  String get addToOrder => 'إضافة عنصر';

  @override
  String get orderCreated => 'تم إنشاء الطلب.';

  @override
  String get orderUpdated => 'تم تحديث الطلب.';

  @override
  String get statusUpdated => 'تم تحديث الحالة.';

  @override
  String get createCategory => 'فئة جديدة';

  @override
  String get editCategory => 'تعديل الفئة';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get parentCategory => 'الفئة الأصلية';

  @override
  String get sortOrder => 'ترتيب العرض';

  @override
  String get productsCount => 'المنتجات';

  @override
  String get createCustomer => 'عميل جديد';

  @override
  String get editCustomer => 'تعديل العميل';

  @override
  String get customerStatus => 'الحالة';

  @override
  String get totalSpent => 'إجمالي الإنفاق';

  @override
  String get ordersCount => 'الطلبات';

  @override
  String get lastOrder => 'آخر طلب';

  @override
  String get addresses => 'العناوين';

  @override
  String get conversationStatus => 'الحالة';

  @override
  String get open => 'فتح';

  @override
  String get closed => 'مغلقة';

  @override
  String get unread => 'غير مقروء';

  @override
  String get assignedTo => 'مسندة إلى';

  @override
  String get unassigned => 'غير مسندة';

  @override
  String get sendMessage => 'إرسال';

  @override
  String get messageHint => 'اكتب ردًا…';

  @override
  String get sendNote => 'إضافة ملاحظة';

  @override
  String get internalNote => 'ملاحظة داخلية';

  @override
  String get markRead => 'تحديد كمقروء';

  @override
  String get noMessages => 'لا رسائل بعد.';

  @override
  String get replyWindowClosed => 'انتهت نافذة الرد. أرسل قالبًا للمتابعة.';

  @override
  String get templateRequired => 'القالب مطلوب';

  @override
  String get notificationCenter => 'الإشعارات';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get markAsRead => 'تحديد كمقروء';

  @override
  String get markAsUnread => 'تحديد كغير مقروء';

  @override
  String get dismiss => 'تجاهل';

  @override
  String get noNotifications => 'لا إشعارات جديدة.';

  @override
  String get profileTitle => 'ملفك الشخصي';

  @override
  String get editProfile => 'تعديل الملف';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordSubtitle =>
      'أدخل الرمز المرسل إلى بريدك واختر كلمة مرور جديدة.';

  @override
  String get resetToken => 'رمز إعادة التعيين';

  @override
  String get resetTokenMissing =>
      'رابط إعادة التعيين غير مكتمل. اطلب رابطًا جديدًا.';

  @override
  String get passwordResetSuccess => 'تم تحديث كلمة المرور';

  @override
  String get passwordResetSuccessMessage =>
      'يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get sessions => 'الأجهزة المسجلة';

  @override
  String get revoke => 'تسجيل الخروج';

  @override
  String get revokeOthers => 'تسجيل خروج الأجهزة الأخرى';

  @override
  String get currentSession => 'هذا الجهاز';

  @override
  String get notificationPreferences => 'تفضيلات الإشعارات';

  @override
  String get workspaceSettings => 'إعدادات مساحة العمل';

  @override
  String get theme => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'النظام';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get about => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get analyticsTitle => 'التحليلات';

  @override
  String get dateRange => 'النطاق الزمني';

  @override
  String get from => 'من';

  @override
  String get until => 'إلى';

  @override
  String get kpi => 'المؤشرات الرئيسية';

  @override
  String get salesTrend => 'اتجاه المبيعات';

  @override
  String get productPerformance => 'أداء المنتجات';

  @override
  String get stockHealth => 'صحة المخزون';

  @override
  String get noAnalytics => 'لا تحليلات لهذه الفترة.';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get endOfList => 'وصلت إلى النهاية.';

  @override
  String get pullToRefresh => 'اسحب للتحديث';

  @override
  String get invalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get accountSuspended => 'هذا الحساب موقوف. تواصل مع الدعم.';

  @override
  String get tenantRequired => 'أنشئ مساحة عمل للمتابعة.';

  @override
  String get noPermission => 'ليس لديك إذن لعرض هذا.';

  @override
  String get avatar => 'صورة الملف الشخصي';

  @override
  String get uploadPhoto => 'رفع صورة';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get chooseImage => 'اختر صورة';

  @override
  String get imageUploadFailed => 'تعذر رفع الصورة.';

  @override
  String get passwordChanged =>
      'تم تغيير كلمة المرور. تم تسجيل خروج الأجهزة الأخرى.';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي.';

  @override
  String get settingsUpdated => 'تم تحديث الإعدادات.';

  @override
  String get preferencesUpdated => 'تم تحديث التفضيلات.';

  @override
  String get sessionRevoked => 'تم تسجيل خروج الجهاز.';

  @override
  String get allSessionsRevoked => 'تم تسجيل خروج الأجهزة الأخرى.';

  @override
  String get allNotificationsRead => 'تم تحديد كل الإشعارات كمقروءة.';

  @override
  String get messageSent => 'تم إرسال الرسالة.';

  @override
  String get noteSent => 'تمت إضافة الملاحظة.';

  @override
  String get stockAdjusted => 'تم تعديل المخزون.';

  @override
  String get stockReceived => 'تم استلام المخزون.';

  @override
  String get customerCreated => 'تم إنشاء العميل.';

  @override
  String get customerUpdated => 'تم تحديث العميل.';

  @override
  String get customerDeleted => 'تم حذف العميل.';

  @override
  String get customerCrm => 'إدارة علاقات العميل';

  @override
  String get conversation => 'المحادثة';

  @override
  String get paidOrders => 'الطلبات المدفوعة';

  @override
  String get lastInteraction => 'آخر تفاعل';

  @override
  String get aiSummary => 'ملخص الذكاء الاصطناعي';

  @override
  String get aiSummaryEmpty =>
      'لا يوجد ملخص بعد. حدّث لإنشاء ملخص من نشاط هذا العميل.';

  @override
  String get editSummary => 'تعديل الملخص';

  @override
  String get refreshSummary => 'تحديث الملخص';

  @override
  String get summaryHint => 'اكتب ملخصًا قصيرًا عن هذا العميل.';

  @override
  String get summaryRefreshed => 'تم تحديث الملخص.';

  @override
  String get summaryUpdated => 'تم تحديث الملخص.';

  @override
  String get highlights => 'أبرز النقاط';

  @override
  String get specifications => 'المواصفات';

  @override
  String get tags => 'الوسوم';

  @override
  String get shortDescription => 'وصف مختصر';

  @override
  String get seoTitle => 'عنوان SEO';

  @override
  String get seoDescription => 'وصف SEO';

  @override
  String get seoKeywords => 'كلمات SEO المفتاحية';

  @override
  String get linesHint => 'عنصر واحد في كل سطر.';

  @override
  String get specificationsHint =>
      'مواصفة واحدة في كل سطر بالصيغة الاسم: القيمة.';

  @override
  String get tagsHint => 'افصل الوسوم بفواصل.';

  @override
  String get risks => 'المخاطر';

  @override
  String get opportunities => 'الفرص';

  @override
  String get memories => 'الذكريات';

  @override
  String get addMemory => 'إضافة ذكرى';

  @override
  String get editMemory => 'تعديل الذكرى';

  @override
  String get noMemories => 'لا توجد ذكريات محفوظة بعد.';

  @override
  String get memoryKey => 'المفتاح';

  @override
  String get memoryValue => 'القيمة';

  @override
  String get confidence => 'الثقة';

  @override
  String get confidenceRange => 'أدخل رقمًا بين 0 و100.';

  @override
  String get deleteMemory => 'حذف الذكرى';

  @override
  String get deleteMemoryMessage => 'ستتم إزالة هذه الذكرى من سجل العميل.';

  @override
  String get memorySaved => 'تم حفظ الذكرى.';

  @override
  String get memoryDeleted => 'تم حذف الذكرى.';

  @override
  String get timeline => 'الخط الزمني';

  @override
  String get noActivity => 'لا يوجد نشاط بعد.';

  @override
  String get edited => 'معدّل';

  @override
  String get productCreated => 'تم إنشاء المنتج.';

  @override
  String get productUpdated => 'تم تحديث المنتج.';

  @override
  String get productDeleted => 'تم حذف المنتج.';

  @override
  String get categoryCreated => 'تم إنشاء الفئة.';

  @override
  String get categoryUpdated => 'تم تحديث الفئة.';

  @override
  String get categoryDeleted => 'تم حذف الفئة.';

  @override
  String get deleteConfirmTitle => 'حذف؟';

  @override
  String get deleteConfirmMessage => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get unsavedChanges => 'تجاهل التغييرات؟';

  @override
  String get discard => 'تجاهل';

  @override
  String get keepEditing => 'متابعة التعديل';

  @override
  String get currency => 'العملة';

  @override
  String get storeCurrency => 'عملة المتجر';

  @override
  String get storeCurrencyHelp =>
      'يؤدي التحويل إلى إعادة كتابة أسعار المنتجات والمتغيرات والحزم والشحن الحالية. تحتفظ الطلبات السابقة بعملتها الأصلية.';

  @override
  String get currentCurrency => 'العملة الحالية';

  @override
  String get targetCurrency => 'العملة الجديدة';

  @override
  String get previewConversion => 'معاينة التحويل';

  @override
  String get conversionRate => 'سعر الصرف';

  @override
  String get rateSource => 'مصدر السعر';

  @override
  String get rateFetchedAt => 'وقت جلب السعر';

  @override
  String get variants => 'المتغيرات';

  @override
  String get samplePrices => 'أسعار تجريبية';

  @override
  String get before => 'قبل';

  @override
  String get after => 'بعد';

  @override
  String get convertCurrency => 'تحويل العملة';

  @override
  String get convertCurrencyTitle => 'تحويل عملة المتجر؟';

  @override
  String get convertCurrencyMessage =>
      'ستتم إعادة كتابة أسعار الكتالوج الحالية باستخدام السعر المعروض. لا تتغير الطلبات والمدفوعات السابقة.';

  @override
  String get currencyConverted => 'تم تحويل العملة.';

  @override
  String get conversionHistory => 'سجل التحويلات';

  @override
  String get selectCurrency => 'اختر عملة';

  @override
  String get sameCurrency => 'المتجر يستخدم هذه العملة بالفعل.';

  @override
  String get displayCurrency => 'عملة العرض';

  @override
  String get displayCurrencyHint =>
      'تفضيل خاص بك للعرض فقط. لا يغيّر أسعار مساحة العمل ولا المعاملات السابقة.';

  @override
  String get workspaceCurrencyHint =>
      'تتبع عملة المتجر الافتراضي. غيّرها من إعدادات عملة المتجر.';

  @override
  String get changeStoreCurrency => 'تغيير عملة المتجر';

  @override
  String get searchCurrencies => 'ابحث عن العملات بالاسم أو الرمز';

  @override
  String get noCurrenciesMatch => 'لا توجد عملات تطابق بحثك.';

  @override
  String decimalPlaces(Object count) {
    return '$count خانة عشرية';
  }

  @override
  String get timezone => 'المنطقة الزمنية';

  @override
  String get locale => 'اللغة';

  @override
  String get contactEmail => 'بريد التواصل';

  @override
  String get slug => 'المعرّف';

  @override
  String get readOnly => 'للقراءة فقط';

  @override
  String get invalidNumber => 'أدخل رقمًا.';

  @override
  String get mustBePositive => 'أدخل صفرًا أو رقمًا موجبًا.';

  @override
  String get confirmDelete => 'نعم، احذف';

  @override
  String get emailNotifications => 'البريد الإلكتروني';

  @override
  String get whatsappNotifications => 'واتساب';

  @override
  String get noProducts => 'لا منتجات تطابق التصفية.';

  @override
  String get noOrders => 'لا طلبات تطابق التصفية.';

  @override
  String get noCustomers => 'لا عملاء يطابقون التصفية.';

  @override
  String get noCategories => 'لا فئات بعد.';

  @override
  String get noInventory => 'لا سجلات مخزون بعد.';

  @override
  String get noConversations => 'لا محادثات تطابق التصفية.';

  @override
  String get addFirstProduct => 'أضف أول منتج';

  @override
  String get addFirstCustomer => 'أضف أول عميل';

  @override
  String get addFirstCategory => 'أضف أول فئة';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get customerDetails => 'تفاصيل العميل';

  @override
  String get productDetails => 'تفاصيل المنتج';

  @override
  String get inventoryDetails => 'تفاصيل المخزون';

  @override
  String get available => 'المتاح';

  @override
  String get reserved => 'المحجوز';

  @override
  String get threshold => 'حد المخزون المنخفض';

  @override
  String get store => 'المتجر';

  @override
  String get createdAt => 'تاريخ الإنشاء';

  @override
  String get updatedAt => 'آخر تحديث';

  @override
  String get sale => 'بيع';

  @override
  String get purchase => 'شراء';

  @override
  String get adjustment => 'تعديل';

  @override
  String get returnIn => 'مرتجع وارد';

  @override
  String get returnOut => 'مرتجع صادر';

  @override
  String get transferIn => 'تحويل وارد';

  @override
  String get transferOut => 'تحويل صادر';

  @override
  String get initial => 'رصيد افتتاحي';

  @override
  String get reference => 'المرجع';

  @override
  String get balanceAfter => 'الرصيد بعد';

  @override
  String get markAll => 'تحديد الكل';

  @override
  String get unreadOnly => 'غير المقروء فقط';

  @override
  String get readOnlyFilter => 'المقروء';

  @override
  String get severity => 'الأهمية';

  @override
  String get categoryFilter => 'الفئة';

  @override
  String get notificationsEmpty => 'لا إشعارات تطابق هذه التصفية.';

  @override
  String get pushNotifications => 'الإشعارات الفورية';

  @override
  String get inAppNotifications => 'الإشعارات داخل التطبيق';

  @override
  String get teamActivity => 'نشاط الفريق';

  @override
  String get securityAlerts => 'تنبيهات الأمان';

  @override
  String get mandatorySecurityHint => 'مفعّل دائمًا للحفاظ على أمان حسابك.';

  @override
  String get allCategories => 'كل الفئات';

  @override
  String get allSeverities => 'كل الأولويات';

  @override
  String get notificationNotFound => 'تعذر العثور على هذا الإشعار.';

  @override
  String get deleteNotificationConfirm =>
      'حذف هذا الإشعار؟ لا يمكن التراجع عن ذلك.';

  @override
  String get notificationDeleted => 'تم حذف الإشعار.';

  @override
  String get notificationDetail => 'تفاصيل الإشعار';

  @override
  String get openRelated => 'فتح العنصر المرتبط';

  @override
  String get categoryOrders => 'الطلبات';

  @override
  String get categoryInventory => 'المخزون';

  @override
  String get categoryMessages => 'الرسائل';

  @override
  String get categoryCustomers => 'العملاء';

  @override
  String get categoryBilling => 'الفوترة';

  @override
  String get categoryAi => 'رؤى الذكاء الاصطناعي';

  @override
  String get categoryApprovals => 'الموافقات';

  @override
  String get categorySecurity => 'الأمان';

  @override
  String get categoryReports => 'التقارير';

  @override
  String get categoryAnnouncements => 'الإعلانات';

  @override
  String get categoryTeam => 'الفريق';

  @override
  String get severityInfo => 'معلومة';

  @override
  String get severitySuccess => 'نجاح';

  @override
  String get severityWarning => 'تحذير';

  @override
  String get severityCritical => 'حرج';

  @override
  String get reply => 'رد';

  @override
  String get internal => 'داخلي';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get custom => 'مخصص';

  @override
  String get retryMessage => 'إعادة المحاولة';

  @override
  String get deliveryFailed => 'فشل الإرسال';

  @override
  String get sent => 'أُرسلت';

  @override
  String get deliveredStatus => 'تم التسليم';

  @override
  String get readStatus => 'مقروءة';

  @override
  String get pendingStatus => 'قيد الانتظار';

  @override
  String get failedStatus => 'فشلت';

  @override
  String get assign => 'إسناد';

  @override
  String get assignTo => 'إسناد إلى';

  @override
  String get me => 'أنا';

  @override
  String get allConversations => 'الكل';

  @override
  String get mine => 'الخاصة بي';

  @override
  String get unassignedFilter => 'غير مسندة';

  @override
  String get unreadFilter => 'غير مقروءة';

  @override
  String get sendTemplate => 'إرسال قالب';

  @override
  String get templateName => 'اسم القالب';

  @override
  String get languageCode => 'رمز اللغة';

  @override
  String get parameters => 'المعاملات';

  @override
  String get requiredParameters => 'قيمة واحدة في كل سطر.';

  @override
  String get photoPermissionDenied =>
      'تم رفض الوصول إلى الصور. فعّله من الإعدادات.';

  @override
  String get cameraPermissionDenied =>
      'تم رفض الوصول إلى الكاميرا. فعّله من الإعدادات.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get productImage => 'صورة المنتج';

  @override
  String get images => 'الصور';

  @override
  String get noImages => 'لا صور بعد.';

  @override
  String get defaultVariant => 'الخيار الافتراضي';

  @override
  String get variantName => 'اسم الخيار';

  @override
  String get addVariant => 'إضافة خيار';

  @override
  String get removeVariant => 'إزالة';

  @override
  String get stockLevel => 'مستوى المخزون';

  @override
  String get priceRequired => 'السعر مطلوب.';

  @override
  String get orderItemsRequired => 'أضف عنصرًا واحدًا على الأقل.';

  @override
  String get searchProducts => 'ابحث في المنتجات';

  @override
  String get searchCustomers => 'ابحث في العملاء';

  @override
  String get searchOrders => 'ابحث في الطلبات';

  @override
  String get searchConversations => 'ابحث في المحادثات';

  @override
  String get noResults => 'لا نتائج.';

  @override
  String get clearFilters => 'مسح التصفية';

  @override
  String get applyFilters => 'تطبيق التصفية';

  @override
  String resultsCount(Object count) {
    return '$count نتيجة';
  }

  @override
  String pageOf(Object last, Object page) {
    return 'الصفحة $page من $last';
  }

  @override
  String showingRange(Object from, Object to, Object total) {
    return 'عرض $from–$to من $total';
  }

  @override
  String get optionalNote => 'أضف ملاحظة (اختياري)';

  @override
  String get confirmStatusChange => 'تغيير الحالة؟';

  @override
  String statusChangeMessage(Object status) {
    return 'سينتقل الطلب إلى $status.';
  }

  @override
  String get orderTransitionNote => 'ملاحظة للسجل (اختياري)';

  @override
  String get paymentMarkPaid => 'تحديد كمدفوع';

  @override
  String get selectVariant => 'اختر خيارًا';

  @override
  String get add => 'إضافة';

  @override
  String get remove => 'إزالة';

  @override
  String quantityAvailable(Object count) {
    return '$count متاح';
  }

  @override
  String get insufficientStock => 'المخزون غير كافٍ لهذا العنصر.';

  @override
  String get workspace => 'مساحة العمل';

  @override
  String get switchAction => 'تبديل';

  @override
  String get notificationsChannelsUnavailable =>
      'بعض القنوات غير مهيأة على الخادم.';

  @override
  String get channelAvailable => 'متاحة';

  @override
  String get channelUnavailable => 'غير متاحة';

  @override
  String get savePreferences => 'حفظ التفضيلات';

  @override
  String get noPermissionTitle => 'الوصول مقيد';

  @override
  String get noPermissionMessage => 'دورك لا يتضمن الوصول إلى هذا القسم.';

  @override
  String get goToDashboard => 'الذهاب إلى لوحة التحكم';

  @override
  String get sessionRevokeConfirm => 'تسجيل خروج هذا الجهاز؟';

  @override
  String get sessionRevokeMessage =>
      'سيحتاج هذا الجهاز إلى تسجيل الدخول مرة أخرى.';

  @override
  String get revokeOthersConfirm => 'تسجيل خروج الأجهزة الأخرى؟';

  @override
  String get revokeOthersMessage =>
      'ستحتاج كل الأجهزة الأخرى إلى تسجيل الدخول مرة أخرى.';

  @override
  String get avatarRemoved => 'تمت إزالة صورة الملف الشخصي.';

  @override
  String get avatarUpdated => 'تم تحديث صورة الملف الشخصي.';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get currentPasswordIncorrect => 'كلمة المرور الحالية غير صحيحة.';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم النسخ.';

  @override
  String get details => 'التفاصيل';

  @override
  String get summary => 'الملخص';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get ordersLabel => 'الطلبات';

  @override
  String get average => 'المتوسط';

  @override
  String get growth => 'النمو';

  @override
  String get previousPeriod => 'الفترة السابقة';

  @override
  String get notMeasurable => 'لا توجد بيانات كافية';

  @override
  String get margin => 'الهامش';

  @override
  String get profit => 'الربح';

  @override
  String get costCoverage => 'تغطية التكلفة';

  @override
  String get stockValue => 'قيمة المخزون';

  @override
  String get conversationResponse => 'أول استجابة';

  @override
  String get deliveryRate => 'معدل التسليم';

  @override
  String get repeatPurchase => 'تكرار الشراء';

  @override
  String get noStore => 'لم يتم اختيار متجر';

  @override
  String get selectStore => 'اختر متجرًا';

  @override
  String get storeFilter => 'المتجر';

  @override
  String get errorLoading => 'تعذر تحميل هذه الشاشة.';

  @override
  String get seeMore => 'عرض المزيد';

  @override
  String get seeLess => 'عرض أقل';

  @override
  String get account => 'الحساب';

  @override
  String get approvals => 'الموافقات';

  @override
  String get attachment => 'مرفق';

  @override
  String get channelFilter => 'القناة';

  @override
  String get conversationAssignments => 'إسناد المحادثات';

  @override
  String get days => 'يومًا';

  @override
  String get deliveryFailures => 'فشل التسليم';

  @override
  String get forgotPasswordTitle => 'هل نسيت كلمة المرور؟';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيينها.';

  @override
  String get goodAfternoon => 'طاب مساؤك';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get isTaxableHint => 'تُحسب الضريبة بواسطة الخادم عند إنشاء الطلب.';

  @override
  String itemsCount(int count) {
    return '$count عنصرًا';
  }

  @override
  String get lastLogin => 'آخر تسجيل دخول';

  @override
  String get limitations => 'قيود البيانات';

  @override
  String get manual => 'يدوي';

  @override
  String get newMessages => 'رسائل جديدة';

  @override
  String get no => 'لا';

  @override
  String get noteHint => 'اكتب ملاحظة داخلية…';

  @override
  String get orderItems => 'عناصر الطلب';

  @override
  String get orderUpdates => 'تحديثات الطلبات';

  @override
  String get productNews => 'أخبار المنتجات';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get resetLinkSent => 'تحقق من بريدك';

  @override
  String get resetLinkSentMessage =>
      'إذا كان هذا البريد مسجلًا، فسيصلك رابط إعادة التعيين.';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get web => 'الويب';

  @override
  String get weeklySummary => 'الملخص الأسبوعي';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get yes => 'نعم';

  @override
  String get partially_paid => 'مدفوع جزئيًا';

  @override
  String get low_stock => 'مخزون منخفض';

  @override
  String get out_of_stock => 'نفد المخزون';

  @override
  String get healthy => 'سليم';

  @override
  String get failed => 'فشل';

  @override
  String get suspended => 'موقوف';

  @override
  String get read => 'مقروء';

  @override
  String get connected => 'متصل';

  @override
  String get reorder => 'إعادة طلب';

  @override
  String get invited => 'مدعو';

  @override
  String get critical => 'حرج';

  @override
  String get warning => 'تحذير';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجاح';

  @override
  String get pending_confirmation => 'بانتظار التأكيد';

  @override
  String get storefrontGroup => 'المتجر';

  @override
  String get storefrontSettings => 'إعدادات المتجر';

  @override
  String get shippingZones => 'مناطق الشحن';

  @override
  String get paymentSettings => 'إعدادات الدفع';

  @override
  String get noStores => 'لا توجد متاجر بعد';

  @override
  String get noStoresMessage => 'أنشئ متجرًا أولًا لتتمكن من إدارة إعداداته.';

  @override
  String get storefrontEnabled => 'المتجر منشور';

  @override
  String get storefrontEnabledHint =>
      'يمكن للعملاء تصفح المتجر وإتمام الطلبات.';

  @override
  String get storefrontDisabledHint => 'المتجر مخفي عن العملاء.';

  @override
  String get storefrontDisabledWarning =>
      'أثناء إيقاف النشر، يعيد رابط المتجر خطأ غير موجود.';

  @override
  String get branding => 'الهوية والمظهر';

  @override
  String get logoUrl => 'رابط الشعار';

  @override
  String get tagline => 'العبارة التعريفية';

  @override
  String get heroImageUrl => 'رابط صورة الغلاف';

  @override
  String get contactDetails => 'بيانات التواصل';

  @override
  String get whatsappNumber => 'رقم واتساب';

  @override
  String get address => 'العنوان';

  @override
  String get openingHours => 'ساعات العمل';

  @override
  String get socialLinks => 'روابط التواصل الاجتماعي';

  @override
  String get policies => 'السياسات';

  @override
  String get deliveryNote => 'ملاحظة التوصيل';

  @override
  String get returnPolicy => 'سياسة الإرجاع';

  @override
  String get showOutOfStock => 'إظهار المنتجات غير المتوفرة';

  @override
  String get showOutOfStockHint => 'تظهر في المتجر مع علامة نفد المخزون.';

  @override
  String get searchEngine => 'البحث والمشاركة';

  @override
  String get searchEngineHint => 'تُستخدم في نتائج البحث ومعاينات الروابط.';

  @override
  String get metaTitle => 'عنوان الصفحة';

  @override
  String get metaDescription => 'وصف الصفحة';

  @override
  String get storefrontUpdated => 'تم تحديث إعدادات المتجر.';

  @override
  String get addShippingZone => 'إضافة منطقة شحن';

  @override
  String get editShippingZone => 'تعديل منطقة الشحن';

  @override
  String get noShippingZones => 'لا توجد مناطق شحن بعد';

  @override
  String get noShippingZonesMessage => 'أضف منطقة لتحديد رسوم التوصيل.';

  @override
  String get shippingZonesIntro =>
      'تُطابق الرسوم المدينة أو المنطقة، ويُعاد حسابها على الخادم عند إتمام الطلب.';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get freeShippingOver => 'توصيل مجاني فوق';

  @override
  String get isActive => 'مفعّلة';

  @override
  String get zoneName => 'اسم المنطقة';

  @override
  String get englishHint =>
      'الإنجليزية هي النسخة الأساسية التي يراها العميل عند غياب الترجمة.';

  @override
  String get arabicHint =>
      'اختياري. يرى القارئ العربي النسخة الإنجليزية عند ترك الحقل فارغًا.';

  @override
  String get missingArabic => 'الترجمة العربية ناقصة';

  @override
  String get zoneDescription => 'وصف المنطقة';

  @override
  String get shippingMethodName => 'اسم طريقة التوصيل';

  @override
  String get shippingMethodNameHint =>
      'خيار التوصيل الذي يراه العميل عند إتمام الطلب.';

  @override
  String get shippingMethodDescription => 'وصف طريقة التوصيل';

  @override
  String get shippingMethodDescriptionHint =>
      'تفاصيل اختيارية تظهر أسفل خيار التوصيل.';

  @override
  String get deliveryInstructions => 'تعليمات التوصيل';

  @override
  String get deliveryInstructionsHint =>
      'ما يجب أن يعرفه العميل قبل وصول المندوب.';

  @override
  String get shippingTerms => 'شروط التوصيل';

  @override
  String get shippingTermsHint => 'شروط اختيارية تظهر للعميل لهذا الخيار.';

  @override
  String get city => 'المدينة';

  @override
  String get cityHint => 'اتركها فارغة لتطبيقها على كل المدن.';

  @override
  String get areas => 'المناطق';

  @override
  String get areasHint => 'افصل بين المناطق بفواصل.';

  @override
  String get freeShippingThreshold => 'حد التوصيل المجاني';

  @override
  String get freeShippingThresholdHint =>
      'اتركه فارغًا لتعطيل التوصيل المجاني.';

  @override
  String get enterNumber => 'أدخل رقمًا.';

  @override
  String get enterPositiveNumber => 'أدخل صفرًا أو رقمًا موجبًا.';

  @override
  String get enterWholeNumber => 'أدخل عددًا صحيحًا.';

  @override
  String get shippingZoneCreated => 'تم إنشاء منطقة الشحن.';

  @override
  String get shippingZoneUpdated => 'تم تحديث منطقة الشحن.';

  @override
  String deleteShippingZoneMessage(Object name) {
    return 'هل تريد حذف «$name»؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get shippingZoneDeleted => 'تم حذف منطقة الشحن.';

  @override
  String get paymentMethods => 'طرق الدفع';

  @override
  String get paymentsIntro =>
      'لا يرى العملاء إلا الطرق التي يستطيع المتجر تنفيذها فعليًا.';

  @override
  String get noPaymentMethods => 'لا توجد طرق دفع متاحة.';

  @override
  String get cashOnDelivery => 'الدفع عند الاستلام';

  @override
  String get codEnabled => 'تفعيل الدفع عند الاستلام';

  @override
  String get codEnabledHint => 'يبقى الطلب غير مدفوع حتى يحصّل المندوب المبلغ.';

  @override
  String get codInstructions => 'تعليمات الدفع';

  @override
  String get codInstructionsHint => 'تظهر للعميل عند إتمام الطلب.';

  @override
  String get onlinePaymentsNote =>
      'الدفع الإلكتروني غير متاح حتى يتم ربط مزوّد دفع. لا يتم خصم أي بطاقة ولا تسجيل دفع وهمي.';

  @override
  String get unavailable => 'غير متاحة';

  @override
  String get paymentSettingsUpdated => 'تم تحديث إعدادات الدفع.';

  @override
  String get aboutDukavo => 'عن دوكافو';

  @override
  String get aboutUs => 'من نحن';

  @override
  String get accessControl => 'التحكم في الوصول';

  @override
  String get accessToken => 'رمز الوصول';

  @override
  String get accessTokenHint => 'الرمز الصادر من مزوّد الرسائل.';

  @override
  String get action => 'الإجراء';

  @override
  String get actionType => 'نوع الإجراء';

  @override
  String get activateTenant => 'تفعيل';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String get addedToCart => 'أُضيف إلى السلة';

  @override
  String get addressLineOne => 'سطر العنوان الأول';

  @override
  String get addressLineTwo => 'سطر العنوان الثاني';

  @override
  String get aiActions => 'إجراءات الذكاء الاصطناعي';

  @override
  String get aiSettings => 'إعدادات الذكاء الاصطناعي';

  @override
  String get aiSettingsByokLabel => 'التوجيه عبر مفاتيحي';

  @override
  String get aiSettingsByokOff =>
      'لم تفعّل المنصة خاصية إحضار مفتاحك الخاص، فلا تستطيع هذه المساحة حفظ مفاتيح المزودين الخاصة بها.';

  @override
  String get aiSettingsByokOptedIn => 'تفضّل هذه المساحة الآن مفاتيحها الخاصة.';

  @override
  String get aiSettingsByokOptedOut => 'عادت هذه المساحة إلى مفاتيح المنصة.';

  @override
  String get aiSettingsByokSubtitle =>
      'عند التفعيل، تفضّل مهام هذه المساحة بيانات اعتمادك على بيانات المنصة، مع مزودي المنصة كاحتياط.';

  @override
  String get aiSettingsByokTitle => 'إحضار مفتاحك الخاص';

  @override
  String get aiSettingsFeatureDisabled => 'تم تعطيل الميزة لمساحة العمل هذه.';

  @override
  String get aiSettingsFeatureEnabled => 'تم تفعيل الميزة لمساحة العمل هذه.';

  @override
  String get aiSettingsFeaturePlatformOff =>
      'الميزة معطّلة على مستوى المنصة، فلا يمكن تفعيلها من هنا.';

  @override
  String get aiSettingsFeaturesSubtitle =>
      'إيقاف ميزة هنا يخص هذه المساحة فقط؛ لا تتأثر بقية المساحات.';

  @override
  String get aiSettingsFeaturesTitle => 'الميزات';

  @override
  String get aiSettingsKeyApiKeyHint =>
      'الصق المفتاح مرة واحدة؛ لن يظهر مجددًا أبدًا.';

  @override
  String get aiSettingsKeyApiKeyLabel => 'مفتاح API';

  @override
  String get aiSettingsKeyBaseUrlHint =>
      'اختياري. يجب أن تكون نقطة نهاية عامة للمزود — تُرفض العناوين المحلية والخاصة.';

  @override
  String get aiSettingsKeyBaseUrlLabel => 'عنوان الأساس';

  @override
  String get aiSettingsKeyFormHint =>
      'إعادة الحفظ للمزود نفسه تستبدل مفتاح ذلك المزود.';

  @override
  String get aiSettingsKeyFormTitle => 'حفظ مفتاح أو تبديله';

  @override
  String get aiSettingsKeyModelLabel => 'النموذج الافتراضي';

  @override
  String get aiSettingsKeyProviderLabel => 'المزود';

  @override
  String aiSettingsKeyRevokeBody(Object masked, Object provider) {
    return 'إلغاء $masked على $provider؟ يعود التوجيه إلى مزودي المنصة.';
  }

  @override
  String get aiSettingsKeyRevokeTitle => 'إلغاء هذا المفتاح';

  @override
  String get aiSettingsKeyRevoked => 'تم إلغاء المفتاح.';

  @override
  String get aiSettingsKeyStored => 'تم حفظ المفتاح.';

  @override
  String get aiSettingsKeyTest => 'اختبار';

  @override
  String get aiSettingsKeyTestFailed => 'فشل فحص الاتصال.';

  @override
  String aiSettingsKeyTestOk(Object latency) {
    return 'أجاب مفتاحك خلال $latency ملي ثانية.';
  }

  @override
  String get aiSettingsKeyTooShort => 'استخدم 8 أحرف على الأقل.';

  @override
  String get aiSettingsKeysEmpty => 'لا مفاتيح محفوظة.';

  @override
  String get aiSettingsKeysSubtitle =>
      'مفتاحك مشفّر في التخزين ولا يُعرض إلا أحرفه الأخيرة.';

  @override
  String get aiSettingsKeysTitle => 'مفاتيحي';

  @override
  String get aiSettingsNoProviders => 'لا مزودين متاحين لمفتاح مساحة عمل.';

  @override
  String get aiSettingsPlatformOffBody =>
      'الذكاء الاصطناعي متوقّف على مستوى المنصة بأكملها. لن يعمل أي شيء هنا حتى يفعّله فريق Dukavo.';

  @override
  String get aiSettingsPlatformOffTitle => 'معطّل على مستوى المنصة';

  @override
  String get aiSettingsUsageCost => 'التكلفة التقديرية';

  @override
  String get aiSettingsUsageEstimatesNote =>
      'التكاليف تقديرات من أسعار النماذج المعلنة — إشارة تشغيلية، وليست رقم فوترة أبدًا.';

  @override
  String get aiSettingsUsageFailures => 'الطلبات الفاشلة';

  @override
  String aiSettingsUsageRow(Object requests, Object tokens) {
    return '$requests طلبًا · $tokens رمزًا';
  }

  @override
  String get aiSettingsUsageTitle => 'استخدام الذكاء الاصطناعي';

  @override
  String get aiSettingsUsageTodayRequests => 'طلبات اليوم';

  @override
  String get aiSettingsUsageTodayTokens => 'رموز اليوم';

  @override
  String get altText => 'النص البديل';

  @override
  String get altTextHint => 'صف الصورة لقارئات الشاشة.';

  @override
  String get answer => 'الإجابة';

  @override
  String get answerAr => 'الإجابة (بالعربية)';

  @override
  String get approve => 'موافقة';

  @override
  String get approved => 'تمت الموافقة';

  @override
  String get area => 'المنطقة';

  @override
  String get areaHint => 'منطقة التوصيل داخل المدينة.';

  @override
  String get auditLog => 'سجل التدقيق';

  @override
  String get auditLogHint => 'كل تغيير حساس، مع من قام به ومتى.';

  @override
  String get automationActionsHint => 'ما تفعله القاعدة عند تحقق شروطها.';

  @override
  String get automationHub => 'الأتمتة';

  @override
  String get automationHubHint => 'قواعد تتفاعل مع أحداث المتجر.';

  @override
  String get automationRules => 'القواعد';

  @override
  String get automationRulesHint => 'المُشغّل والشروط والإجراءات.';

  @override
  String get automationRuns => 'التنفيذات';

  @override
  String get automationRunsHint => 'كل مرة تم تقييم قاعدة فيها.';

  @override
  String get automationTasks => 'المهام';

  @override
  String get automationTasksHint => 'أعمال مؤجلة أنشأتها الأتمتة.';

  @override
  String get automations => 'الأتمتة';

  @override
  String get billingInterval => 'دورة الفوترة';

  @override
  String get bodyHtml => 'المحتوى (HTML)';

  @override
  String get bodyHtmlAr => 'المحتوى (HTML بالعربية)';

  @override
  String get bodyHtmlHint => 'نص المقال كاملًا بصيغة HTML.';

  @override
  String get browseShop => 'تصفح متجرًا';

  @override
  String get bundleItems => 'عناصر الحزمة';

  @override
  String get bundleItemsHint =>
      'قائمة JSON بمعرّفات متغيّرات المنتجات والكميات.';

  @override
  String get bundles => 'الحزم';

  @override
  String get businessAccountId => 'معرّف حساب الأعمال';

  @override
  String get businessType => 'نوع النشاط';

  @override
  String get calculatedByStore => 'يُحسب بواسطة المتجر';

  @override
  String get cancelledOrders => 'الطلبات الملغاة';

  @override
  String get cart => 'السلة';

  @override
  String get cartEmpty => 'سلتك فارغة';

  @override
  String get cartEmptyHint => 'أضف منتجًا لبدء طلب.';

  @override
  String get catalogue => 'الكتالوج';

  @override
  String get checkout => 'إتمام الطلب';

  @override
  String get chooseDeliveryCity => 'اختر مدينة التوصيل.';

  @override
  String get chooseVariant => 'اختر متغيّرًا';

  @override
  String get classification => 'التصنيف';

  @override
  String get cogs => 'تكلفة البضاعة';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get company => 'الشركة';

  @override
  String get completed => 'مكتمل';

  @override
  String get completedAt => 'اكتمل في';

  @override
  String get conditions => 'الشروط';

  @override
  String get conditionsHint => 'شروط JSON يجب أن تتحقق جميعها.';

  @override
  String get connectedAt => 'تم الاتصال في';

  @override
  String get contactAttempts => 'محاولات التواصل';

  @override
  String get contactMessages => 'رسائل التواصل';

  @override
  String get contactMessagesHint => 'الرسائل المرسلة عبر نموذج التواصل العام.';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get contactUsHint => 'أرسل لنا رسالة وسنرد عبر البريد الإلكتروني.';

  @override
  String get content => 'المحتوى';

  @override
  String get contentPages => 'صفحات المحتوى';

  @override
  String get contentPagesHint => 'صفحات قانونية ومعلوماتية قابلة للتعديل.';

  @override
  String get context => 'السياق';

  @override
  String get continueShopping => 'متابعة التسوق';

  @override
  String get cooldownSeconds => 'فترة الانتظار (ثوانٍ)';

  @override
  String get costIncomplete => 'بيانات التكلفة غير مكتملة';

  @override
  String get countryCode => 'رمز الدولة';

  @override
  String get countryCodeHint => 'رمز ISO من حرفين، مثل SA.';

  @override
  String get createAutomation => 'أتمتة جديدة';

  @override
  String get createTeamMember => 'دعوة عضو فريق';

  @override
  String get currencyCodeHint => 'رمز ISO من ثلاثة أحرف، مثل SAR.';

  @override
  String get dailyDemand => 'الطلب اليومي';

  @override
  String get daysOfCover => 'أيام التغطية';

  @override
  String get decrease => 'تقليل';

  @override
  String get defaultLabel => 'افتراضي';

  @override
  String get defaultStore => 'المتجر الافتراضي';

  @override
  String get deleteImage => 'حذف الصورة';

  @override
  String get deleteImageMessage => 'حذف هذه الصورة؟ لا يمكن التراجع.';

  @override
  String get deleted => 'محذوف';

  @override
  String get delivery => 'التوصيل';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get detectedAt => 'تم الاكتشاف في';

  @override
  String get disconnectAccount => 'فصل الحساب';

  @override
  String get disconnected => 'غير متصل';

  @override
  String get discountType => 'نوع الخصم';

  @override
  String get discountValue => 'قيمة الخصم';

  @override
  String get discounts => 'الخصومات';

  @override
  String get dismissalReason => 'سبب الاستبعاد';

  @override
  String get dismissed => 'مستبعد';

  @override
  String get disqualified => 'غير مؤهل';

  @override
  String get doNotContact => 'لا تتواصل';

  @override
  String get draftMessage => 'مسودة الرسالة';

  @override
  String get dueAt => 'مستحق في';

  @override
  String get editAltText => 'تعديل النص البديل';

  @override
  String get editTeamMember => 'تعديل عضو الفريق';

  @override
  String get errorMessage => 'رسالة الخطأ';

  @override
  String get estimatedTotal => 'الإجمالي التقديري';

  @override
  String get estimatedValue => 'القيمة التقديرية';

  @override
  String get event => 'الحدث';

  @override
  String get excerpt => 'المقتطف';

  @override
  String get excerptAr => 'المقتطف (بالعربية)';

  @override
  String get execute => 'تنفيذ';

  @override
  String get executed => 'تم التنفيذ';

  @override
  String get expired => 'منتهي';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String exportSaved(Object path) {
    return 'تم الحفظ في $path';
  }

  @override
  String get faqEntries => 'أسئلة شائعة';

  @override
  String get faqEntriesHint => 'الأسئلة المعروضة في صفحة الأسئلة الشائعة.';

  @override
  String get features => 'المزايا';

  @override
  String get finalTotalOnConfirmation =>
      'يؤكد المتجر الإجمالي النهائي بعد التحقق من المخزون والتوصيل.';

  @override
  String get finishedAt => 'انتهى في';

  @override
  String get firstStoreName => 'اسم المتجر الأول';

  @override
  String get firstStoreNameHint =>
      'تبدأ مساحتك بمتجر واحد. يمكنك إضافة المزيد لاحقًا.';

  @override
  String get fixed => 'ثابت';

  @override
  String get followUpSent => 'تم إرسال المتابعة';

  @override
  String get free => 'مجاني';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get grossProfit => 'الربح الإجمالي';

  @override
  String get growthSeries => 'سلسلة النمو';

  @override
  String get growthSeriesHint => 'القيمة المستردة يوميًا خلال الفترة المحددة.';

  @override
  String get highlighted => 'مميّز';

  @override
  String get imageTooLarge => 'هذه الصورة كبيرة جدًا.';

  @override
  String get imagesUploaded => 'تم رفع الصور.';

  @override
  String get increase => 'زيادة';

  @override
  String get information => 'معلومات';

  @override
  String get insights => 'الرؤى';

  @override
  String get insufficientHistory => 'لا يوجد سجل كافٍ للتنبؤ بعد.';

  @override
  String get intro => 'مقدمة';

  @override
  String get invalidJson => 'أدخل JSON صالحًا.';

  @override
  String get inventoryIntelligence => 'ذكاء المخزون';

  @override
  String get inviteTeamMember => 'دعوة عضو';

  @override
  String get ipAddress => 'عنوان IP';

  @override
  String get itemCount => 'عدد العناصر';

  @override
  String get joinWaitlist => 'انضم إلى قائمة الانتظار';

  @override
  String get joined => 'انضم';

  @override
  String get lastContactedAt => 'آخر تواصل';

  @override
  String get lastTriggered => 'آخر تشغيل';

  @override
  String lastUpdated(Object date) {
    return 'آخر تحديث $date';
  }

  @override
  String get leadsAndAudience => 'العملاء المحتملون والجمهور';

  @override
  String get limitationsHint => 'ما لا يستطيع هذا التقرير قياسه بعد.';

  @override
  String get limits => 'الحدود';

  @override
  String get localeHint => 'رمز اللغة، مثل en أو ar.';

  @override
  String get makeDefault => 'اجعلها افتراضية';

  @override
  String get markCompleted => 'تحديد كمكتمل';

  @override
  String get marketing => 'التسويق';

  @override
  String get marketingHub => 'التسويق';

  @override
  String get marketingHubHint => 'المحتوى العام والخطط والأسئلة والجمهور.';

  @override
  String get matched => 'متطابق';

  @override
  String get members => 'الأعضاء';

  @override
  String get merchantWorkspace => 'مساحة التاجر';

  @override
  String get message => 'الرسالة';

  @override
  String get messageSentHint => 'نرد على البريد الإلكتروني الذي تقدّمه.';

  @override
  String get monthly => 'شهري';

  @override
  String get moveDown => 'تحريك لأسفل';

  @override
  String get moveUp => 'تحريك لأعلى';

  @override
  String get netSales => 'صافي المبيعات';

  @override
  String get newInPeriod => 'جديد خلال الفترة';

  @override
  String get newStatus => 'جديد';

  @override
  String get newValues => 'القيم الجديدة';

  @override
  String get newsletter => 'النشرة البريدية';

  @override
  String get newsletters => 'النشرات البريدية';

  @override
  String get newslettersHint => 'المقالات المنشورة في النشرة العامة.';

  @override
  String get nextFollowUpAt => 'المتابعة التالية';

  @override
  String get noAiActions => 'لا توجد إجراءات ذكاء اصطناعي بعد';

  @override
  String get noAltText => 'لا يوجد نص بديل';

  @override
  String get noAuditEntries => 'لا توجد سجلات تدقيق';

  @override
  String get noAutomationRules => 'لا توجد قواعد أتمتة';

  @override
  String get noAutomationRuns => 'لا توجد تنفيذات بعد';

  @override
  String get noAutomationTasks => 'لا توجد مهام بعد';

  @override
  String get noBundles => 'لا توجد حزم بعد';

  @override
  String get noContactMessages => 'لا توجد رسائل تواصل';

  @override
  String get noContentPages => 'لا توجد صفحات محتوى';

  @override
  String get noFaqEntries => 'لا توجد أسئلة شائعة';

  @override
  String get noFeatures => 'لا توجد مزايا مدرجة';

  @override
  String get noMembers => 'لا يوجد أعضاء';

  @override
  String get noNewsletters => 'لا توجد نشرات بريدية';

  @override
  String get noPlatformUsers => 'لا يوجد مستخدمو منصة';

  @override
  String get noPreviousData => 'لا توجد بيانات سابقة';

  @override
  String get noPricingPlans => 'لا توجد خطط تسعير';

  @override
  String get noRecoveryOpportunities => 'لا توجد فرص استرداد';

  @override
  String get noRoles => 'لا توجد أدوار';

  @override
  String get noSubscribers => 'لا يوجد مشتركون';

  @override
  String get noTeamMembers => 'لا يوجد أعضاء فريق';

  @override
  String get noTenants => 'لا يوجد مستأجرون';

  @override
  String get noWaitlistEntries => 'لا توجد مدخلات قائمة انتظار';

  @override
  String get noWhatsappAccounts => 'لا توجد حسابات واتساب';

  @override
  String get oldValues => 'القيم القديمة';

  @override
  String get oneTime => 'مرة واحدة';

  @override
  String onlyLeft(Object count) {
    return 'تبقّى $count فقط';
  }

  @override
  String get openValue => 'القيمة المفتوحة';

  @override
  String get orderConfirmed => 'تم تأكيد الطلب';

  @override
  String get orderNotes => 'ملاحظات الطلب';

  @override
  String get orderPlacedNoTracking =>
      'تم تقديم الطلب، لكن لم يُرجع رابط تتبّع.';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get orderTracking => 'تتبّع الطلب';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get pageKey => 'مفتاح الصفحة';

  @override
  String get passwordMinHint => '8 أحرف على الأقل.';

  @override
  String get paused => 'متوقف مؤقتًا';

  @override
  String get payload => 'الحمولة';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get pendingApproval => 'بانتظار الموافقة';

  @override
  String get percentage => 'نسبة مئوية';

  @override
  String get permissions => 'الصلاحيات';

  @override
  String get permissionsHint => 'اختر ما يستطيع هذا الدور فعله.';

  @override
  String get phoneNumberId => 'معرّف رقم الهاتف';

  @override
  String get placeOrder => 'تأكيد الطلب';

  @override
  String get platformConsole => 'لوحة المنصة';

  @override
  String get platformOverview => 'نظرة عامة على المنصة';

  @override
  String get platformPasswordSelfService =>
      'تغيّر حسابات المنصة كلمة المرور من ملفها الشخصي.';

  @override
  String get platformRoles => 'أدوار المنصة';

  @override
  String get platformScope => 'المنصة';

  @override
  String get platformUsers => 'مستخدمو المنصة';

  @override
  String get position => 'الترتيب';

  @override
  String get postalCode => 'الرمز البريدي';

  @override
  String get priceComingSoonHint =>
      'التسعير غير مفعّل بعد؛ اتركه فارغًا إن لم يوجد سعر.';

  @override
  String get pricing => 'التسعير';

  @override
  String get pricingComingSoon => 'التسعير قريبًا.';

  @override
  String get pricingPlans => 'خطط التسعير';

  @override
  String get pricingPlansHint => 'الخطط المعروضة في صفحة التسعير العامة.';

  @override
  String get pricingSubtitle => 'خطط بسيطة تنمو مع متجرك.';

  @override
  String get priority => 'الأولوية';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get proceedToCheckout => 'المتابعة إلى الدفع';

  @override
  String get productImages => 'صور المنتج';

  @override
  String get productImagesHint => 'ارفع الصور وأعد ترتيبها وصف كل صورة.';

  @override
  String get productImagesLimits =>
      'JPEG أو PNG أو WebP حتى 5 ميغابايت لكل صورة.';

  @override
  String get published => 'منشور';

  @override
  String get publishedAt => 'نُشر في';

  @override
  String get question => 'السؤال';

  @override
  String get questionAr => 'السؤال (بالعربية)';

  @override
  String readingMinutes(Object count) {
    return '$count دقيقة قراءة';
  }

  @override
  String get readyToRecover => 'جاهز للاسترداد';

  @override
  String get reason => 'السبب';

  @override
  String get recommended => 'موصى به';

  @override
  String get recovered => 'مسترد';

  @override
  String get recoveredRevenue => 'الإيرادات المستردة';

  @override
  String get recoveredValue => 'القيمة المستردة';

  @override
  String get recovery => 'الاسترداد';

  @override
  String get recoveryOpportunities => 'فرص الاسترداد';

  @override
  String get recoverySummary => 'ملخص الاسترداد';

  @override
  String get recoverySummaryUnavailable => 'ملخص الاسترداد غير متاح.';

  @override
  String get reject => 'رفض';

  @override
  String get rejected => 'مرفوض';

  @override
  String get rejectionReason => 'سبب الرفض';

  @override
  String get replied => 'تم الرد';

  @override
  String get resourceType => 'نوع المورد';

  @override
  String get responded => 'تم الرد';

  @override
  String get result => 'النتيجة';

  @override
  String get role => 'الدور';

  @override
  String get roles => 'الأدوار';

  @override
  String get rolesAndWorkspaces => 'الأدوار ومساحات العمل';

  @override
  String get rolesHint => 'تحكم بما يستطيع كل عضو فريق رؤيته وفعله.';

  @override
  String get runCount => 'عدد التشغيلات';

  @override
  String get saveTrackingLink => 'احفظ هذا الرابط للتحقق من الطلب لاحقًا.';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get scope => 'النطاق';

  @override
  String get sectionsJson => 'الأقسام (JSON)';

  @override
  String get sectionsJsonHint => 'مصفوفة JSON لأقسام المحتوى.';

  @override
  String get seePricing => 'عرض التسعير';

  @override
  String selectedCount(Object count) {
    return 'تم تحديد $count';
  }

  @override
  String get send => 'إرسال';

  @override
  String get sendAnotherMessage => 'إرسال رسالة أخرى';

  @override
  String get setPrimary => 'تعيين كصورة رئيسية';

  @override
  String get shippingRevenue => 'إيرادات التوصيل';

  @override
  String get shop => 'المتجر';

  @override
  String get shopLinkRequired => 'افتح رابط متجر';

  @override
  String shopLinkRequiredHint(Object store, Object tenant) {
    return 'يبدو رابط المتجر هكذا /shop/$tenant/$store. اطلب الرابط من التاجر.';
  }

  @override
  String get siteHeroSubtitle => 'منصة التجارة للتجار العصريين.';

  @override
  String get slugHint => 'أحرف صغيرة وأرقام وشرطات.';

  @override
  String get snoozed => 'مؤجل';

  @override
  String get sortName => 'الاسم';

  @override
  String get sortNewest => 'الأحدث';

  @override
  String get sortPriceHigh => 'السعر: من الأعلى إلى الأقل';

  @override
  String get sortPriceLow => 'السعر: من الأقل إلى الأعلى';

  @override
  String get sortRecommended => 'موصى به';

  @override
  String get source => 'المصدر';

  @override
  String get startedAt => 'بدأ في';

  @override
  String get state => 'الولاية / المحافظة';

  @override
  String get stillHaveQuestions => 'لا تزال لديك أسئلة؟';

  @override
  String get storeId => 'معرّف المتجر';

  @override
  String get stores => 'المتاجر';

  @override
  String get storesCount => 'المتاجر';

  @override
  String get subject => 'الموضوع';

  @override
  String get submitForApproval => 'إرسال للموافقة';

  @override
  String get subscribe => 'اشترك';

  @override
  String get subscribeToNewsletter => 'اشترك في نشرتنا البريدية';

  @override
  String get subscribeToNewsletterHint =>
      'تحديثات المنتج ونصائح التجار، دون إزعاج.';

  @override
  String get subscribed => 'مشترك';

  @override
  String get subscribedAt => 'تاريخ الاشتراك';

  @override
  String get subscribers => 'المشتركون';

  @override
  String get subscribersHint => 'الأشخاص الذين وافقوا على النشرة البريدية.';

  @override
  String get subtotalEstimate => 'تقدير المجموع الفرعي';

  @override
  String get suggestedOrder => 'الطلب المقترح';

  @override
  String get superAdmin => 'مدير أعلى';

  @override
  String get suspendTenant => 'تعليق';

  @override
  String get systemRole => 'دور نظام';

  @override
  String get systemRolePermissionsLocked =>
      'لا يمكن تغيير صلاحيات أدوار النظام.';

  @override
  String get taxCollected => 'الضريبة المحصلة';

  @override
  String get teamAndAccess => 'الفريق والوصول';

  @override
  String get teamHub => 'الفريق';

  @override
  String get teamHubHint => 'الأشخاص والأدوار وسجل التدقيق.';

  @override
  String get teamMembers => 'أعضاء الفريق';

  @override
  String get teamMembersHint => 'ادعُ أشخاصًا وأدر صلاحياتهم.';

  @override
  String get tenantScope => 'مساحة العمل';

  @override
  String get tenants => 'المستأجرون';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get timezoneHint => 'منطقة زمنية IANA، مثل Asia/Riyadh.';

  @override
  String get title => 'العنوان';

  @override
  String get titleAr => 'العنوان (بالعربية)';

  @override
  String get tooManyImages => 'يمكنك رفع 8 صور كحد أقصى في المرة.';

  @override
  String get totalsResolvedAtCheckout =>
      'يحدد المتجر الإجمالي النهائي عند إتمام الطلب.';

  @override
  String get findOrder => 'البحث عن الطلب';

  @override
  String get track => 'تتبّع';

  @override
  String get trackOrder => 'تتبّع طلبًا';

  @override
  String get trackOrderHelp =>
      'الصق رمز التتبّع أو رابط التتبّع من رسالة التأكيد.';

  @override
  String get trackingToken => 'رمز التتبّع';

  @override
  String get trackingTokenHint => 'الرمز من تأكيد طلبك.';

  @override
  String get trigger => 'المُشغّل';

  @override
  String get triggerConversationMessage => 'رسالة محادثة';

  @override
  String get triggerInventoryLowStock => 'مخزون منخفض';

  @override
  String get triggerOrderCreated => 'تم إنشاء طلب';

  @override
  String get triggerOrderStatusChanged => 'تغيّر حالة الطلب';

  @override
  String get triggerRecoveryDetected => 'تم اكتشاف استرداد';

  @override
  String get unsubscribed => 'غير مشترك';

  @override
  String get unsubscribedAt => 'تاريخ إلغاء الاشتراك';

  @override
  String get uploadImages => 'رفع الصور';

  @override
  String get userAccounts => 'حسابات المستخدمين';

  @override
  String get users => 'المستخدمون';

  @override
  String get usersCount => 'المستخدمون';

  @override
  String get verifyAccount => 'التحقق من الحساب';

  @override
  String get viewDukavo => 'عرض دوكافو';

  @override
  String get waitlist => 'قائمة الانتظار';

  @override
  String get waitlistHint => 'الأشخاص المنتظرون لدعوة.';

  @override
  String get waitlistJoined => 'أنت على القائمة';

  @override
  String get waitlistJoinedHint => 'سنراسلك عبر البريد عند توفر مكان.';

  @override
  String get webhookVerifyToken => 'رمز التحقق من Webhook';

  @override
  String get webhookVerifyTokenHint =>
      'يُستخدم للتحقق من استدعاءات Webhook الواردة.';

  @override
  String get whatsappAccounts => 'حسابات واتساب';

  @override
  String get workspaces => 'مساحات العمل';

  @override
  String get yearly => 'سنوي';

  @override
  String get newLabel => 'جديد';

  @override
  String get pending_approval => 'بانتظار الموافقة';

  @override
  String get contacted => 'تم التواصل';

  @override
  String get eligible => 'مؤهل';

  @override
  String get platform => 'المنصة';

  @override
  String get tenant => 'مساحة العمل';

  @override
  String get splashTagline => 'كل تجارتك في مكان واحد';

  @override
  String get splashPreparing => 'نجهز مساحتك…';

  @override
  String get splashAi => 'أتمتة بالذكاء الاصطناعي';

  @override
  String get publicNavHome => 'الرئيسية';

  @override
  String get publicNavFeatures => 'المزايا';

  @override
  String get publicNavPricing => 'الأسعار';

  @override
  String get publicNavAbout => 'من نحن';

  @override
  String get publicNavMore => 'المزيد';

  @override
  String get publicNavHowItWorks => 'كيف يعمل';

  @override
  String get publicNavFaq => 'الأسئلة الشائعة';

  @override
  String get publicNavBlog => 'المدونة';

  @override
  String get publicNavContact => 'اتصل بنا';

  @override
  String get publicOpenApp => 'افتح مساحة العمل';

  @override
  String get publicBackToSite => 'العودة إلى الموقع';

  @override
  String get publicExplore => 'اكتشف Dukavo';

  @override
  String get publicRegister => 'إنشاء حساب';

  @override
  String publicCopyright(Object year) {
    return '© $year Dukavo. جميع الحقوق محفوظة.';
  }

  @override
  String get publicLoginInviteOnly => 'الحسابات تُنشأ بدعوة.';

  @override
  String get publicRegisterHaveAccount => 'لديك حساب؟ سجّل الدخول';

  @override
  String get publicFooterTagline => 'إدارة عمليات البيع للمشاريع النامية.';

  @override
  String get publicFooterProduct => 'المنتج';

  @override
  String get publicFooterResources => 'الموارد';

  @override
  String get publicFooterCompany => 'الشركة';

  @override
  String get publicFooterLegal => 'قانوني';

  @override
  String get publicMenuExplore => 'استكشف';

  @override
  String get publicMenuAccount => 'الحساب';

  @override
  String get publicMenuPreferences => 'التفضيلات';

  @override
  String get publicMenuLegal => 'قانوني';

  @override
  String get publicMenuOpenAppHint => 'تابع إلى مساحة عملك';

  @override
  String get publicMenuSignInHint => 'سجّل الدخول لإدارة متجرك';

  @override
  String get publicHomeBadge => 'منصة تجارة مصممة للعربية أولًا';

  @override
  String get publicHomeTitleLine1 => 'أدر متجرك بالكامل';

  @override
  String get publicHomeTitleFrom => 'من';

  @override
  String get publicHomeTitleAccent => 'مكان واحد';

  @override
  String get publicHomeSubtitle =>
      'المنتجات، المخزون، الطلبات، العملاء ومحادثات WhatsApp — كل ما تحتاجه لإدارة تجارتك في منصة واحدة.';

  @override
  String get publicHomePrimary => 'انضم لقائمة الانتظار';

  @override
  String get publicHomeSecondary => 'شاهد كيف يعمل Dukavo';

  @override
  String get publicHomeTickArabic => 'عربي أولًا';

  @override
  String get publicHomeTickWhatsapp => 'WhatsApp مدمج';

  @override
  String get publicHomeTickTeam => 'صلاحيات للفريق';

  @override
  String get publicHomeEcosystemLabel => 'ما الذي يعمل على Dukavo';

  @override
  String get publicHomeEcosystemProducts => 'المنتجات';

  @override
  String get publicHomeEcosystemInventory => 'المخزون';

  @override
  String get publicHomeEcosystemOrders => 'الطلبات';

  @override
  String get publicHomeEcosystemCustomers => 'العملاء';

  @override
  String get publicHomeEcosystemConversations => 'المحادثات';

  @override
  String get publicHomeEcosystemTeam => 'الفريق';

  @override
  String get publicHomePillarsEyebrow => 'المزايا';

  @override
  String get publicHomePillarsTitle => 'خمس ركائز، نظام واحد';

  @override
  String get publicHomePillarsSubtitle =>
      'مكان واحد للمنتجات والمخزون والطلبات والعملاء والمحادثات.';

  @override
  String get publicHomeStoryEyebrow => 'من المحادثة إلى الطلب';

  @override
  String get publicHomeStoryTitle => 'بدون فوضى';

  @override
  String get publicHomeStorySubtitle => 'الخطوات الخمس نفسها في كل مرة.';

  @override
  String get publicHomePricingEyebrow => 'الأسعار';

  @override
  String get publicHomePricingTitle => 'خطط تنمو مع تجارتك';

  @override
  String get publicHomePricingSubtitle =>
      'الأسعار النهائية قيد الإعداد. انضم إلى قائمة الانتظار لتصلك أولًا.';

  @override
  String get publicHomeFaqEyebrow => 'الأسئلة الشائعة';

  @override
  String get publicHomeFaqTitle => 'أسئلة قد تخطر ببالك';

  @override
  String get publicHomeBlogEyebrow => 'المدونة والنشرة';

  @override
  String get publicHomeBlogTitle => 'أفكار لتجارة أكثر تنظيمًا';

  @override
  String get publicHomeCtaTitle => 'جاهز لتنظيم تجارتك معنا؟';

  @override
  String get publicHomeCtaBody =>
      'انضم لقائمة الانتظار وسنجهّز منتجاتك وطلباتك وعملاءك ومحادثاتك معًا.';

  @override
  String get publicHomeCtaAction => 'انضم لقائمة الانتظار';

  @override
  String get publicStepConversationTitle => 'المحادثة';

  @override
  String get publicStepConversationBody =>
      'يكتب العميل على WhatsApp، وتصل رسالته إلى صندوق Dukavo.';

  @override
  String get publicStepCustomerTitle => 'العميل';

  @override
  String get publicStepCustomerBody =>
      'يتعرف Dukavo على العميل ويفتح ملفه مع كامل تاريخه.';

  @override
  String get publicStepOrderTitle => 'الطلب';

  @override
  String get publicStepOrderBody => 'يتحول الكلام إلى طلب منظم بعناصره وحالته.';

  @override
  String get publicStepInventoryTitle => 'المخزون';

  @override
  String get publicStepInventoryBody =>
      'تنقص الكمية تلقائيًا، مع تنبيه عند اقتراب النفاد.';

  @override
  String get publicStepTeamTitle => 'الفريق';

  @override
  String get publicStepTeamBody =>
      'كل موظف يرى ويفعل ما سمحت له به الصلاحيات فقط.';

  @override
  String get publicFeaturesTitle => 'كل ما تحتاجه لإدارة تجارتك بفعالية';

  @override
  String get publicFeaturesSubtitle =>
      'القدرات المتاحة اليوم، وما هو في الطريق.';

  @override
  String get publicFeaturesAvailable => 'متاح الآن';

  @override
  String get publicFeaturesAvailableHint =>
      'هذه القدرات متاحة في مساحة عمل التاجر.';

  @override
  String get publicFeaturesUpcoming => 'قريبًا';

  @override
  String get publicFeaturesUpcomingHint => 'قدرات مخططة، نعرضها بصدق حتى تصدر.';

  @override
  String get publicFeaturesEmpty => 'كتالوج المزايا العام فارغ.';

  @override
  String get publicPricingTitle => 'خطط تناسب طريقة بيعك';

  @override
  String get publicPricingHeroSubtitle => 'خطط واضحة، منشورة من منصة Dukavo.';

  @override
  String get publicPricingInviteTitle => 'انضمام بالدعوة';

  @override
  String get publicPricingInviteBody =>
      'تستقبل Dukavo التجار من قائمة الانتظار. انضم إليها وسنتواصل معك عند توفر مكان.';

  @override
  String get publicPricingTaxNote =>
      'الأسعار المعروضة قبل الضريبة ما لم تُذكر خلاف ذلك.';

  @override
  String get publicPricingFaqTitle => 'أسئلة الأسعار';

  @override
  String get publicPricingFaqSubtitle => 'ما يسأله التجار عادة قبل اختيار خطة.';

  @override
  String get publicFaqTitle => 'الأسئلة الشائعة';

  @override
  String get publicFaqSubtitle =>
      'إجابات قصيرة عن Dukavo والانضمام وقائمة الانتظار.';

  @override
  String get publicFaqContactTitle => 'لا تزال لديك أسئلة؟';

  @override
  String get publicFaqContactBody =>
      'أرسل لنا رسالة وسنرد على البريد الذي تقدمه.';

  @override
  String get publicBlogTitle => 'المدونة';

  @override
  String get publicBlogSubtitle => 'أدلة وملاحظات منتج من فريق دوكافو.';

  @override
  String get publicBlogFeatured => 'أحدث مقال';

  @override
  String get publicBlogAll => 'كل المقالات';

  @override
  String get publicBlogEmptyTitle => 'لا توجد مقالات بعد';

  @override
  String get publicBlogEmptyBody => 'لم ننشر شيئاً بعد. عد قريباً.';

  @override
  String get publicBlogNotFoundTitle => 'المقال غير موجود';

  @override
  String get publicBlogNotFoundBody => 'ربما أُلغي نشر هذا المقال أو حُذف.';

  @override
  String get publicBlogBack => 'كل المقالات';

  @override
  String get publicContactTitle => 'تواصل معنا';

  @override
  String get publicContactSubtitle =>
      'أسئلة عن Dukavo أو الأسعار أو الانضمام؟ أرسل رسالة.';

  @override
  String get publicContactResponse => 'نرد عادة خلال يومي عمل.';

  @override
  String get publicContactSuccessTitle => 'تم إرسال الرسالة';

  @override
  String get publicContactSuccessBody => 'نرد على البريد الذي تقدمه.';

  @override
  String get publicContactHoneypot => 'الموقع الإلكتروني';

  @override
  String get publicWaitlistTitle => 'انضم إلى قائمة الانتظار';

  @override
  String get publicWaitlistSubtitle => 'كن أول من يعرف عند توفر مكان.';

  @override
  String get publicWaitlistBody =>
      'اترك بريدك وسنتواصل معك عندما تصبح Dukavo جاهزة لمتجرك.';

  @override
  String get publicWaitlistPrivacy => 'نستخدم هذا البريد فقط لدعوتك.';

  @override
  String get publicAboutBadge => 'عن Dukavo';

  @override
  String get publicAboutContactCta => 'تواصل معنا';

  @override
  String get publicAboutUnavailableTitle => 'هذه الصفحة غير متاحة بعد';

  @override
  String get publicAboutUnavailableBody =>
      'قد تكون قيد الإعداد. يرجى المحاولة لاحقًا.';

  @override
  String get publicContentUnavailableTitle => 'هذه الصفحة غير متاحة بعد';

  @override
  String get publicContentUnavailableBody =>
      'قد تكون قيد الإعداد. يرجى المحاولة لاحقًا.';

  @override
  String get publicContentBackHome => 'العودة إلى الرئيسية';

  @override
  String get publicRegisterBadge => 'بالدعوة فقط';

  @override
  String get publicRegisterTitle => 'احصل على دعوة';

  @override
  String get publicRegisterSubtitle =>
      'تنشئ Dukavo حسابات التجار بالدعوة، ليبقى الانضمام مدروسًا وشخصيًا.';

  @override
  String get publicRegisterStepOneTitle => 'انضم إلى قائمة الانتظار';

  @override
  String get publicRegisterStepOneBody => 'أخبرنا عن متجرك وطريقة بيعك.';

  @override
  String get publicRegisterStepTwoTitle => 'استلم دعوتك';

  @override
  String get publicRegisterStepTwoBody =>
      'نرسل دعوة بالبريد عند توفر مكان لنوع تجارتك.';

  @override
  String get publicRegisterStepThreeTitle => 'سجّل الدخول وجهّز متجرك';

  @override
  String get publicRegisterStepThreeBody =>
      'استخدم البريد الوارد في دعوتك لتسجيل الدخول وإنشاء مساحة عملك.';

  @override
  String get publicRegisterNoteTitle => 'لماذا بالدعوة؟';

  @override
  String get publicRegisterNoteBody =>
      'يتيح لنا مساعدة كل تاجر في نقل المنتجات والمخزون والعملاء بشكل صحيح بدل تركه أمام شاشة فارغة.';

  @override
  String get publicVerifyTitle => 'تأكيد البريد';

  @override
  String get publicVerifyPendingTitle => 'تحقق من بريدك';

  @override
  String get publicVerifyPendingBody =>
      'أكّد بريدك حتى نتمكن من إرسال الدعوات والإيصالات وإشعارات الحساب.';

  @override
  String get publicVerifyVerifiedTitle => 'تم تأكيد البريد';

  @override
  String get publicVerifyVerifiedBody => 'تم تأكيد بريدك. كل شيء جاهز.';

  @override
  String get publicVerifyResend => 'إعادة إرسال بريد التأكيد';

  @override
  String get publicVerifyResendAgain => 'أرسله مرة أخرى';

  @override
  String get publicVerifySent => 'إذا سمح الخادم، فالبريد في طريقه.';

  @override
  String get publicVerifySessionNote =>
      'يتطلب إرسال بريد التأكيد جلسة مسجّلة. إذا رفض الخادم، سجّل الدخول مجددًا وأعد المحاولة.';

  @override
  String get publicHowTitle => 'كيف تعمل Dukavo';

  @override
  String get publicHowSubtitle =>
      'من رسالة WhatsApp إلى طلب مكتمل، دون إعادة كتابة أي شيء.';

  @override
  String get publicHowSetupTitle => 'الإعداد';

  @override
  String get publicHowSetupSubtitle => 'ثلاث خطوات قصيرة عند وصول دعوتك.';

  @override
  String get publicHowSetupOneTitle => 'أضف منتجاتك';

  @override
  String get publicHowSetupOneBody =>
      'استورد كتالوجك أو أضف المنتجات واحدًا تلو الآخر، مع الأسعار والمخزون.';

  @override
  String get publicHowSetupTwoTitle => 'ادعُ فريقك';

  @override
  String get publicHowSetupTwoBody =>
      'امنح كل شخص الصلاحيات التي يحتاجها عمله، لا أكثر.';

  @override
  String get publicHowSetupThreeTitle => 'اربط قنواتك';

  @override
  String get publicHowSetupThreeBody =>
      'اجمع محادثات WhatsApp في الصندوق نفسه مع الطلبات والعملاء.';

  @override
  String get publicHowSecurityTitle => 'الصلاحيات يفرضها الخادم';

  @override
  String get publicHowSecurityBody =>
      'يخفي التطبيق ما لا يمكنك استخدامه، ويتحقق الخادم من كل طلب بشكل مستقل.';

  @override
  String get publicHowCtaTitle => 'جاهز لتنظيم تجارتك معنا؟';

  @override
  String get publicHowCtaBody =>
      'انضم لقائمة الانتظار وسنجهّز منتجاتك وطلباتك وعملاءك ومحادثاتك معًا.';

  @override
  String get translationAssistant => 'الترجمات بالذكاء الاصطناعي';

  @override
  String get translationOpen => 'الترجمات';

  @override
  String get translationReviewHint =>
      'تبقى مسودات الذكاء الاصطناعي خاصة حتى تعتمدها.';

  @override
  String get translationNoSelection => 'لا شيء محدد';

  @override
  String translationSelectedCount(Object count) {
    return 'تم تحديد $count';
  }

  @override
  String translationApproveSelectedCount(Object count) {
    return 'اعتماد $count';
  }

  @override
  String get translationGenerateTitle => 'إنشاء الترجمات';

  @override
  String get translationGenerateHint =>
      'اختر الحقول واللغات المطلوبة. النتيجة اقتراح وليست تغييرًا منشورًا.';

  @override
  String get translationSourceLanguage => 'لغة المصدر';

  @override
  String get translationSourceUnknown =>
      'تعذر تحديد لغة المصدر. اخترها صراحةً.';

  @override
  String translationDetectedLanguage(Object confidence, Object language) {
    return 'تم اكتشاف $language (ثقة $confidence٪)';
  }

  @override
  String get translationSourceRequired => 'لغة المصدر مطلوبة';

  @override
  String get translationSourceRequiredHint =>
      'اختر اللغة المكتوب بها النص حتى تترجم دوكافو من اللغة الصحيحة.';

  @override
  String get translationFields => 'الحقول';

  @override
  String get translationTargets => 'لغات الهدف';

  @override
  String get translationNoTargets => 'لا توجد لغة أخرى مفعّلة متاحة بعد.';

  @override
  String get translationGenerate => 'إنشاء';

  @override
  String get translationUsageTitle => 'استخدام الذكاء الاصطناعي اليوم';

  @override
  String translationUsageSummary(Object cost, Object requests, Object tokens) {
    return '$requests طلبًا · $tokens رمزًا · التكلفة التقديرية $cost';
  }

  @override
  String get translationReviewTitle => 'المراجعة';

  @override
  String get translationStale => 'قديمة';

  @override
  String get translationManuallyEdited => 'معدّلة يدويًا';

  @override
  String get translationSourceCopy => 'المصدر';

  @override
  String get translationNotTranslatedYet => 'لم تُترجم بعد.';

  @override
  String translationRejectionReasonValue(Object reason) {
    return 'مرفوضة: $reason';
  }

  @override
  String get translationPublishedCopy => 'لا تزال منشورة';

  @override
  String get translationApprove => 'اعتماد';

  @override
  String get translationEdit => 'تعديل';

  @override
  String get translationReject => 'رفض';

  @override
  String get translationRegenerate => 'إعادة الإنشاء';

  @override
  String get translationStatusNotTranslated => 'غير مترجمة';

  @override
  String get translationStatusGenerating => 'جارٍ الإنشاء';

  @override
  String get translationStatusGenerated => 'تم الإنشاء';

  @override
  String get translationStatusNeedsReview => 'تحتاج مراجعة';

  @override
  String get translationStatusApproved => 'معتمدة';

  @override
  String get translationStatusRejected => 'مرفوضة';

  @override
  String get translationStatusFailed => 'فشلت';

  @override
  String get translationStatusStale => 'قديمة';

  @override
  String get translationGenerated => 'تم إنشاء الترجمات للمراجعة.';

  @override
  String get translationApprovedMessage => 'تم اعتماد الترجمة ونشرها.';

  @override
  String get translationUpdated => 'تم تحديث الترجمة وإعادتها للمراجعة.';

  @override
  String get translationRejectedMessage => 'تم رفض الترجمة.';

  @override
  String get translationNothingSelected => 'اختر ترجمة واحدة على الأقل أولًا.';

  @override
  String get translationTextRequired => 'أدخل النص المترجم.';

  @override
  String get translationEditApprovedTitle => 'تعديل ترجمة منشورة؟';

  @override
  String get translationEditApprovedMessage =>
      'يبقى النص العام الحالي منشورًا حتى تعتمد النص الجديد.';

  @override
  String get translationEditHint => 'عدّل الترجمة';

  @override
  String get translationRejectReason => 'السبب (اختياري)';

  @override
  String get translationRejectReasonHint =>
      'أخبر المراجع سبب رفض هذا الاقتراح.';

  @override
  String get translationOverwriteMessage =>
      'سيستبدل هذا المسودة الحالية. النص المعدّل يدويًا والنص المنشور يحتاجان تأكيدك قبل إعادة الإنشاء.';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get choosePaymentRail => 'اختر طريقة الدفع';

  @override
  String get onlineRedirectNote =>
      'ستنتقل إلى صفحة المزوّد الآمنة. يبقى الطلب غير مدفوع حتى يؤكده المزوّد.';

  @override
  String get bankTransferNote =>
      'حوّل المبلغ إلى المتجر واحتفظ بالإيصال. يؤكد المتجر الطلب عند وصول المبلغ.';

  @override
  String get paymentProvider => 'المزوّد';

  @override
  String get paymentRail => 'طريقة الدفع';

  @override
  String get paymentAttempt => 'المحاولة';

  @override
  String get paymentAmount => 'المبلغ';

  @override
  String get paymentReference => 'المرجع';

  @override
  String get paymentPendingNote =>
      'بانتظار تأكيد المزوّد. تُحدَّث هذه الصفحة تلقائيًا.';

  @override
  String get paymentPaidNote => 'أكّد المزوّد هذا الدفع.';

  @override
  String get paymentLinkHint =>
      'افتح هذا الرابط في المتصفح للدفع. لا يتحدّث الطلب إلا بعد تأكيد المزوّد.';

  @override
  String get paymentLinkCopied => 'تم نسخ رابط الدفع.';

  @override
  String get copyPaymentLink => 'نسخ رابط الدفع';

  @override
  String get retryPayment => 'إعادة محاولة الدفع';

  @override
  String get orderAwaitingPayment => 'بانتظار الدفع';

  @override
  String get bankTransfer => 'التحويل البنكي';

  @override
  String get codNote =>
      'ادفع للمندوب عند الاستلام. يبقى الطلب غير مدفوع حتى ذلك الحين.';

  @override
  String get twoFactorTitle => 'التحقق بخطوتين';

  @override
  String get twoFactorSubtitle => 'أكّد أنك أنت لإكمال تسجيل الدخول.';

  @override
  String get twoFactorPrompt =>
      'أدخل الرمز المكوّن من 6 أرقام من تطبيق المصادقة.';

  @override
  String get twoFactorCode => 'رمز المصادقة';

  @override
  String get twoFactorCodePlaceholder => '000000';

  @override
  String get twoFactorCodeLength => 'أدخل الرمز المكوّن من 6 أرقام.';

  @override
  String get twoFactorVerify => 'تحقّق وسجّل الدخول';

  @override
  String get verifying => 'جارٍ التحقق';

  @override
  String get twoFactorUseRecovery => 'استخدام رمز استرداد';

  @override
  String get twoFactorUseCode => 'استخدام رمز المصادقة';

  @override
  String get twoFactorRecoveryCode => 'رمز الاسترداد';

  @override
  String get twoFactorRecoveryHint =>
      'أحد الرموز أحادية الاستخدام التي حفظتها عند تفعيل التحقق بخطوتين.';

  @override
  String get onboardingPreferencesTitle => 'بعض التفاصيل عنك';

  @override
  String get onboardingPreferencesSubtitle =>
      'خمّنّا هذه من شبكتك ومتصفحك لتوفير وقتك. راجعها، وغيّر أي شيء غير صحيح، أو تخطَّ الآن.';

  @override
  String get onboardingPersonalTitle => 'المعلومات الشخصية';

  @override
  String get onboardingPersonalHint => 'كيف يظهر اسمك وصورتك لفريقك.';

  @override
  String get onboardingLocationHint =>
      'يساعدنا الموقع على عرض التوقيت المحلي. التخمين من الشبكة تقريبي وليس موثّقًا.';

  @override
  String get onboardingDisplayHint => 'اختر كيف يبدو دوكافو ويُقرأ لك.';

  @override
  String get onboardingDetectedBadge => 'تم اكتشافها لك';

  @override
  String get onboardingApproximateBadge =>
      'بعض القيم تقدير من شبكتك. راجعها قبل الحفظ.';

  @override
  String get onboardingSave => 'حفظ التفضيلات';

  @override
  String get onboardingSkip => 'تخطٍّ الآن';

  @override
  String get onboardingSaved => 'تم حفظ التفضيلات.';

  @override
  String get onboardingSkipped =>
      'لا مشكلة — يمكنك تغييرها في أي وقت من ملفك الشخصي.';

  @override
  String get onboardingFootnote =>
      'هذه إعدادات شخصية. لا تغيّر أبدًا عملة متجر أو أسعاره أو طلباته السابقة.';

  @override
  String get onboardingPromptBody =>
      'أكّد لغتك وعملتك ومنطقتك الزمنية ليكون دوكافو مناسبًا لك.';

  @override
  String get onboardingPromptAction => 'مراجعة التفضيلات';

  @override
  String get nameHint => 'اسمك الكامل.';

  @override
  String get bio => 'نبذة';

  @override
  String get bioHint => 'جملة أو جملتان عنك. اختياري.';

  @override
  String get location => 'الموقع';

  @override
  String get country => 'الدولة';

  @override
  String get countryPlaceholder => 'اختر دولة';

  @override
  String get countrySearch => 'ابحث بالاسم أو الرمز أو رمز الاتصال';

  @override
  String get cityManualHint =>
      'لم تجدها؟ اكتب الاسم — الإدخال اليدوي مقبول دائمًا.';

  @override
  String get phoneCountry => 'رمز دولة الهاتف';

  @override
  String get phoneCountryHint => 'الدولة التي ينتمي إليها رقم هاتفك.';

  @override
  String get timezonePlaceholder => 'اختر منطقة زمنية';

  @override
  String get timezoneSearch => 'ابحث في المناطق الزمنية';

  @override
  String get dateFormat => 'تنسيق التاريخ';

  @override
  String get timeFormat => 'تنسيق الوقت';

  @override
  String get timeFormat24 => '24 ساعة (14:30)';

  @override
  String get timeFormat12 => '12 ساعة (2:30 م)';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get preferences => 'تفضيلات العرض';

  @override
  String get accountInformation => 'معلومات الحساب';

  @override
  String get accountMetaDesc => 'العضوية والأمان في لمحة.';

  @override
  String get accountType => 'نوع الحساب';

  @override
  String get accountTypeMember => 'عضو';

  @override
  String get memberSince => 'عضو منذ';

  @override
  String get passwordNever => 'لم تتغيّر أبدًا';

  @override
  String get profileComplete => 'ملفك مكتمل.';

  @override
  String get profileCompletion => 'اكتمال الملف الشخصي';

  @override
  String get workspaceSeparationHint =>
      'تغييرها لا يغيّر أبدًا عملة متجر أو أسعاره أو طلباته السابقة.';

  @override
  String get locationAndPreferences => 'الموقع والتفضيلات';

  @override
  String get locationAndPreferencesDesc =>
      'خاصة بك — منفصلة عن أي إعدادات لمساحة العمل.';

  @override
  String get securityCenter => 'مركز الأمان';

  @override
  String get securityActivity => 'نشاط الأمان';

  @override
  String get securityActivityDesc =>
      'عمليات الدخول وتغييرات كلمة المرور والجلسات على حسابك.';

  @override
  String get securityActivityEmpty => 'لا يوجد نشاط أمان بعد.';

  @override
  String get sessionsDesc => 'كل جهاز مسجّل الدخول إلى حسابك الآن.';

  @override
  String get twoFactor => 'التحقق بخطوتين';

  @override
  String get twoFactorDesc => 'اطلب رمزًا من تطبيق المصادقة عند تسجيل الدخول.';

  @override
  String get twoFactorOn => 'مفعّل';

  @override
  String get twoFactorOff => 'متوقف';

  @override
  String get twoFactorEnable => 'تفعيل';

  @override
  String get twoFactorEnabled => 'التحقق بخطوتين مفعّل.';

  @override
  String get twoFactorDisabled => 'التحقق بخطوتين متوقف.';

  @override
  String get twoFactorConfirm => 'تفعيل التحقق';

  @override
  String get twoFactorSetupIntro =>
      'افتح تطبيق المصادقة، أضف هذا المفتاح، ثم أدخل الرمز الذي يعرضه.';

  @override
  String get twoFactorSecret => 'مفتاح الإعداد';

  @override
  String get twoFactorSecretOnce =>
      'يُعرض هذا المفتاح مرة واحدة. احفظه في مكان آمن.';

  @override
  String get twoFactorProvisioningUri => 'رابط الإعداد';

  @override
  String twoFactorActiveSince(Object time) {
    return 'مفعّل منذ $time';
  }

  @override
  String get recoveryCodesTitle => 'رموز الاسترداد';

  @override
  String get recoveryCodesOnce =>
      'احفظها الآن. كل رمز يعمل مرة واحدة، ولن تُعرض مرة أخرى.';

  @override
  String get recoveryCodesRegenerated => 'تم إنشاء رموز استرداد جديدة.';

  @override
  String recoveryCodesRemaining(Object count) {
    return 'بقي $count من رموز الاسترداد';
  }

  @override
  String get regenerateRecoveryCodes => 'رموز استرداد جديدة';

  @override
  String get regenerateIntro =>
      'أدخل رمز مصادقة حاليًا لاستبدال رموز الاسترداد. ستتوقف الرموز القديمة عن العمل.';

  @override
  String get disableTwoFactor => 'إيقاف';

  @override
  String get currentPasswordRequired => 'أدخل كلمة مرورك الحالية.';

  @override
  String get requiresAuthenticationCode => 'أدخل رمز مصادقة أو رمز استرداد.';

  @override
  String get useAuthenticatorCode => 'استخدام رمز المصادقة';

  @override
  String get useRecoveryCode => 'استخدام رمز استرداد';

  @override
  String get recoveryCode => 'رمز الاسترداد';

  @override
  String get editProfileHint => 'الاسم والصورة والنبذة وبيانات التواصل.';

  @override
  String get changePasswordDesc =>
      'استخدم كلمة مرور قوية لا تستخدمها في أي مكان آخر.';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get supportSearchHint => 'ابحث في الأدلة والمواضيع';

  @override
  String get supportBrowseTopics => 'تصفح حسب الموضوع';

  @override
  String get supportFeatured => 'أدلة مميزة';

  @override
  String get supportPopular => 'الأكثر قراءة';

  @override
  String supportArticlesCount(Object count) {
    return '$count مقالات';
  }

  @override
  String get supportSearchEmptyTitle => 'لا توجد أدلة مطابقة';

  @override
  String get supportSearchEmptyBody =>
      'جرّب عبارة أقصر، أو امسح البحث وتصفح حسب الموضوع.';

  @override
  String get supportEmptyCategoryTitle => 'لا توجد مقالات بعد';

  @override
  String get supportEmptyCategoryBody => 'لم يُنشر أي شيء في هذا التصنيف بعد.';

  @override
  String get supportNotFoundTitle => 'لم نتمكن من العثور على هذا الدليل';

  @override
  String get supportNotFoundBody =>
      'ربما نُقل أو أعيد تسميته، أو أنه غير متاح لك.';

  @override
  String get supportRelated => 'أدلة ذات صلة';

  @override
  String get supportAllTopics => 'كل المواضيع';

  @override
  String get supportFeedbackTitle => 'هل ساعدك هذا الدليل؟';

  @override
  String get supportFeedbackYes => 'نعم';

  @override
  String get supportFeedbackNo => 'لا';

  @override
  String get supportFeedbackCommentLabel => 'هل تريد إضافة شيء؟ (اختياري)';

  @override
  String get supportFeedbackCommentHint => 'ما الذي كنت تحاول فعله؟';

  @override
  String get supportFeedbackSend => 'إرسال الإجابة';

  @override
  String get supportFeedbackThanks => 'تساعدنا إجابتك في تحسين هذا الدليل.';

  @override
  String get supportFeedbackFailed => 'تعذّر إرسال إجابتك. حاول مرة أخرى.';

  @override
  String get integrations => 'التكاملات';

  @override
  String get integrationsSubtitle => 'كل قناة يمكن لعملائك الوصول إليك عبرها.';

  @override
  String get integrationsRefresh => 'تحديث';

  @override
  String get integrationsConnect => 'ربط';

  @override
  String integrationsConnectChannel(Object channel) {
    return 'ربط $channel';
  }

  @override
  String get integrationsEditConnection => 'تعديل الاتصال';

  @override
  String get integrationsAvailabilityAvailable => 'متاحة';

  @override
  String get integrationsAvailabilityAwaitingConfiguration => 'بانتظار الإعداد';

  @override
  String get integrationsAvailabilityAwaitingProviderAccess =>
      'بانتظار وصول المزوّد';

  @override
  String get integrationsStatusPending => 'قيد الانتظار';

  @override
  String get integrationsStatusConnected => 'متصلة';

  @override
  String get integrationsStatusDisconnected => 'غير متصلة';

  @override
  String get integrationsStatusError => 'خطأ';

  @override
  String get integrationsHealthUnknown => 'لم تُفحص';

  @override
  String get integrationsHealthHealthy => 'سليمة';

  @override
  String get integrationsHealthDegraded => 'متدهورة';

  @override
  String get integrationsHealthFailing => 'فاشلة';

  @override
  String get integrationsCapabilities => 'الإمكانات';

  @override
  String get integrationsConnections => 'الاتصالات';

  @override
  String get integrationsNoConnections => 'لا شيء متصل بعد.';

  @override
  String get integrationsAllStores => 'كل المتاجر';

  @override
  String get integrationsName => 'اسم الاتصال';

  @override
  String get integrationsNameHint => 'مثال: خط المبيعات';

  @override
  String get integrationsStore => 'المتجر';

  @override
  String get integrationsCredentials => 'بيانات الاعتماد';

  @override
  String get integrationsCredentialsHint =>
      'تُشفَّر القيم عند التخزين ولا تُعرض مرة أخرى. اترك الحقل السري فارغًا للإبقاء على القيمة المحفوظة.';

  @override
  String get integrationsRequired => 'مطلوب';

  @override
  String get integrationsOptional => 'اختياري';

  @override
  String get integrationsConfigured => 'محفوظ';

  @override
  String get integrationsSecretHint => 'محفوظ — اتركه فارغًا للإبقاء عليه';

  @override
  String get integrationsAwaitingAccessTitle => 'لم يُمنح وصول المزوّد بعد';

  @override
  String get integrationsAwaitingAccessBody =>
      'هذه القناة معلنة لكن دوكافو لا يملك وصولًا معتمدًا إلى واجهتها البرمجية. يمكنك حفظ بيانات الاعتماد الآن؛ يبقى الاتصال قيد الانتظار حتى يُمنح الوصول وينجح فحص حقيقي.';

  @override
  String get integrationsAwaitingConfigTitle => 'إعداد المنصة ناقص';

  @override
  String get integrationsAwaitingConfigBody =>
      'يفتقد هذا التنصيب المفاتيح الخاصة بالمنصة التي تحتاجها هذه القناة. اطلب من مسؤول المنصة إعدادها.';

  @override
  String get integrationsWebhook => 'رابط الويب هوك';

  @override
  String get integrationsCopied => 'تم النسخ.';

  @override
  String get integrationsCopyFailed =>
      'منع هذا الجهاز الوصول إلى الحافظة — انسخه يدويًا.';

  @override
  String get integrationsTest => 'فحص';

  @override
  String get integrationsReconnect => 'إعادة الاتصال';

  @override
  String get integrationsDisconnect => 'قطع الاتصال';

  @override
  String integrationsDisconnectTitle(Object name) {
    return 'قطع اتصال $name؟';
  }

  @override
  String get integrationsDisconnectBody =>
      'لن يصل إليك العملاء عبر هذا الاتصال بعد الآن. تبقى المحادثات في صندوق الوارد.';

  @override
  String get integrationsSaved => 'تم حفظ الاتصال.';

  @override
  String get integrationsDisconnected => 'تم قطع الاتصال.';

  @override
  String get integrationsTested => 'تم فحص الاتصال.';

  @override
  String get integrationsReconnected => 'تمت إعادة الاتصال.';

  @override
  String get integrationsError => 'أبلغ هذا الاتصال عن خطأ.';

  @override
  String get integrationsEmptyTitle => 'لا توجد قنوات متاحة';

  @override
  String get integrationsEmptyBody =>
      'لم تُعرَّف أي قناة مراسلة في هذا التنصيب.';

  @override
  String get integrationsNeverChecked => 'لم يُفحص قط';

  @override
  String get integrationsCapabilityText => 'نص';

  @override
  String get integrationsCapabilityImage => 'صور';

  @override
  String get integrationsCapabilityDocument => 'مستندات';

  @override
  String get integrationsCapabilityAudio => 'صوت';

  @override
  String get integrationsCapabilityVoice => 'رسائل صوتية';

  @override
  String get integrationsCapabilityVideo => 'فيديو';

  @override
  String get integrationsCapabilityTemplate => 'قوالب';

  @override
  String get integrationsCapabilityDeliveryStatus => 'حالة التسليم';

  @override
  String get integrationsCapabilityReadStatus => 'إشعارات القراءة';

  @override
  String get integrationsCapabilityMediaDownload => 'تنزيل الوسائط';

  @override
  String get integrationsCapabilityTyping => 'مؤشر الكتابة';

  @override
  String get enabled => 'مفعّل';

  @override
  String get disabled => 'معطّل';

  @override
  String get environment => 'البيئة';

  @override
  String get configuration => 'الإعدادات';

  @override
  String get platformSettings => 'إعدادات المنصة';

  @override
  String get platformSettingsSubtitle =>
      'مكان واحد للإعدادات التي تشترك فيها المنصة كلها. إعدادات المتجر والتاجر تبقى منفصلة.';

  @override
  String get platformSettingsSpecialists =>
      'بيانات اعتماد مزوّدي الذكاء الاصطناعي والموجّهات ودليل المدفوعات تُدار من لوحة الويب. هذه الشاشة تربط بما يمكن للهاتف تغييره بأمان.';

  @override
  String get platformSettingsAuditNote =>
      'كل حفظ يُسجَّل في سجل التدقيق مع المشغّل والقيمة السابقة والجديدة. تُحجب الأسرار.';

  @override
  String get platformSettingsSections => 'أقسام الإعدادات';

  @override
  String get platformSettingsControls => 'أدوات المنصة';

  @override
  String get platformSettingsOperations => 'العمليات';

  @override
  String platformSettingsSectionMeta(Object overrides, Object settings) {
    return '$settings إعداد · $overrides متجاوَز';
  }

  @override
  String platformSettingsSecretCount(Object count) {
    return '$count سر';
  }

  @override
  String get platformSettingsOverrides => 'التجاوزات';

  @override
  String get platformSettingsSecrets => 'الأسرار';

  @override
  String get platformSettingsDefinitions => 'التعريفات';

  @override
  String get platformSettingsRuntime => 'وقت التشغيل';

  @override
  String get platformSettingsMaintenanceActive => 'وضع الصيانة مفعّل';

  @override
  String get platformSettingsOpenMaintenance => 'فتح الصيانة';

  @override
  String get platformSettingsSaved => 'تم حفظ الإعدادات.';

  @override
  String get platformSettingsReadOnlyTitle => 'للقراءة فقط لدورك';

  @override
  String get platformSettingsReadOnlyBody =>
      'يمكنك قراءة هذا القسم دون تغييره. اطلب من مسؤول المنصة الصلاحية المطابقة.';

  @override
  String get platformSettingsEmptySection =>
      'لا توجد إعدادات معرّفة في هذا القسم.';

  @override
  String platformSettingsUnsaved(Object count) {
    return '$count تغيير غير محفوظ';
  }

  @override
  String get platformSettingsClearOverride =>
      'إعادة الضبط إلى قيمة البيئة أو التطبيق الافتراضية';

  @override
  String get platformSettingsRequiresRestart => 'يُطبَّق مع الطلب التالي';

  @override
  String platformSettingsSecretHint(Object hint) {
    return 'ينتهي بـ $hint';
  }

  @override
  String get platformSettingsSecretPlaceholder =>
      'أدخل قيمة جديدة لاستبدال السر المخزّن';

  @override
  String get platformSettingsSecretConfigured => 'مضبوط';

  @override
  String get platformSettingsSecretMissing => 'غير مضبوط';

  @override
  String get platformSettingsChooseOption => 'اختر خيارًا';

  @override
  String platformSettingsRange(Object max, Object min) {
    return 'النطاق $min–$max';
  }

  @override
  String get platformSettingsSourceDatabase => 'إعداد المنصة';

  @override
  String get platformSettingsSourceEnvironment => 'البيئة';

  @override
  String get platformSettingsSourceDefault => 'افتراضي التطبيق';

  @override
  String get settingsGroupIdentity => 'الهوية';

  @override
  String get settingsGroupApplication => 'التطبيق';

  @override
  String get settingsGroupBrand => 'العلامة';

  @override
  String get settingsGroupContact => 'التواصل';

  @override
  String get settingsGroupFormat => 'التنسيقات';

  @override
  String get settingsGroupLanguage => 'اللغات';

  @override
  String get settingsGroupNumber => 'الأرقام';

  @override
  String get settingsGroupPassword => 'سياسة كلمة المرور';

  @override
  String get settingsGroupRateLimits => 'حدود المعدّل';

  @override
  String get settingsGroupRegion => 'المنطقة';

  @override
  String get settingsGroupRouting => 'التوجيه';

  @override
  String get settingsGroupRuntime => 'وقت التشغيل';

  @override
  String get settingsGroupSession => 'الجلسات';

  @override
  String get settingsGroupSocial => 'التواصل الاجتماعي';

  @override
  String get settingsGroupState => 'الحالة';

  @override
  String get settingsGroupTransport => 'النقل';

  @override
  String get settingsGroupDriver => 'المشغّل';

  @override
  String get settingsGroupGeneral => 'عام';

  @override
  String get platformSettingsFeaturesTitle => 'مزايا المنصة';

  @override
  String get platformSettingsFeaturesSubtitle =>
      'مفاتيح التوفر على مستوى المنصة.';

  @override
  String get platformSettingsFeaturesNoteTitle => 'توفر لا استحقاق';

  @override
  String get platformSettingsFeaturesNoteBody =>
      'إيقاف ميزة يزيلها من كل المستأجرين بغض النظر عن الخطة أو الصلاحية. تُحفظ البيانات والمفتاح قابل للعكس.';

  @override
  String platformSettingsFeaturesEnabled(Object count) {
    return '$count مفعّلة';
  }

  @override
  String platformSettingsFeaturesTotal(Object count) {
    return 'من $count';
  }

  @override
  String get platformSettingsFeaturesSearch => 'ابحث في المزايا';

  @override
  String get platformSettingsFeaturesEmptyTitle => 'لا توجد مزايا مطابقة';

  @override
  String get platformSettingsFeaturesEmptyBody => 'جرّب عبارة بحث أخرى.';

  @override
  String platformSettingsFeatureEnabled(Object name) {
    return '$name أصبحت متاحة.';
  }

  @override
  String platformSettingsFeatureDisabled(Object name) {
    return 'تم سحب $name.';
  }

  @override
  String get featureGroupIntelligence => 'الذكاء';

  @override
  String get featureGroupChannels => 'القنوات';

  @override
  String get featureGroupCommunication => 'التواصل';

  @override
  String get featureGroupOperations => 'العمليات';

  @override
  String get featureGroupCommerce => 'التجارة';

  @override
  String get featureGroupGrowth => 'النمو';

  @override
  String get platformSettingsHealthTitle => 'صحة التكاملات';

  @override
  String get platformSettingsHealthSubtitle =>
      'آخر حالة مسجّلة وفحوص عند الطلب.';

  @override
  String get platformSettingsHealthReadTitle => 'القراءة لا تفحص';

  @override
  String get platformSettingsHealthReadBody =>
      'تعرض هذه الشاشة آخر حالة مسجّلة. الفحص يستدعي المزوّد، لذا لا يعمل إلا عند طلبه.';

  @override
  String get platformSettingsHealthEmpty => 'لا توجد تكاملات مسجّلة.';

  @override
  String get platformSettingsHealthStateConnected => 'متصل';

  @override
  String get platformSettingsHealthStateDisconnected => 'غير متصل';

  @override
  String get platformSettingsHealthStateInvalidCredentials =>
      'بيانات اعتماد غير صالحة';

  @override
  String get platformSettingsHealthStateRateLimited => 'تجاوز حد المعدّل';

  @override
  String get platformSettingsHealthStateServiceUnavailable =>
      'الخدمة غير متاحة';

  @override
  String get platformSettingsHealthStateConfigurationRequired => 'يلزم الضبط';

  @override
  String get platformSettingsHealthStateNotTested => 'لم يُفحص';

  @override
  String get platformSettingsHealthStateDisabled => 'معطّل';

  @override
  String platformSettingsHealthChecked(Object name) {
    return 'اكتمل فحص $name.';
  }

  @override
  String platformSettingsHealthCheckedAt(Object when) {
    return 'فُحص $when';
  }

  @override
  String get platformSettingsHealthNever => 'لم يُفحص أبدًا';

  @override
  String get platformSettingsHealthTest => 'تشغيل الفحص';

  @override
  String get platformSettingsHistoryTitle => 'سجل الإعدادات';

  @override
  String get platformSettingsHistorySubtitle =>
      'من غيّر ماذا، وما الذي استبدله.';

  @override
  String get platformSettingsHistoryFilter => 'مفتاح الإعداد';

  @override
  String get platformSettingsHistoryFilterHint => 'email.mail_host';

  @override
  String get platformSettingsHistoryRows => 'الصفوف';

  @override
  String get platformSettingsHistoryEmpty => 'لا تغييرات بعد';

  @override
  String get platformSettingsHistoryEmptyFiltered =>
      'لا تغيير يطابق هذا المفتاح.';

  @override
  String get platformSettingsHistoryEmptyBody =>
      'سيُسجَّل أي حفظ للإعدادات هنا.';

  @override
  String get platformSettingsHistoryNone => 'لا شيء';

  @override
  String platformSettingsHistorySecret(Object hint) {
    return 'سر · ينتهي بـ $hint';
  }

  @override
  String get platformSettingsHistorySystem => 'النظام';

  @override
  String get platformSettingsInfrastructureTitle => 'البنية التحتية';

  @override
  String get platformSettingsInfrastructureSubtitle =>
      'قيم للقراءة فقط تديرها بيئة النشر.';

  @override
  String get platformSettingsInfraReadOnlyTitle => 'تديرها بيئة النشر';

  @override
  String get platformSettingsInfraReadOnlyBody =>
      'هذه القيم للقراءة فقط هنا بحكم التصميم. غيّرها في بيئة النشر وأعد النشر؛ تُعرض الأسرار كمضبوطة أو غير مضبوطة فقط.';

  @override
  String get platformSettingsInfraRuntimeTitle => 'العملية قيد التشغيل';

  @override
  String get platformSettingsInfraVariablesTitle => 'متغيّرات البيئة';

  @override
  String get platformSettingsInfraPhp => 'PHP';

  @override
  String get platformSettingsInfraLaravel => 'Laravel';

  @override
  String get platformSettingsInfraDatabase => 'قاعدة البيانات';

  @override
  String get platformSettingsInfraCache => 'التخزين المؤقت';

  @override
  String get platformSettingsInfraQueue => 'الطابور';

  @override
  String get platformSettingsInfraSession => 'الجلسة';

  @override
  String get platformSettingsInfraMailer => 'البريد';

  @override
  String get platformSettingsInfraFilesystem => 'الملفات';

  @override
  String get actionPreviews => 'معاينات الإجراءات';

  @override
  String get actionUrl => 'رابط الإجراء';

  @override
  String get activateTenantMessage => 'تفعيل هذا المستأجر؟';

  @override
  String get activeVersion => 'النسخة النشطة';

  @override
  String get activityLog => 'سجل النشاط';

  @override
  String get adapter => 'المحوّل';

  @override
  String get addPaymentConnection => 'إضافة اتصال دفع';

  @override
  String get aiAdminReadOnlyNote =>
      'هذه الشاشة للقراءة فقط باستثناء تدوير بيانات الاعتماد.';

  @override
  String get aiAdministration => 'إدارة الذكاء الاصطناعي';

  @override
  String get aiCopilot => 'مساعد الذكاء الاصطناعي';

  @override
  String get aiCopilotHint =>
      'يجيب المساعد من أرقام لوحة التحكم الفعلية فقط، ولا يخترع أي قيمة.';

  @override
  String get aiCopilotQuestionHint =>
      'مثال: على ماذا يجب أن أركّز هذا الأسبوع؟';

  @override
  String get aiFeatureLimits => 'حدود ميزات الذكاء الاصطناعي';

  @override
  String get aiInsights => 'رؤى الذكاء الاصطناعي';

  @override
  String get aiPrompts => 'الموجّهات';

  @override
  String get aiServing => 'حالة خدمة الذكاء الاصطناعي';

  @override
  String get aiTasks => 'مهام الذكاء الاصطناعي';

  @override
  String get aiTestConnection => 'اختبار الاتصال';

  @override
  String get aiUsage30Days => 'الاستخدام خلال 30 يومًا';

  @override
  String get apiKey => 'مفتاح API';

  @override
  String get applyTemplateUpdate => 'تطبيق تحديث القالب';

  @override
  String get applyTemplateUpdateMessage =>
      'تطبيق نسخة القالب الأحدث على هذا التثبيت؟';

  @override
  String get approveAiActionMessage => 'الموافقة على إجراء الذكاء الاصطناعي؟';

  @override
  String get archiveTemplate => 'أرشفة القالب';

  @override
  String get archiveTemplateMessage =>
      'أرشفة هذا القالب؟ لن يظهر للمتاجر الجديدة.';

  @override
  String get askCopilot => 'اسأل المساعد';

  @override
  String get attempt => 'المحاولة';

  @override
  String get attempts => 'المحاولات';

  @override
  String get audience => 'الجمهور';

  @override
  String get automationInstallations => 'تثبيتات الأتمتة';

  @override
  String get automationInstallationsHint => 'قواعد مثبّتة من قوالب المنصة.';

  @override
  String get automationTemplates => 'قوالب الأتمتة';

  @override
  String get automationTemplatesHint =>
      'قوالب جاهزة من المنصة يمكنك تثبيتها في متجرك.';

  @override
  String get availability => 'التوافر';

  @override
  String get baseUrl => 'عنوان URL الأساسي';

  @override
  String get byokDisabled => 'مفتاح المنصة مفعّل';

  @override
  String get byokEnabled => 'مفتاح المستأجر مفعّل';

  @override
  String get cacheHit => 'إصابة الذاكرة المؤقتة';

  @override
  String get cacheHits => 'إصابات الذاكرة المؤقتة';

  @override
  String get campaigns => 'الحملات';

  @override
  String get cancelCampaign => 'إلغاء الحملة';

  @override
  String get cancelCampaignMessage => 'إلغاء هذه الحملة؟';

  @override
  String get cancelledAt => 'أُلغيت في';

  @override
  String get capabilities => 'القدرات';

  @override
  String get changelog => 'سجل التغييرات';

  @override
  String get channel => 'القناة';

  @override
  String get channelKey => 'مفتاح القناة';

  @override
  String get channels => 'القنوات';

  @override
  String get configurationSchema => 'مخطط الإعدادات';

  @override
  String get connectionVerified => 'تم التحقق من الاتصال';

  @override
  String get connections => 'الاتصالات';

  @override
  String get correlationId => 'معرّف الارتباط';

  @override
  String get countries => 'الدول';

  @override
  String get counts => 'الأعداد';

  @override
  String get credentialFields => 'حقول بيانات الاعتماد';

  @override
  String get credentialSource => 'مصدر بيانات الاعتماد';

  @override
  String get credentials => 'بيانات الاعتماد';

  @override
  String get currentVersion => 'النسخة الحالية';

  @override
  String get dailyPerTenant => 'الحد اليومي للمستأجر';

  @override
  String get dailyPerUser => 'الحد اليومي للمستخدم';

  @override
  String get dataGaps => 'فجوات البيانات';

  @override
  String get deliveredAt => 'سُلّمت في';

  @override
  String get deliveries => 'عمليات التسليم';

  @override
  String get descriptionAr => 'الوصف (عربي)';

  @override
  String get disableInstallation => 'تعطيل التثبيت';

  @override
  String get disableInstallationMessage =>
      'تعطيل هذا التثبيت؟ سيتوقف عن العمل.';

  @override
  String get disconnectAccountMessage => 'فصل هذا الحساب؟';

  @override
  String get dismissRecoveryMessage => 'تجاهل فرصة الاستعادة هذه؟';

  @override
  String get dismissTaskMessage => 'تجاهل هذه المهمة؟';

  @override
  String get doNotContactMessage => 'تسجيل هذا العميل كعدم التواصل؟';

  @override
  String get docsUrl => 'رابط التوثيق';

  @override
  String get draftMessageMessage => 'إنشاء مسودة رسالة؟';

  @override
  String get driver => 'المشغّل';

  @override
  String get durationMs => 'المدة (مللي ثانية)';

  @override
  String get effectiveCopy => 'النص الفعلي';

  @override
  String get emailTemplates => 'قوالب البريد';

  @override
  String get enableInstallation => 'تفعيل التثبيت';

  @override
  String get enabledAt => 'فُعّل في';

  @override
  String get errorCategory => 'فئة الخطأ';

  @override
  String get estimatedCost => 'التكلفة المقدّرة';

  @override
  String get estimatesAndRecommendations => 'التقديرات والتوصيات';

  @override
  String get eventId => 'معرّف الحدث';

  @override
  String get eventKey => 'مفتاح الحدث';

  @override
  String get eventType => 'نوع الحدث';

  @override
  String get executeAiActionMessage => 'تنفيذ إجراء الذكاء الاصطناعي الآن؟';

  @override
  String get factsUsed => 'الحقائق المستخدمة';

  @override
  String get failedAt => 'فشلت في';

  @override
  String get failing => 'فاشلة';

  @override
  String get failureReason => 'سبب الفشل';

  @override
  String get failureType => 'نوع الفشل';

  @override
  String get failures => 'الإخفاقات';

  @override
  String get fallbackAttempts => 'محاولات البديل';

  @override
  String get fallbackRequests => 'طلبات البديل';

  @override
  String get feature => 'الميزة';

  @override
  String get fromStore => 'من متجر';

  @override
  String get group => 'المجموعة';

  @override
  String get headingAr => 'العنوان (عربي)';

  @override
  String get headingEn => 'العنوان (إنجليزي)';

  @override
  String get httpStatus => 'حالة HTTP';

  @override
  String get icon => 'الأيقونة';

  @override
  String get inputTokens => 'رموز الإدخال';

  @override
  String get installTemplate => 'تثبيت القالب';

  @override
  String get installTemplateMessage => 'تثبيت هذا القالب في مساحة عملك؟';

  @override
  String get installation => 'التثبيت';

  @override
  String get installations => 'التثبيتات';

  @override
  String get installed => 'مثبّت';

  @override
  String get installedAt => 'ثُبّت في';

  @override
  String get installedVersion => 'النسخة المثبّتة';

  @override
  String get installer => 'المثبّت';

  @override
  String get integrationEnabled => 'التكامل مفعّل';

  @override
  String get integrationHealth => 'صحة التكاملات';

  @override
  String get introAr => 'المقدمة (عربي)';

  @override
  String get introEn => 'المقدمة (إنجليزي)';

  @override
  String get inventoryTransfer => 'نقل المخزون';

  @override
  String get inventoryTransferHint =>
      'انقل كمية من متغير منتج بين متجرين في مساحة العمل نفسها. يتحقق الخادم من المتجرين والمخزون.';

  @override
  String get isMarketing => 'رسالة تسويقية';

  @override
  String get key => 'المفتاح';

  @override
  String get kind => 'النوع';

  @override
  String get lastSyncedAt => 'آخر مزامنة';

  @override
  String get lastVerified => 'آخر تحقق';

  @override
  String get live => 'مباشر';

  @override
  String get makeDefaultMessage => 'تعيين هذا كافتراضي؟';

  @override
  String get markCompletedMessage => 'تعليم هذا كمكتمل؟';

  @override
  String get maxOutputTokens => 'أقصى رموز الإخراج';

  @override
  String get maxRetries => 'أقصى عدد محاولات';

  @override
  String get merchantReference => 'مرجع التاجر';

  @override
  String get methodCode => 'رمز طريقة الدفع';

  @override
  String get metricExplanations => 'شرح المؤشرات';

  @override
  String get missingData => 'بيانات ناقصة';

  @override
  String get model => 'النموذج';

  @override
  String get models => 'النماذج';

  @override
  String get monthlyPerTenant => 'الحد الشهري للمستأجر';

  @override
  String get monthlyPlatformRequests => 'الحد الشهري للمنصة';

  @override
  String get nameAr => 'الاسم (عربي)';

  @override
  String get noAiPrompts => 'لا توجد موجّهات بعد';

  @override
  String get noAiTasks => 'لا توجد مهام بعد';

  @override
  String get noAnswerReturned => 'لم يُرجع المساعد إجابة.';

  @override
  String get noAutomationInstallations => 'لا توجد تثبيتات أتمتة';

  @override
  String get noAutomationTemplates => 'لا توجد قوالب أتمتة';

  @override
  String get noCampaigns => 'لا توجد حملات';

  @override
  String get noConnections => 'لا توجد اتصالات';

  @override
  String get noCountries => 'لا توجد دول';

  @override
  String get noCredentials => 'لا توجد بيانات اعتماد';

  @override
  String get noDeliveries => 'لا توجد عمليات تسليم';

  @override
  String get noEmailTemplates => 'لا توجد قوالب بريد';

  @override
  String get noIntegrations => 'لا توجد تكاملات';

  @override
  String get noPaymentConnections => 'لا توجد اتصالات دفع';

  @override
  String get noPaymentConnectionsMessage =>
      'أضف اتصالًا ليتمكن المتجر من تحصيل المدفوعات.';

  @override
  String get noPayments => 'لا توجد مدفوعات';

  @override
  String get noProviders => 'لا يوجد مزوّدون';

  @override
  String get noVariantsToTransfer => 'لا توجد متغيرات منتجات للنقل';

  @override
  String get noWebhookEvents => 'لا توجد أحداث webhook';

  @override
  String get nothingHereYet => 'لا يوجد شيء بعد';

  @override
  String get notificationOperations => 'عمليات الإشعارات';

  @override
  String get operations => 'العمليات';

  @override
  String get outputTokens => 'رموز الإخراج';

  @override
  String get paidAt => 'دُفعت في';

  @override
  String get payment => 'الدفعة';

  @override
  String get paymentCatalogue => 'دليل المدفوعات';

  @override
  String get paymentConnections => 'اتصالات الدفع';

  @override
  String get paymentHistory => 'سجل المدفوعات';

  @override
  String get payments => 'المدفوعات';

  @override
  String get period => 'الفترة';

  @override
  String get platformConfigured => 'مضبوط على المنصة';

  @override
  String get processedAt => 'عُولج في';

  @override
  String get productVariant => 'متغير المنتج';

  @override
  String get promptKey => 'مفتاح الموجّه';

  @override
  String get provider => 'المزوّد';

  @override
  String get providerCode => 'رمز المزوّد';

  @override
  String get providerCount => 'عدد المزوّدين';

  @override
  String get providerCoverage => 'تغطية المزوّدين';

  @override
  String get providerKey => 'مفتاح المزوّد';

  @override
  String get providerMessageId => 'معرّف رسالة المزوّد';

  @override
  String get providers => 'المزوّدون';

  @override
  String get publicKey => 'المفتاح العام';

  @override
  String get publishCampaign => 'نشر الحملة';

  @override
  String get publishCampaignMessage => 'نشر هذه الحملة الآن؟';

  @override
  String get publishTemplate => 'نشر القالب';

  @override
  String get publishTemplateMessage => 'نشر هذا القالب للمتاجر؟';

  @override
  String get questionTooLong => 'السؤال طويل جدًا (الحد 1000 حرف).';

  @override
  String get queuedAt => 'في الانتظار منذ';

  @override
  String get recheckComplete => 'اكتمل إعادة الفحص';

  @override
  String get recheckIntegration => 'إعادة فحص التكامل';

  @override
  String get recheckIntegrationMessage => 'إعادة فحص هذا التكامل الآن؟';

  @override
  String get recipient => 'المستلم';

  @override
  String get recommendations => 'التوصيات';

  @override
  String get refundAmount => 'مبلغ الاسترداد';

  @override
  String get refundPayment => 'استرداد الدفعة';

  @override
  String get refundReason => 'سبب الاسترداد';

  @override
  String get refundSubmitted => 'تم إرسال الاسترداد';

  @override
  String get rejectAiActionMessage => 'رفض إجراء الذكاء الاصطناعي؟';

  @override
  String get removed => 'مزال';

  @override
  String get requests => 'الطلبات';

  @override
  String get restoreTemplate => 'استعادة القالب';

  @override
  String get restoreTemplateMessage => 'استعادة النص الافتراضي لهذا القالب؟';

  @override
  String get retryDelivery => 'إعادة محاولة التسليم';

  @override
  String get retryDeliveryMessage => 'إعادة محاولة تسليم هذه الرسالة؟';

  @override
  String get revokeConnectionMessage =>
      'إلغاء هذا الاتصال؟ سيتوقف المتجر عن استخدامه.';

  @override
  String get rotateCredential => 'تدوير بيانات الاعتماد';

  @override
  String get routes => 'المسارات';

  @override
  String get rule => 'القاعدة';

  @override
  String get sandbox => 'تجريبي';

  @override
  String get scheduleCampaign => 'جدولة الحملة';

  @override
  String get scheduledAt => 'مجدولة في';

  @override
  String get secretKey => 'المفتاح السري';

  @override
  String get seedAiTasks => 'تهيئة مهام الذكاء الاصطناعي';

  @override
  String get seedAiTasksMessage =>
      'إنشاء مهام الذكاء الاصطناعي الافتراضية الناقصة؟';

  @override
  String get selectPeriod => 'اختر الفترة';

  @override
  String get sendTestEmail => 'إرسال بريد تجريبي';

  @override
  String get sentAt => 'أُرسلت في';

  @override
  String get signatureValid => 'التوقيع صالح';

  @override
  String get stockTransferred => 'تم نقل المخزون';

  @override
  String get subjectAr => 'الموضوع (عربي)';

  @override
  String get subjectEn => 'الموضوع (إنجليزي)';

  @override
  String get submitForApprovalMessage => 'إرسال للموافقة؟';

  @override
  String get suspendTenantMessage => 'تعليق هذا المستأجر؟';

  @override
  String get syncPayment => 'مزامنة الدفعة';

  @override
  String get taskKey => 'مفتاح المهمة';

  @override
  String get temperature => 'درجة الحرارة';

  @override
  String get template => 'القالب';

  @override
  String get templateActionsHint =>
      'مصفوفة JSON للإجراءات، مثل النوع send_notification.';

  @override
  String get templateCategoryHint => 'إحدى فئات القوالب التي يعرّفها الخادم.';

  @override
  String get templateCustomized => 'القالب مخصّص';

  @override
  String get templateKey => 'مفتاح القالب';

  @override
  String get templateKeyHint => 'معرّف فريد بأحرف صغيرة وشرطات.';

  @override
  String get templateTriggerHint => 'مشغّل من قائمة مشغّلات الأتمتة.';

  @override
  String get timeoutSeconds => 'مهلة (ثانية)';

  @override
  String get toStore => 'إلى متجر';

  @override
  String get toggleCountry => 'تبديل حالة الدولة';

  @override
  String get toggleCountryMessage => 'تغيير حالة تفعيل هذه الدولة؟';

  @override
  String get toggleMethod => 'تبديل حالة الطريقة';

  @override
  String get toggleMethodMessage => 'تغيير حالة تفعيل طريقة الدفع؟';

  @override
  String get tokens => 'الرموز';

  @override
  String get transferNeedsTwoStores => 'تحتاج إلى متجرين';

  @override
  String get transferNeedsTwoStoresMessage =>
      'أنشئ متجرًا ثانيًا لتتمكن من نقل المخزون بين المتاجر.';

  @override
  String get transferStock => 'نقل المخزون';

  @override
  String get transferStockConfirm => 'نقل هذه الكمية بين المتجرين؟';

  @override
  String get unprocessedEvents => 'أحداث غير معالجة';

  @override
  String get unregisteredProviders => 'مزوّدون غير مسجّلين';

  @override
  String get variables => 'المتغيرات';

  @override
  String get verifyAccountMessage => 'التحقق من هذا الحساب؟';

  @override
  String get verifyConnection => 'التحقق من الاتصال';

  @override
  String get versions => 'النسخ';

  @override
  String get webhookDocsUrl => 'رابط توثيق webhook';

  @override
  String get webhookEvents => 'أحداث webhook';

  @override
  String get webhookSecret => 'سر webhook';

  @override
  String get yourQuestion => 'سؤالك';
}
