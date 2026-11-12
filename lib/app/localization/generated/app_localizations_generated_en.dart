// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_generated.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Dukavo';

  @override
  String get appTagline => 'Run your store from anywhere.';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Create';

  @override
  String get search => 'Search';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading…';

  @override
  String get noData => 'Nothing here yet';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'We couldn\'t reach the server. Check your connection and try again.';

  @override
  String get offlineTitle => 'You\'re offline';

  @override
  String get offlineBody =>
      'Showing what was saved on this device. Actions that need the server are paused.';

  @override
  String get offlineSyncingTitle => 'Back online';

  @override
  String offlineSyncingBody(Object count) {
    return 'Syncing $count saved change(s)…';
  }

  @override
  String get offlineRefreshing => 'Refreshing the latest data…';

  @override
  String get offlineBackOnline => 'You\'re back online';

  @override
  String get offlineBackOnlineBody =>
      'Saved changes are syncing and screens will refresh.';

  @override
  String get offlineActionBlocked => 'This action needs a connection.';

  @override
  String get offlineNoSavedData => 'No saved copy yet';

  @override
  String get offlineNoSavedDataBody =>
      'Connect to the internet once to keep this screen available offline.';

  @override
  String get offlineQueued => 'Saved for later';

  @override
  String offlinePendingChanges(Object count) {
    return '$count change(s) waiting to sync';
  }

  @override
  String get requiredField => 'This field is required.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get passwordTooShort => 'Use at least 8 characters.';

  @override
  String get all => 'All';

  @override
  String get none => 'None';

  @override
  String get optional => 'Optional';

  @override
  String get actions => 'Actions';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get apply => 'Apply';

  @override
  String get clear => 'Clear';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get filter => 'Filter';

  @override
  String get filters => 'Filters';

  @override
  String get refresh => 'Refresh';

  @override
  String get viewAll => 'View all';

  @override
  String get total => 'Total';

  @override
  String get status => 'Status';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get notes => 'Notes';

  @override
  String get description => 'Description';

  @override
  String get price => 'Price';

  @override
  String get cost => 'Cost';

  @override
  String get sku => 'SKU';

  @override
  String get category => 'Category';

  @override
  String get categories => 'Categories';

  @override
  String get product => 'Product';

  @override
  String get products => 'Products';

  @override
  String get order => 'Order';

  @override
  String get orders => 'Orders';

  @override
  String get customer => 'Customer';

  @override
  String get customers => 'Customers';

  @override
  String get inventory => 'Inventory';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get conversations => 'Inbox';

  @override
  String get inbox => 'Inbox';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get analytics => 'Analytics';

  @override
  String get more => 'More';

  @override
  String get logout => 'Sign out';

  @override
  String get login => 'Sign in';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to manage your store.';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordHint => 'Your password';

  @override
  String get tenantSetupTitle => 'Create your workspace';

  @override
  String get tenantSetupSubtitle =>
      'Tell us what your business is called. You can invite your team afterwards.';

  @override
  String get workspaceName => 'Workspace name';

  @override
  String get storeName => 'Store name';

  @override
  String get createWorkspace => 'Create workspace';

  @override
  String get switchWorkspace => 'Switch workspace';

  @override
  String get selectWorkspace => 'Select a workspace';

  @override
  String get noWorkspace => 'You don\'t have a workspace yet.';

  @override
  String get sessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get unauthorized => 'Your session has expired. Please sign in again.';

  @override
  String get forbidden => 'You don\'t have permission to do that.';

  @override
  String get notFound => 'We couldn\'t find what you were looking for.';

  @override
  String get serverError =>
      'Something went wrong on our end. Please try again.';

  @override
  String get validationError => 'Some of the details need attention.';

  @override
  String get signedOut => 'You have been signed out.';

  @override
  String get signOutConfirm => 'Sign out?';

  @override
  String get signOutMessage => 'You will need to sign in again on this device.';

  @override
  String get dashboardTitle => 'Overview';

  @override
  String get revenueToday => 'Revenue today';

  @override
  String get ordersToday => 'Orders today';

  @override
  String get averageOrderValue => 'Average order';

  @override
  String get revenueMonth => 'Revenue this month';

  @override
  String get ordersMonth => 'Orders this month';

  @override
  String get openConversations => 'Open chats';

  @override
  String get lowStockItems => 'Low stock';

  @override
  String get activeCustomers => 'Active customers';

  @override
  String get awaitingFulfilment => 'Awaiting fulfilment';

  @override
  String get revenueTrend => 'Revenue trend';

  @override
  String get topProducts => 'Top products';

  @override
  String get deadStock => 'Dead stock';

  @override
  String get noTopProducts => 'No sales in this period yet.';

  @override
  String get noDeadStock => 'Nothing is sitting still. Nice.';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get units => 'units';

  @override
  String get stock => 'Stock';

  @override
  String get lowStock => 'Low stock';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get inStock => 'In stock';

  @override
  String get adjustStock => 'Adjust stock';

  @override
  String get receiveStock => 'Receive stock';

  @override
  String get movements => 'Movements';

  @override
  String get quantity => 'Quantity';

  @override
  String get newQuantity => 'New quantity';

  @override
  String get note => 'Note';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get createProduct => 'New product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get productName => 'Product name';

  @override
  String get productStatus => 'Status';

  @override
  String get draft => 'Draft';

  @override
  String get active => 'Active';

  @override
  String get archived => 'Archived';

  @override
  String get inactive => 'Inactive';

  @override
  String get blocked => 'Blocked';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get processing => 'Processing';

  @override
  String get shipped => 'Shipped';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get partiallyPaid => 'Partially paid';

  @override
  String get paid => 'Paid';

  @override
  String get refunded => 'Refunded';

  @override
  String get orderNumber => 'Order number';

  @override
  String get paymentStatus => 'Payment';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get tax => 'Tax';

  @override
  String get shipping => 'Shipping';

  @override
  String get grandTotal => 'Total';

  @override
  String get items => 'Items';

  @override
  String get customerName => 'Customer name';

  @override
  String get customerPhone => 'Customer phone';

  @override
  String get changeStatus => 'Change status';

  @override
  String get allowedTransitions => 'Available actions';

  @override
  String get orderTimeline => 'History';

  @override
  String get createOrder => 'New order';

  @override
  String get selectCustomer => 'Select customer';

  @override
  String get selectProduct => 'Select product';

  @override
  String get variant => 'Variant';

  @override
  String get addToOrder => 'Add item';

  @override
  String get orderCreated => 'Order created.';

  @override
  String get orderUpdated => 'Order updated.';

  @override
  String get statusUpdated => 'Status updated.';

  @override
  String get createCategory => 'New category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryName => 'Category name';

  @override
  String get parentCategory => 'Parent category';

  @override
  String get sortOrder => 'Sort order';

  @override
  String get productsCount => 'Products';

  @override
  String get createCustomer => 'New customer';

  @override
  String get editCustomer => 'Edit customer';

  @override
  String get customerStatus => 'Status';

  @override
  String get totalSpent => 'Total spent';

  @override
  String get ordersCount => 'Orders';

  @override
  String get lastOrder => 'Last order';

  @override
  String get addresses => 'Addresses';

  @override
  String get conversationStatus => 'Status';

  @override
  String get open => 'Open';

  @override
  String get closed => 'Closed';

  @override
  String get unread => 'Unread';

  @override
  String get assignedTo => 'Assigned to';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get sendMessage => 'Send';

  @override
  String get messageHint => 'Write a reply…';

  @override
  String get sendNote => 'Add note';

  @override
  String get internalNote => 'Internal note';

  @override
  String get markRead => 'Mark as read';

  @override
  String get noMessages => 'No messages yet.';

  @override
  String get replyWindowClosed =>
      'The reply window is closed. Send a template to continue.';

  @override
  String get templateRequired => 'Template required';

  @override
  String get notificationCenter => 'Notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get markAsUnread => 'Mark as unread';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get noNotifications => 'You\'re all caught up.';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetPasswordSubtitle =>
      'Enter the code from your email and choose a new password.';

  @override
  String get resetToken => 'Reset code';

  @override
  String get resetTokenMissing =>
      'This reset link is incomplete. Request a new one.';

  @override
  String get passwordResetSuccess => 'Password updated';

  @override
  String get passwordResetSuccessMessage =>
      'You can now sign in with your new password.';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get sessions => 'Signed-in devices';

  @override
  String get revoke => 'Sign out';

  @override
  String get revokeOthers => 'Sign out other devices';

  @override
  String get currentSession => 'This device';

  @override
  String get notificationPreferences => 'Notification preferences';

  @override
  String get workspaceSettings => 'Workspace settings';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get dateRange => 'Date range';

  @override
  String get from => 'From';

  @override
  String get until => 'Until';

  @override
  String get kpi => 'Key figures';

  @override
  String get salesTrend => 'Sales trend';

  @override
  String get productPerformance => 'Product performance';

  @override
  String get stockHealth => 'Stock health';

  @override
  String get noAnalytics => 'No analytics for this period.';

  @override
  String get loadMore => 'Load more';

  @override
  String get endOfList => 'You\'ve reached the end.';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get invalidCredentials => 'The email or password is incorrect.';

  @override
  String get accountSuspended => 'This account is suspended. Contact support.';

  @override
  String get tenantRequired => 'Create a workspace to continue.';

  @override
  String get noPermission => 'You don\'t have permission to view this.';

  @override
  String get avatar => 'Profile photo';

  @override
  String get uploadPhoto => 'Upload photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get chooseImage => 'Choose an image';

  @override
  String get imageUploadFailed => 'The image could not be uploaded.';

  @override
  String get passwordChanged =>
      'Password changed. Other devices were signed out.';

  @override
  String get profileUpdated => 'Profile updated.';

  @override
  String get settingsUpdated => 'Settings updated.';

  @override
  String get preferencesUpdated => 'Preferences updated.';

  @override
  String get sessionRevoked => 'Device signed out.';

  @override
  String get allSessionsRevoked => 'Other devices signed out.';

  @override
  String get allNotificationsRead => 'All notifications marked as read.';

  @override
  String get messageSent => 'Message sent.';

  @override
  String get noteSent => 'Note added.';

  @override
  String get stockAdjusted => 'Stock adjusted.';

  @override
  String get stockReceived => 'Stock received.';

  @override
  String get customerCreated => 'Customer created.';

  @override
  String get customerUpdated => 'Customer updated.';

  @override
  String get customerDeleted => 'Customer deleted.';

  @override
  String get customerCrm => 'Customer CRM';

  @override
  String get conversation => 'Conversation';

  @override
  String get paidOrders => 'Paid orders';

  @override
  String get lastInteraction => 'Last interaction';

  @override
  String get aiSummary => 'AI summary';

  @override
  String get aiSummaryEmpty =>
      'No summary yet. Refresh to generate one from this customer\'s activity.';

  @override
  String get editSummary => 'Edit summary';

  @override
  String get refreshSummary => 'Refresh summary';

  @override
  String get summaryHint => 'Write a short summary of this customer.';

  @override
  String get summaryRefreshed => 'Summary refreshed.';

  @override
  String get summaryUpdated => 'Summary updated.';

  @override
  String get highlights => 'Highlights';

  @override
  String get specifications => 'Specifications';

  @override
  String get tags => 'Tags';

  @override
  String get shortDescription => 'Short description';

  @override
  String get seoTitle => 'SEO title';

  @override
  String get seoDescription => 'SEO description';

  @override
  String get seoKeywords => 'SEO keywords';

  @override
  String get linesHint => 'One item per line.';

  @override
  String get specificationsHint =>
      'One specification per line, as Label: value.';

  @override
  String get tagsHint => 'Separate tags with commas.';

  @override
  String get risks => 'Risks';

  @override
  String get opportunities => 'Opportunities';

  @override
  String get memories => 'Memories';

  @override
  String get addMemory => 'Add memory';

  @override
  String get editMemory => 'Edit memory';

  @override
  String get noMemories => 'No saved memories yet.';

  @override
  String get memoryKey => 'Key';

  @override
  String get memoryValue => 'Value';

  @override
  String get confidence => 'Confidence';

  @override
  String get confidenceRange => 'Enter a number between 0 and 100.';

  @override
  String get deleteMemory => 'Delete memory';

  @override
  String get deleteMemoryMessage =>
      'This memory will be removed from the customer record.';

  @override
  String get memorySaved => 'Memory saved.';

  @override
  String get memoryDeleted => 'Memory deleted.';

  @override
  String get timeline => 'Timeline';

  @override
  String get noActivity => 'No activity yet.';

  @override
  String get edited => 'Edited';

  @override
  String get productCreated => 'Product created.';

  @override
  String get productUpdated => 'Product updated.';

  @override
  String get productDeleted => 'Product deleted.';

  @override
  String get categoryCreated => 'Category created.';

  @override
  String get categoryUpdated => 'Category updated.';

  @override
  String get categoryDeleted => 'Category deleted.';

  @override
  String get deleteConfirmTitle => 'Delete?';

  @override
  String get deleteConfirmMessage => 'This action cannot be undone.';

  @override
  String get unsavedChanges => 'Discard changes?';

  @override
  String get discard => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get currency => 'Currency';

  @override
  String get storeCurrency => 'Store currency';

  @override
  String get storeCurrencyHelp =>
      'Converting rewrites current product, variant, bundle and shipping prices. Historical orders keep their original currency.';

  @override
  String get currentCurrency => 'Current currency';

  @override
  String get targetCurrency => 'New currency';

  @override
  String get previewConversion => 'Preview conversion';

  @override
  String get conversionRate => 'Exchange rate';

  @override
  String get rateSource => 'Rate source';

  @override
  String get rateFetchedAt => 'Rate fetched';

  @override
  String get variants => 'Variants';

  @override
  String get samplePrices => 'Sample prices';

  @override
  String get before => 'Before';

  @override
  String get after => 'After';

  @override
  String get convertCurrency => 'Convert currency';

  @override
  String get convertCurrencyTitle => 'Convert store currency?';

  @override
  String get convertCurrencyMessage =>
      'Current catalogue prices will be rewritten using the displayed rate. Historical orders and payments are not changed.';

  @override
  String get currencyConverted => 'Currency converted.';

  @override
  String get conversionHistory => 'Conversion history';

  @override
  String get selectCurrency => 'Select a currency';

  @override
  String get sameCurrency => 'The store already uses this currency.';

  @override
  String get displayCurrency => 'Display currency';

  @override
  String get displayCurrencyHint =>
      'Your own display preference. It never changes workspace prices or past transactions.';

  @override
  String get workspaceCurrencyHint =>
      'This follows the default store\'s base currency. Change it from the store\'s currency settings.';

  @override
  String get changeStoreCurrency => 'Change store currency';

  @override
  String get searchCurrencies => 'Search currencies by name or code';

  @override
  String get noCurrenciesMatch => 'No currencies match your search.';

  @override
  String decimalPlaces(Object count) {
    return '$count decimal places';
  }

  @override
  String get timezone => 'Timezone';

  @override
  String get locale => 'Language';

  @override
  String get contactEmail => 'Contact email';

  @override
  String get slug => 'Slug';

  @override
  String get readOnly => 'Read only';

  @override
  String get invalidNumber => 'Enter a number.';

  @override
  String get mustBePositive => 'Enter zero or a positive number.';

  @override
  String get confirmDelete => 'Yes, delete';

  @override
  String get emailNotifications => 'Email';

  @override
  String get whatsappNotifications => 'WhatsApp';

  @override
  String get noProducts => 'No products match your filters.';

  @override
  String get noOrders => 'No orders match your filters.';

  @override
  String get noCustomers => 'No customers match your filters.';

  @override
  String get noCategories => 'No categories yet.';

  @override
  String get noInventory => 'No stock records yet.';

  @override
  String get noConversations => 'No conversations match your filters.';

  @override
  String get addFirstProduct => 'Add your first product';

  @override
  String get addFirstCustomer => 'Add your first customer';

  @override
  String get addFirstCategory => 'Add your first category';

  @override
  String get orderDetails => 'Order details';

  @override
  String get customerDetails => 'Customer details';

  @override
  String get productDetails => 'Product details';

  @override
  String get inventoryDetails => 'Stock details';

  @override
  String get available => 'Available';

  @override
  String get reserved => 'Reserved';

  @override
  String get threshold => 'Low-stock threshold';

  @override
  String get store => 'Store';

  @override
  String get createdAt => 'Created';

  @override
  String get updatedAt => 'Updated';

  @override
  String get sale => 'Sale';

  @override
  String get purchase => 'Purchase';

  @override
  String get adjustment => 'Adjustment';

  @override
  String get returnIn => 'Return in';

  @override
  String get returnOut => 'Return out';

  @override
  String get transferIn => 'Transfer in';

  @override
  String get transferOut => 'Transfer out';

  @override
  String get initial => 'Initial';

  @override
  String get reference => 'Reference';

  @override
  String get balanceAfter => 'Balance after';

  @override
  String get markAll => 'Mark all';

  @override
  String get unreadOnly => 'Unread only';

  @override
  String get readOnlyFilter => 'Read';

  @override
  String get severity => 'Severity';

  @override
  String get categoryFilter => 'Category';

  @override
  String get notificationsEmpty => 'No notifications match this filter.';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get inAppNotifications => 'In-app notifications';

  @override
  String get teamActivity => 'Team activity';

  @override
  String get securityAlerts => 'Security alerts';

  @override
  String get mandatorySecurityHint => 'Always on to keep your account secure.';

  @override
  String get allCategories => 'All categories';

  @override
  String get allSeverities => 'All priorities';

  @override
  String get notificationNotFound => 'This notification could not be found.';

  @override
  String get deleteNotificationConfirm =>
      'Delete this notification? This cannot be undone.';

  @override
  String get notificationDeleted => 'Notification deleted.';

  @override
  String get notificationDetail => 'Notification details';

  @override
  String get openRelated => 'Open related';

  @override
  String get categoryOrders => 'Orders';

  @override
  String get categoryInventory => 'Inventory';

  @override
  String get categoryMessages => 'Messages';

  @override
  String get categoryCustomers => 'Customers';

  @override
  String get categoryBilling => 'Billing';

  @override
  String get categoryAi => 'AI insights';

  @override
  String get categoryApprovals => 'Approvals';

  @override
  String get categorySecurity => 'Security';

  @override
  String get categoryReports => 'Reports';

  @override
  String get categoryAnnouncements => 'Announcements';

  @override
  String get categoryTeam => 'Team';

  @override
  String get severityInfo => 'Info';

  @override
  String get severitySuccess => 'Success';

  @override
  String get severityWarning => 'Warning';

  @override
  String get severityCritical => 'Critical';

  @override
  String get reply => 'Reply';

  @override
  String get internal => 'Internal';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get custom => 'Custom';

  @override
  String get retryMessage => 'Retry';

  @override
  String get deliveryFailed => 'Delivery failed';

  @override
  String get sent => 'Sent';

  @override
  String get deliveredStatus => 'Delivered';

  @override
  String get readStatus => 'Read';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get failedStatus => 'Failed';

  @override
  String get assign => 'Assign';

  @override
  String get assignTo => 'Assign to';

  @override
  String get me => 'Me';

  @override
  String get allConversations => 'All';

  @override
  String get mine => 'Mine';

  @override
  String get unassignedFilter => 'Unassigned';

  @override
  String get unreadFilter => 'Unread';

  @override
  String get sendTemplate => 'Send template';

  @override
  String get templateName => 'Template name';

  @override
  String get languageCode => 'Language code';

  @override
  String get parameters => 'Parameters';

  @override
  String get requiredParameters => 'One value per line.';

  @override
  String get photoPermissionDenied =>
      'Photo access was denied. Enable it in Settings.';

  @override
  String get cameraPermissionDenied =>
      'Camera access was denied. Enable it in Settings.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get productImage => 'Product image';

  @override
  String get images => 'Images';

  @override
  String get noImages => 'No images yet.';

  @override
  String get defaultVariant => 'Default variant';

  @override
  String get variantName => 'Variant name';

  @override
  String get addVariant => 'Add variant';

  @override
  String get removeVariant => 'Remove';

  @override
  String get stockLevel => 'Stock level';

  @override
  String get priceRequired => 'A price is required.';

  @override
  String get orderItemsRequired => 'Add at least one item.';

  @override
  String get searchProducts => 'Search products';

  @override
  String get searchCustomers => 'Search customers';

  @override
  String get searchOrders => 'Search orders';

  @override
  String get searchConversations => 'Search conversations';

  @override
  String get noResults => 'No results.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String resultsCount(Object count) {
    return '$count results';
  }

  @override
  String pageOf(Object last, Object page) {
    return 'Page $page of $last';
  }

  @override
  String showingRange(Object from, Object to, Object total) {
    return 'Showing $from–$to of $total';
  }

  @override
  String get optionalNote => 'Add a note (optional)';

  @override
  String get confirmStatusChange => 'Change status?';

  @override
  String statusChangeMessage(Object status) {
    return 'The order will move to $status.';
  }

  @override
  String get orderTransitionNote => 'Note for the history (optional)';

  @override
  String get paymentMarkPaid => 'Mark as paid';

  @override
  String get selectVariant => 'Select a variant';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String quantityAvailable(Object count) {
    return '$count available';
  }

  @override
  String get insufficientStock => 'Not enough stock for this item.';

  @override
  String get workspace => 'Workspace';

  @override
  String get switchAction => 'Switch';

  @override
  String get notificationsChannelsUnavailable =>
      'Some channels are not configured on the server.';

  @override
  String get channelAvailable => 'Available';

  @override
  String get channelUnavailable => 'Unavailable';

  @override
  String get savePreferences => 'Save preferences';

  @override
  String get noPermissionTitle => 'Access restricted';

  @override
  String get noPermissionMessage =>
      'Your role does not include access to this area.';

  @override
  String get goToDashboard => 'Go to dashboard';

  @override
  String get sessionRevokeConfirm => 'Sign this device out?';

  @override
  String get sessionRevokeMessage => 'That device will need to sign in again.';

  @override
  String get revokeOthersConfirm => 'Sign out other devices?';

  @override
  String get revokeOthersMessage =>
      'Every other device will need to sign in again.';

  @override
  String get avatarRemoved => 'Profile photo removed.';

  @override
  String get avatarUpdated => 'Profile photo updated.';

  @override
  String get passwordMismatch => 'The passwords do not match.';

  @override
  String get currentPasswordIncorrect => 'The current password is incorrect.';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied.';

  @override
  String get details => 'Details';

  @override
  String get summary => 'Summary';

  @override
  String get revenue => 'Revenue';

  @override
  String get ordersLabel => 'Orders';

  @override
  String get average => 'Average';

  @override
  String get growth => 'Growth';

  @override
  String get previousPeriod => 'Previous period';

  @override
  String get notMeasurable => 'Not enough data';

  @override
  String get margin => 'Margin';

  @override
  String get profit => 'Profit';

  @override
  String get costCoverage => 'Cost coverage';

  @override
  String get stockValue => 'Stock value';

  @override
  String get conversationResponse => 'First response';

  @override
  String get deliveryRate => 'Delivery rate';

  @override
  String get repeatPurchase => 'Repeat purchase';

  @override
  String get noStore => 'No store selected';

  @override
  String get selectStore => 'Select store';

  @override
  String get storeFilter => 'Store';

  @override
  String get errorLoading => 'We couldn\'t load this screen.';

  @override
  String get seeMore => 'See more';

  @override
  String get seeLess => 'See less';

  @override
  String get account => 'Account';

  @override
  String get approvals => 'Approvals';

  @override
  String get attachment => 'Attachment';

  @override
  String get channelFilter => 'Channel';

  @override
  String get conversationAssignments => 'Conversation assignments';

  @override
  String get days => 'days';

  @override
  String get deliveryFailures => 'Delivery failures';

  @override
  String get forgotPasswordTitle => 'Forgot your password?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a link to reset it.';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get isTaxableHint =>
      'Tax is calculated by the server when the order is placed.';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String get lastLogin => 'Last sign-in';

  @override
  String get limitations => 'Data limitations';

  @override
  String get manual => 'Manual';

  @override
  String get newMessages => 'New messages';

  @override
  String get no => 'No';

  @override
  String get noteHint => 'Write an internal note…';

  @override
  String get orderItems => 'Order items';

  @override
  String get orderUpdates => 'Order updates';

  @override
  String get productNews => 'Product news';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get resetLinkSent => 'Check your inbox';

  @override
  String get resetLinkSentMessage =>
      'If that email is registered, a reset link is on its way.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get web => 'Web';

  @override
  String get weeklySummary => 'Weekly summary';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get yes => 'Yes';

  @override
  String get partially_paid => 'Partially paid';

  @override
  String get low_stock => 'Low stock';

  @override
  String get out_of_stock => 'Out of stock';

  @override
  String get healthy => 'Healthy';

  @override
  String get failed => 'Failed';

  @override
  String get suspended => 'Suspended';

  @override
  String get read => 'Read';

  @override
  String get connected => 'Connected';

  @override
  String get reorder => 'Reorder';

  @override
  String get invited => 'Invited';

  @override
  String get critical => 'Critical';

  @override
  String get warning => 'Warning';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get pending_confirmation => 'Pending confirmation';

  @override
  String get storefrontGroup => 'Storefront';

  @override
  String get storefrontSettings => 'Shop settings';

  @override
  String get shippingZones => 'Shipping zones';

  @override
  String get paymentSettings => 'Payment settings';

  @override
  String get noStores => 'No stores yet';

  @override
  String get noStoresMessage =>
      'Create a store before managing its shop settings.';

  @override
  String get storefrontEnabled => 'Shop published';

  @override
  String get storefrontEnabledHint =>
      'Customers can browse the shop and place orders.';

  @override
  String get storefrontDisabledHint => 'The shop is hidden from customers.';

  @override
  String get storefrontDisabledWarning =>
      'While unpublished, the shop link returns not found.';

  @override
  String get branding => 'Branding';

  @override
  String get logoUrl => 'Logo URL';

  @override
  String get tagline => 'Tagline';

  @override
  String get heroImageUrl => 'Cover image URL';

  @override
  String get contactDetails => 'Contact details';

  @override
  String get whatsappNumber => 'WhatsApp number';

  @override
  String get address => 'Address';

  @override
  String get openingHours => 'Opening hours';

  @override
  String get socialLinks => 'Social links';

  @override
  String get policies => 'Policies';

  @override
  String get deliveryNote => 'Delivery note';

  @override
  String get returnPolicy => 'Return policy';

  @override
  String get showOutOfStock => 'Show out-of-stock products';

  @override
  String get showOutOfStockHint =>
      'Display sold-out items with an out-of-stock label.';

  @override
  String get searchEngine => 'Search and sharing';

  @override
  String get searchEngineHint => 'Used by search results and link previews.';

  @override
  String get metaTitle => 'Page title';

  @override
  String get metaDescription => 'Page description';

  @override
  String get storefrontUpdated => 'Shop settings updated.';

  @override
  String get addShippingZone => 'Add shipping zone';

  @override
  String get editShippingZone => 'Edit shipping zone';

  @override
  String get noShippingZones => 'No shipping zones yet';

  @override
  String get noShippingZonesMessage =>
      'Add a zone to set the delivery fee for an area.';

  @override
  String get shippingZonesIntro =>
      'Fees match the city or area and are recalculated on the server at checkout.';

  @override
  String get deliveryFee => 'Delivery fee';

  @override
  String get freeShippingOver => 'Free delivery over';

  @override
  String get isActive => 'Active';

  @override
  String get zoneName => 'Zone name';

  @override
  String get englishHint =>
      'English is the canonical copy customers see when a translation is missing.';

  @override
  String get arabicHint =>
      'Optional. Arabic readers see the English copy when a field is empty.';

  @override
  String get missingArabic => 'Arabic missing';

  @override
  String get zoneDescription => 'Zone description';

  @override
  String get shippingMethodName => 'Delivery method name';

  @override
  String get shippingMethodNameHint =>
      'The delivery option customers see at checkout.';

  @override
  String get shippingMethodDescription => 'Delivery method description';

  @override
  String get shippingMethodDescriptionHint =>
      'Optional detail shown under the delivery option.';

  @override
  String get deliveryInstructions => 'Delivery instructions';

  @override
  String get deliveryInstructionsHint =>
      'What the customer should know before the courier arrives.';

  @override
  String get shippingTerms => 'Delivery terms';

  @override
  String get shippingTermsHint =>
      'Optional customer-facing terms for this delivery option.';

  @override
  String get city => 'City';

  @override
  String get cityHint => 'Leave empty to apply to every city.';

  @override
  String get areas => 'Areas';

  @override
  String get areasHint => 'Separate areas with commas.';

  @override
  String get freeShippingThreshold => 'Free delivery threshold';

  @override
  String get freeShippingThresholdHint =>
      'Leave empty to disable free delivery.';

  @override
  String get enterNumber => 'Enter a number.';

  @override
  String get enterPositiveNumber => 'Enter zero or a positive number.';

  @override
  String get enterWholeNumber => 'Enter a whole number.';

  @override
  String get shippingZoneCreated => 'Shipping zone created.';

  @override
  String get shippingZoneUpdated => 'Shipping zone updated.';

  @override
  String deleteShippingZoneMessage(Object name) {
    return 'Delete “$name”? This cannot be undone.';
  }

  @override
  String get shippingZoneDeleted => 'Shipping zone deleted.';

  @override
  String get paymentMethods => 'Payment methods';

  @override
  String get paymentsIntro =>
      'Customers only see methods the store can genuinely honour.';

  @override
  String get noPaymentMethods => 'No payment methods are available.';

  @override
  String get cashOnDelivery => 'Cash on delivery';

  @override
  String get codEnabled => 'Enable cash on delivery';

  @override
  String get codEnabledHint =>
      'Orders stay unpaid until the courier collects the amount.';

  @override
  String get codInstructions => 'Payment instructions';

  @override
  String get codInstructionsHint => 'Shown to the customer at checkout.';

  @override
  String get onlinePaymentsNote =>
      'Online payment is unavailable until a payment provider is connected. No card is charged and no fake payment is recorded.';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get paymentSettingsUpdated => 'Payment settings updated.';

  @override
  String get aboutDukavo => 'About Dukavo';

  @override
  String get aboutUs => 'About us';

  @override
  String get accessControl => 'Access control';

  @override
  String get accessToken => 'Access token';

  @override
  String get accessTokenHint => 'Token issued by the messaging provider.';

  @override
  String get action => 'Action';

  @override
  String get actionType => 'Action type';

  @override
  String get activateTenant => 'Activate';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get addressLineOne => 'Address line 1';

  @override
  String get addressLineTwo => 'Address line 2';

  @override
  String get aiActions => 'AI actions';

  @override
  String get aiSettings => 'AI settings';

  @override
  String get aiSettingsByokLabel => 'Route through my own keys';

  @override
  String get aiSettingsByokOff =>
      'The platform has not enabled bring-your-own-key, so this workspace cannot store its own provider keys.';

  @override
  String get aiSettingsByokOptedIn =>
      'This workspace now prefers its own keys.';

  @override
  String get aiSettingsByokOptedOut =>
      'This workspace is back on platform keys.';

  @override
  String get aiSettingsByokSubtitle =>
      'When on, tasks in this workspace prefer your own provider credentials over the platform\'s, with the platform\'s providers as fallback.';

  @override
  String get aiSettingsByokTitle => 'Bring your own key';

  @override
  String get aiSettingsFeatureDisabled =>
      'Feature disabled for this workspace.';

  @override
  String get aiSettingsFeatureEnabled => 'Feature enabled for this workspace.';

  @override
  String get aiSettingsFeaturePlatformOff =>
      'The platform has this feature off, so it cannot be enabled here.';

  @override
  String get aiSettingsFeaturesSubtitle =>
      'Turn a feature off for this workspace only; other workspaces are unaffected.';

  @override
  String get aiSettingsFeaturesTitle => 'Features';

  @override
  String get aiSettingsKeyApiKeyHint =>
      'Paste the key once; it is never shown again.';

  @override
  String get aiSettingsKeyApiKeyLabel => 'API key';

  @override
  String get aiSettingsKeyBaseUrlHint =>
      'Optional. Must be a public provider endpoint — local or private addresses are refused.';

  @override
  String get aiSettingsKeyBaseUrlLabel => 'Base URL';

  @override
  String get aiSettingsKeyFormHint =>
      'Storing again for the same provider replaces that provider\'s key.';

  @override
  String get aiSettingsKeyFormTitle => 'Store or rotate a key';

  @override
  String get aiSettingsKeyModelLabel => 'Default model';

  @override
  String get aiSettingsKeyProviderLabel => 'Provider';

  @override
  String aiSettingsKeyRevokeBody(Object masked, Object provider) {
    return 'Revoke $masked on $provider? Routing falls back to the platform\'s providers.';
  }

  @override
  String get aiSettingsKeyRevokeTitle => 'Revoke this key';

  @override
  String get aiSettingsKeyRevoked => 'Key revoked.';

  @override
  String get aiSettingsKeyStored => 'Key stored.';

  @override
  String get aiSettingsKeyTest => 'Test';

  @override
  String get aiSettingsKeyTestFailed => 'The connection check failed.';

  @override
  String aiSettingsKeyTestOk(Object latency) {
    return 'Your key answered in $latency ms.';
  }

  @override
  String get aiSettingsKeyTooShort => 'Use at least 8 characters.';

  @override
  String get aiSettingsKeysEmpty => 'No keys stored.';

  @override
  String get aiSettingsKeysSubtitle =>
      'Your key is encrypted at rest and shown only as its last characters.';

  @override
  String get aiSettingsKeysTitle => 'My keys';

  @override
  String get aiSettingsNoProviders =>
      'No providers are available for a workspace key.';

  @override
  String get aiSettingsPlatformOffBody =>
      'AI is turned off for the whole platform. Nothing here will run until the Dukavo team enables it.';

  @override
  String get aiSettingsPlatformOffTitle => 'Off platform-wide';

  @override
  String get aiSettingsUsageCost => 'Estimated cost';

  @override
  String get aiSettingsUsageEstimatesNote =>
      'Costs are estimates from declared model prices — operational signal, never a billing figure.';

  @override
  String get aiSettingsUsageFailures => 'Failed requests';

  @override
  String aiSettingsUsageRow(Object requests, Object tokens) {
    return '$requests requests · $tokens tokens';
  }

  @override
  String get aiSettingsUsageTitle => 'AI usage';

  @override
  String get aiSettingsUsageTodayRequests => 'Requests today';

  @override
  String get aiSettingsUsageTodayTokens => 'Tokens today';

  @override
  String get altText => 'Alt text';

  @override
  String get altTextHint => 'Describe the image for screen readers.';

  @override
  String get answer => 'Answer';

  @override
  String get answerAr => 'Answer (Arabic)';

  @override
  String get approve => 'Approve';

  @override
  String get approved => 'Approved';

  @override
  String get area => 'Area';

  @override
  String get areaHint => 'Delivery area within the city.';

  @override
  String get auditLog => 'Audit log';

  @override
  String get auditLogHint =>
      'Every sensitive change, with who made it and when.';

  @override
  String get automationActionsHint =>
      'What the rule does when its conditions match.';

  @override
  String get automationHub => 'Automations';

  @override
  String get automationHubHint => 'Rules that react to store events.';

  @override
  String get automationRules => 'Rules';

  @override
  String get automationRulesHint => 'Trigger, conditions and actions.';

  @override
  String get automationRuns => 'Runs';

  @override
  String get automationRunsHint => 'Each time a rule was evaluated.';

  @override
  String get automationTasks => 'Tasks';

  @override
  String get automationTasksHint => 'Deferred work created by automations.';

  @override
  String get automations => 'Automations';

  @override
  String get billingInterval => 'Billing interval';

  @override
  String get bodyHtml => 'Body (HTML)';

  @override
  String get bodyHtmlAr => 'Body (Arabic HTML)';

  @override
  String get bodyHtmlHint => 'Full article body in HTML.';

  @override
  String get browseShop => 'Browse a shop';

  @override
  String get bundleItems => 'Bundle items';

  @override
  String get bundleItemsHint =>
      'JSON list of product variant ids and quantities.';

  @override
  String get bundles => 'Bundles';

  @override
  String get businessAccountId => 'Business account ID';

  @override
  String get businessType => 'Business type';

  @override
  String get calculatedByStore => 'Calculated by the store';

  @override
  String get cancelledOrders => 'Cancelled orders';

  @override
  String get cart => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyHint => 'Add a product to start an order.';

  @override
  String get catalogue => 'Catalogue';

  @override
  String get checkout => 'Checkout';

  @override
  String get chooseDeliveryCity => 'Choose a delivery city.';

  @override
  String get chooseVariant => 'Choose a variant';

  @override
  String get classification => 'Classification';

  @override
  String get cogs => 'Cost of goods';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get company => 'Company';

  @override
  String get completed => 'Completed';

  @override
  String get completedAt => 'Completed at';

  @override
  String get conditions => 'Conditions';

  @override
  String get conditionsHint => 'JSON conditions that must all match.';

  @override
  String get connectedAt => 'Connected at';

  @override
  String get contactAttempts => 'Contact attempts';

  @override
  String get contactMessages => 'Contact messages';

  @override
  String get contactMessagesHint =>
      'Messages sent through the public contact form.';

  @override
  String get contactUs => 'Contact us';

  @override
  String get contactUsHint => 'Send us a message and we will reply by email.';

  @override
  String get content => 'Content';

  @override
  String get contentPages => 'Content pages';

  @override
  String get contentPagesHint => 'Editable legal and informational pages.';

  @override
  String get context => 'Context';

  @override
  String get continueShopping => 'Continue shopping';

  @override
  String get cooldownSeconds => 'Cooldown (seconds)';

  @override
  String get costIncomplete => 'Cost data is incomplete';

  @override
  String get countryCode => 'Country code';

  @override
  String get countryCodeHint => 'Two-letter ISO code, e.g. SA.';

  @override
  String get createAutomation => 'New automation';

  @override
  String get createTeamMember => 'Invite team member';

  @override
  String get currencyCodeHint => 'Three-letter ISO code, e.g. SAR.';

  @override
  String get dailyDemand => 'Daily demand';

  @override
  String get daysOfCover => 'Days of cover';

  @override
  String get decrease => 'Decrease';

  @override
  String get defaultLabel => 'Default';

  @override
  String get defaultStore => 'Default store';

  @override
  String get deleteImage => 'Delete image';

  @override
  String get deleteImageMessage => 'Delete this image? This cannot be undone.';

  @override
  String get deleted => 'Deleted';

  @override
  String get delivery => 'Delivery';

  @override
  String get deliveryAddress => 'Delivery address';

  @override
  String get detectedAt => 'Detected at';

  @override
  String get disconnectAccount => 'Disconnect account';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get discountType => 'Discount type';

  @override
  String get discountValue => 'Discount value';

  @override
  String get discounts => 'Discounts';

  @override
  String get dismissalReason => 'Dismissal reason';

  @override
  String get dismissed => 'Dismissed';

  @override
  String get disqualified => 'Disqualified';

  @override
  String get doNotContact => 'Do not contact';

  @override
  String get draftMessage => 'Draft message';

  @override
  String get dueAt => 'Due at';

  @override
  String get editAltText => 'Edit alt text';

  @override
  String get editTeamMember => 'Edit team member';

  @override
  String get errorMessage => 'Error message';

  @override
  String get estimatedTotal => 'Estimated total';

  @override
  String get estimatedValue => 'Estimated value';

  @override
  String get event => 'Event';

  @override
  String get excerpt => 'Excerpt';

  @override
  String get excerptAr => 'Excerpt (Arabic)';

  @override
  String get execute => 'Execute';

  @override
  String get executed => 'Executed';

  @override
  String get expired => 'Expired';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String exportSaved(Object path) {
    return 'Saved to $path';
  }

  @override
  String get faqEntries => 'FAQ entries';

  @override
  String get faqEntriesHint => 'Questions shown on the public FAQ page.';

  @override
  String get features => 'Features';

  @override
  String get finalTotalOnConfirmation =>
      'The store confirms the final total after checking stock and delivery.';

  @override
  String get finishedAt => 'Finished at';

  @override
  String get firstStoreName => 'First store name';

  @override
  String get firstStoreNameHint =>
      'Your workspace starts with one store. You can add more later.';

  @override
  String get fixed => 'Fixed';

  @override
  String get followUpSent => 'Follow-up sent';

  @override
  String get free => 'Free';

  @override
  String get fullName => 'Full name';

  @override
  String get getStarted => 'Get started';

  @override
  String get grossProfit => 'Gross profit';

  @override
  String get growthSeries => 'Growth series';

  @override
  String get growthSeriesHint =>
      'Daily recovered value over the selected period.';

  @override
  String get highlighted => 'Highlighted';

  @override
  String get imageTooLarge => 'This image is too large.';

  @override
  String get imagesUploaded => 'Images uploaded.';

  @override
  String get increase => 'Increase';

  @override
  String get information => 'Information';

  @override
  String get insights => 'Insights';

  @override
  String get insufficientHistory => 'Not enough history to forecast yet.';

  @override
  String get intro => 'Introduction';

  @override
  String get invalidJson => 'Enter valid JSON.';

  @override
  String get inventoryIntelligence => 'Inventory intelligence';

  @override
  String get inviteTeamMember => 'Invite member';

  @override
  String get ipAddress => 'IP address';

  @override
  String get itemCount => 'Item count';

  @override
  String get joinWaitlist => 'Join the waitlist';

  @override
  String get joined => 'Joined';

  @override
  String get lastContactedAt => 'Last contacted';

  @override
  String get lastTriggered => 'Last triggered';

  @override
  String lastUpdated(Object date) {
    return 'Last updated $date';
  }

  @override
  String get leadsAndAudience => 'Leads and audience';

  @override
  String get limitationsHint => 'What this report cannot measure yet.';

  @override
  String get limits => 'Limits';

  @override
  String get localeHint => 'Language code, e.g. en or ar.';

  @override
  String get makeDefault => 'Make default';

  @override
  String get markCompleted => 'Mark completed';

  @override
  String get marketing => 'Marketing';

  @override
  String get marketingHub => 'Marketing';

  @override
  String get marketingHubHint => 'Public content, plans, FAQs and audience.';

  @override
  String get matched => 'Matched';

  @override
  String get members => 'Members';

  @override
  String get merchantWorkspace => 'Merchant workspace';

  @override
  String get message => 'Message';

  @override
  String get messageSentHint => 'We reply to the email you provide.';

  @override
  String get monthly => 'Monthly';

  @override
  String get moveDown => 'Move down';

  @override
  String get moveUp => 'Move up';

  @override
  String get netSales => 'Net sales';

  @override
  String get newInPeriod => 'New in period';

  @override
  String get newStatus => 'New';

  @override
  String get newValues => 'New values';

  @override
  String get newsletter => 'Newsletter';

  @override
  String get newsletters => 'Newsletters';

  @override
  String get newslettersHint => 'Articles published to the public newsletter.';

  @override
  String get nextFollowUpAt => 'Next follow-up';

  @override
  String get noAiActions => 'No AI actions yet';

  @override
  String get noAltText => 'No alt text';

  @override
  String get noAuditEntries => 'No audit entries';

  @override
  String get noAutomationRules => 'No automation rules';

  @override
  String get noAutomationRuns => 'No runs yet';

  @override
  String get noAutomationTasks => 'No tasks yet';

  @override
  String get noBundles => 'No bundles yet';

  @override
  String get noContactMessages => 'No contact messages';

  @override
  String get noContentPages => 'No content pages';

  @override
  String get noFaqEntries => 'No FAQ entries';

  @override
  String get noFeatures => 'No features listed';

  @override
  String get noMembers => 'No members';

  @override
  String get noNewsletters => 'No newsletters';

  @override
  String get noPlatformUsers => 'No platform users';

  @override
  String get noPreviousData => 'No previous data';

  @override
  String get noPricingPlans => 'No pricing plans';

  @override
  String get noRecoveryOpportunities => 'No recovery opportunities';

  @override
  String get noRoles => 'No roles';

  @override
  String get noSubscribers => 'No subscribers';

  @override
  String get noTeamMembers => 'No team members';

  @override
  String get noTenants => 'No tenants';

  @override
  String get noWaitlistEntries => 'No waitlist entries';

  @override
  String get noWhatsappAccounts => 'No WhatsApp accounts';

  @override
  String get oldValues => 'Old values';

  @override
  String get oneTime => 'One time';

  @override
  String onlyLeft(Object count) {
    return 'Only $count left';
  }

  @override
  String get openValue => 'Open value';

  @override
  String get orderConfirmed => 'Order confirmed';

  @override
  String get orderNotes => 'Order notes';

  @override
  String get orderPlacedNoTracking =>
      'Order placed, but no tracking link was returned.';

  @override
  String get orderSummary => 'Order summary';

  @override
  String get orderTracking => 'Order tracking';

  @override
  String get overview => 'Overview';

  @override
  String get pageKey => 'Page key';

  @override
  String get passwordMinHint => 'At least 8 characters.';

  @override
  String get paused => 'Paused';

  @override
  String get payload => 'Payload';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get pendingApproval => 'Pending approval';

  @override
  String get percentage => 'Percentage';

  @override
  String get permissions => 'Permissions';

  @override
  String get permissionsHint => 'Choose what this role can do.';

  @override
  String get phoneNumberId => 'Phone number ID';

  @override
  String get placeOrder => 'Place order';

  @override
  String get platformConsole => 'Platform console';

  @override
  String get platformOverview => 'Platform overview';

  @override
  String get platformPasswordSelfService =>
      'Platform accounts change their password from their profile.';

  @override
  String get platformRoles => 'Platform roles';

  @override
  String get platformScope => 'Platform';

  @override
  String get platformUsers => 'Platform users';

  @override
  String get position => 'Position';

  @override
  String get postalCode => 'Postal code';

  @override
  String get priceComingSoonHint =>
      'Pricing is not enforced yet; leave empty if there is no price.';

  @override
  String get pricing => 'Pricing';

  @override
  String get pricingComingSoon => 'Pricing is coming soon.';

  @override
  String get pricingPlans => 'Pricing plans';

  @override
  String get pricingPlansHint => 'Plans shown on the public pricing page.';

  @override
  String get pricingSubtitle => 'Simple plans that grow with your store.';

  @override
  String get priority => 'Priority';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get proceedToCheckout => 'Proceed to checkout';

  @override
  String get productImages => 'Product images';

  @override
  String get productImagesHint => 'Upload, reorder and describe each image.';

  @override
  String get productImagesLimits => 'JPEG, PNG or WebP up to 5 MB each.';

  @override
  String get published => 'Published';

  @override
  String get publishedAt => 'Published at';

  @override
  String get question => 'Question';

  @override
  String get questionAr => 'Question (Arabic)';

  @override
  String readingMinutes(Object count) {
    return '$count min read';
  }

  @override
  String get readyToRecover => 'Ready to recover';

  @override
  String get reason => 'Reason';

  @override
  String get recommended => 'Recommended';

  @override
  String get recovered => 'Recovered';

  @override
  String get recoveredRevenue => 'Recovered revenue';

  @override
  String get recoveredValue => 'Recovered value';

  @override
  String get recovery => 'Recovery';

  @override
  String get recoveryOpportunities => 'Recovery opportunities';

  @override
  String get recoverySummary => 'Recovery summary';

  @override
  String get recoverySummaryUnavailable => 'Recovery summary is unavailable.';

  @override
  String get reject => 'Reject';

  @override
  String get rejected => 'Rejected';

  @override
  String get rejectionReason => 'Rejection reason';

  @override
  String get replied => 'Replied';

  @override
  String get resourceType => 'Resource type';

  @override
  String get responded => 'Responded';

  @override
  String get result => 'Result';

  @override
  String get role => 'Role';

  @override
  String get roles => 'Roles';

  @override
  String get rolesAndWorkspaces => 'Roles and workspaces';

  @override
  String get rolesHint => 'Control what each team member can see and do.';

  @override
  String get runCount => 'Run count';

  @override
  String get saveTrackingLink => 'Save this link to check the order later.';

  @override
  String get saved => 'Saved';

  @override
  String get scope => 'Scope';

  @override
  String get sectionsJson => 'Sections (JSON)';

  @override
  String get sectionsJsonHint => 'JSON array of content sections.';

  @override
  String get seePricing => 'See pricing';

  @override
  String selectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get send => 'Send';

  @override
  String get sendAnotherMessage => 'Send another message';

  @override
  String get setPrimary => 'Set primary';

  @override
  String get shippingRevenue => 'Shipping revenue';

  @override
  String get shop => 'Shop';

  @override
  String get shopLinkRequired => 'Open a shop link';

  @override
  String shopLinkRequiredHint(Object store, Object tenant) {
    return 'A shop link looks like /shop/$tenant/$store. Ask the merchant for theirs.';
  }

  @override
  String get siteHeroSubtitle => 'The commerce platform for modern merchants.';

  @override
  String get slugHint => 'Lowercase letters, numbers and dashes.';

  @override
  String get snoozed => 'Snoozed';

  @override
  String get sortName => 'Name';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortPriceHigh => 'Price: high to low';

  @override
  String get sortPriceLow => 'Price: low to high';

  @override
  String get sortRecommended => 'Recommended';

  @override
  String get source => 'Source';

  @override
  String get startedAt => 'Started at';

  @override
  String get state => 'State / province';

  @override
  String get stillHaveQuestions => 'Still have questions?';

  @override
  String get storeId => 'Store ID';

  @override
  String get stores => 'Stores';

  @override
  String get storesCount => 'Stores';

  @override
  String get subject => 'Subject';

  @override
  String get submitForApproval => 'Submit for approval';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get subscribeToNewsletter => 'Subscribe to our newsletter';

  @override
  String get subscribeToNewsletterHint =>
      'Product updates and merchant tips, no spam.';

  @override
  String get subscribed => 'Subscribed';

  @override
  String get subscribedAt => 'Subscribed at';

  @override
  String get subscribers => 'Subscribers';

  @override
  String get subscribersHint => 'People who opted in to the newsletter.';

  @override
  String get subtotalEstimate => 'Subtotal estimate';

  @override
  String get suggestedOrder => 'Suggested order';

  @override
  String get superAdmin => 'Super admin';

  @override
  String get suspendTenant => 'Suspend';

  @override
  String get systemRole => 'System role';

  @override
  String get systemRolePermissionsLocked =>
      'System role permissions cannot be changed.';

  @override
  String get taxCollected => 'Tax collected';

  @override
  String get teamAndAccess => 'Team and access';

  @override
  String get teamHub => 'Team';

  @override
  String get teamHubHint => 'People, roles and the audit trail.';

  @override
  String get teamMembers => 'Team members';

  @override
  String get teamMembersHint => 'Invite people and manage their access.';

  @override
  String get tenantScope => 'Workspace';

  @override
  String get tenants => 'Tenants';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get timezoneHint => 'IANA timezone, e.g. Asia/Riyadh.';

  @override
  String get title => 'Title';

  @override
  String get titleAr => 'Title (Arabic)';

  @override
  String get tooManyImages => 'You can upload at most 8 images at once.';

  @override
  String get totalsResolvedAtCheckout =>
      'The final total is resolved by the store at checkout.';

  @override
  String get findOrder => 'Find order';

  @override
  String get track => 'Track';

  @override
  String get trackOrder => 'Track an order';

  @override
  String get trackOrderHelp =>
      'Paste the token or the tracking link from your confirmation.';

  @override
  String get trackingToken => 'Tracking token';

  @override
  String get trackingTokenHint => 'The token from your order confirmation.';

  @override
  String get trigger => 'Trigger';

  @override
  String get triggerConversationMessage => 'Conversation message';

  @override
  String get triggerInventoryLowStock => 'Low stock';

  @override
  String get triggerOrderCreated => 'Order created';

  @override
  String get triggerOrderStatusChanged => 'Order status changed';

  @override
  String get triggerRecoveryDetected => 'Recovery detected';

  @override
  String get unsubscribed => 'Unsubscribed';

  @override
  String get unsubscribedAt => 'Unsubscribed at';

  @override
  String get uploadImages => 'Upload images';

  @override
  String get userAccounts => 'User accounts';

  @override
  String get users => 'Users';

  @override
  String get usersCount => 'Users';

  @override
  String get verifyAccount => 'Verify account';

  @override
  String get viewDukavo => 'View Dukavo';

  @override
  String get waitlist => 'Waitlist';

  @override
  String get waitlistHint => 'People waiting for an invitation.';

  @override
  String get waitlistJoined => 'You are on the list';

  @override
  String get waitlistJoinedHint => 'We will email you when a place opens.';

  @override
  String get webhookVerifyToken => 'Webhook verify token';

  @override
  String get webhookVerifyTokenHint => 'Used to verify incoming webhook calls.';

  @override
  String get whatsappAccounts => 'WhatsApp accounts';

  @override
  String get workspaces => 'Workspaces';

  @override
  String get yearly => 'Yearly';

  @override
  String get newLabel => 'New';

  @override
  String get pending_approval => 'Pending approval';

  @override
  String get contacted => 'Contacted';

  @override
  String get eligible => 'Eligible';

  @override
  String get platform => 'Platform';

  @override
  String get tenant => 'Workspace';

  @override
  String get splashTagline => 'Your Business. Connected.';

  @override
  String get splashPreparing => 'Preparing your workspace…';

  @override
  String get splashAi => 'AI automation';

  @override
  String get publicNavHome => 'Home';

  @override
  String get publicNavFeatures => 'Features';

  @override
  String get publicNavPricing => 'Pricing';

  @override
  String get publicNavAbout => 'About';

  @override
  String get publicNavMore => 'More';

  @override
  String get publicNavHowItWorks => 'How it works';

  @override
  String get publicNavFaq => 'FAQ';

  @override
  String get publicNavBlog => 'Blog';

  @override
  String get publicNavContact => 'Contact';

  @override
  String get publicOpenApp => 'Open workspace';

  @override
  String get publicBackToSite => 'Back to site';

  @override
  String get publicExplore => 'Explore Dukavo';

  @override
  String get publicRegister => 'Register';

  @override
  String publicCopyright(Object year) {
    return '© $year Dukavo. All rights reserved.';
  }

  @override
  String get publicLoginInviteOnly => 'Accounts are created by invitation.';

  @override
  String get publicRegisterHaveAccount => 'Already have an account? Sign in';

  @override
  String get publicFooterTagline =>
      'Commerce operations for growing businesses.';

  @override
  String get publicFooterProduct => 'Product';

  @override
  String get publicFooterResources => 'Resources';

  @override
  String get publicFooterCompany => 'Company';

  @override
  String get publicFooterLegal => 'Legal';

  @override
  String get publicMenuExplore => 'Explore';

  @override
  String get publicMenuAccount => 'Account';

  @override
  String get publicMenuPreferences => 'Preferences';

  @override
  String get publicMenuLegal => 'Legal';

  @override
  String get publicMenuOpenAppHint => 'Continue to your workspace';

  @override
  String get publicMenuSignInHint => 'Sign in to manage your store';

  @override
  String get publicHomeBadge => 'Arabic-first commerce platform';

  @override
  String get publicHomeTitleLine1 => 'Run your whole store';

  @override
  String get publicHomeTitleFrom => 'from';

  @override
  String get publicHomeTitleAccent => 'one place';

  @override
  String get publicHomeSubtitle =>
      'Products, inventory, orders, customers and WhatsApp conversations — everything you need to run your store in one place.';

  @override
  String get publicHomePrimary => 'Join the waitlist';

  @override
  String get publicHomeSecondary => 'See how Dukavo works';

  @override
  String get publicHomeTickArabic => 'Arabic-first';

  @override
  String get publicHomeTickWhatsapp => 'WhatsApp built in';

  @override
  String get publicHomeTickTeam => 'Team permissions';

  @override
  String get publicHomeEcosystemLabel => 'What runs on Dukavo';

  @override
  String get publicHomeEcosystemProducts => 'Products';

  @override
  String get publicHomeEcosystemInventory => 'Inventory';

  @override
  String get publicHomeEcosystemOrders => 'Orders';

  @override
  String get publicHomeEcosystemCustomers => 'Customers';

  @override
  String get publicHomeEcosystemConversations => 'Conversations';

  @override
  String get publicHomeEcosystemTeam => 'Team';

  @override
  String get publicHomePillarsEyebrow => 'Features';

  @override
  String get publicHomePillarsTitle => 'Five pillars, one system';

  @override
  String get publicHomePillarsSubtitle =>
      'One place for products, stock, orders, customers and conversations.';

  @override
  String get publicHomeStoryEyebrow => 'From conversation to order';

  @override
  String get publicHomeStoryTitle => 'Without the chaos';

  @override
  String get publicHomeStorySubtitle => 'The same five steps, every time.';

  @override
  String get publicHomePricingEyebrow => 'Pricing';

  @override
  String get publicHomePricingTitle => 'Plans that grow with your business';

  @override
  String get publicHomePricingSubtitle =>
      'Final pricing is being prepared. Join the waitlist to hear first.';

  @override
  String get publicHomeFaqEyebrow => 'FAQ';

  @override
  String get publicHomeFaqTitle => 'Questions you might have';

  @override
  String get publicHomeBlogEyebrow => 'Blog & newsletter';

  @override
  String get publicHomeBlogTitle => 'Ideas for a more organised business';

  @override
  String get publicHomeCtaTitle => 'Ready to get organised with us?';

  @override
  String get publicHomeCtaBody =>
      'Join the waitlist and we’ll set up your products, orders, customers and conversations together.';

  @override
  String get publicHomeCtaAction => 'Join the waitlist';

  @override
  String get publicStepConversationTitle => 'The conversation';

  @override
  String get publicStepConversationBody =>
      'The customer writes on WhatsApp, and the message lands in your Dukavo inbox.';

  @override
  String get publicStepCustomerTitle => 'The customer';

  @override
  String get publicStepCustomerBody =>
      'Dukavo recognises the customer and opens their profile with their history.';

  @override
  String get publicStepOrderTitle => 'The order';

  @override
  String get publicStepOrderBody =>
      'Conversation becomes a structured order, with its items and its status.';

  @override
  String get publicStepInventoryTitle => 'The inventory';

  @override
  String get publicStepInventoryBody =>
      'Quantities drop automatically, with an alert when stock runs low.';

  @override
  String get publicStepTeamTitle => 'The team';

  @override
  String get publicStepTeamBody =>
      'Every staff member sees and does only what their permissions allow.';

  @override
  String get publicFeaturesTitle =>
      'Everything you need to run your store efficiently';

  @override
  String get publicFeaturesSubtitle =>
      'The capabilities available today, and what is still on the way.';

  @override
  String get publicFeaturesAvailable => 'Available now';

  @override
  String get publicFeaturesAvailableHint =>
      'These capabilities are live in the merchant workspace.';

  @override
  String get publicFeaturesUpcoming => 'Coming soon';

  @override
  String get publicFeaturesUpcomingHint =>
      'Planned capabilities, shown honestly until they ship.';

  @override
  String get publicFeaturesEmpty => 'The public feature catalogue is empty.';

  @override
  String get publicPricingTitle => 'Plans that fit how you sell';

  @override
  String get publicPricingHeroSubtitle =>
      'Transparent plans, published from the Dukavo platform.';

  @override
  String get publicPricingInviteTitle => 'Invite-only onboarding';

  @override
  String get publicPricingInviteBody =>
      'Dukavo is onboarding merchants from the waitlist. Join it and we’ll contact you when a place opens.';

  @override
  String get publicPricingTaxNote =>
      'Prices shown are before tax unless the plan says otherwise.';

  @override
  String get publicPricingFaqTitle => 'Pricing questions';

  @override
  String get publicPricingFaqSubtitle =>
      'What merchants usually ask before choosing a plan.';

  @override
  String get publicFaqTitle => 'Frequently asked questions';

  @override
  String get publicFaqSubtitle =>
      'Short answers about Dukavo, onboarding and the waitlist.';

  @override
  String get publicFaqContactTitle => 'Still have questions?';

  @override
  String get publicFaqContactBody =>
      'Send us a message and we’ll reply to the email you provide.';

  @override
  String get publicBlogTitle => 'Blog';

  @override
  String get publicBlogSubtitle =>
      'Guides and product notes from the Dukavo team.';

  @override
  String get publicBlogFeatured => 'Latest article';

  @override
  String get publicBlogAll => 'All articles';

  @override
  String get publicBlogEmptyTitle => 'No articles yet';

  @override
  String get publicBlogEmptyBody =>
      'We haven’t published anything yet. Check back soon.';

  @override
  String get publicBlogNotFoundTitle => 'Article not found';

  @override
  String get publicBlogNotFoundBody =>
      'This article may have been unpublished or removed.';

  @override
  String get publicBlogBack => 'All articles';

  @override
  String get publicContactTitle => 'Talk to us';

  @override
  String get publicContactSubtitle =>
      'Questions about Dukavo, pricing or onboarding? Send a message.';

  @override
  String get publicContactResponse =>
      'We usually reply within two business days.';

  @override
  String get publicContactSuccessTitle => 'Message sent';

  @override
  String get publicContactSuccessBody => 'We reply to the email you provide.';

  @override
  String get publicContactHoneypot => 'Website';

  @override
  String get publicWaitlistTitle => 'Join the waitlist';

  @override
  String get publicWaitlistSubtitle => 'Be first to know when a place opens.';

  @override
  String get publicWaitlistBody =>
      'Leave your email and we’ll contact you when Dukavo is ready for your store.';

  @override
  String get publicWaitlistPrivacy =>
      'We only use this email for your invitation.';

  @override
  String get publicAboutBadge => 'About Dukavo';

  @override
  String get publicAboutContactCta => 'Talk to us';

  @override
  String get publicAboutUnavailableTitle => 'This page isn’t available yet';

  @override
  String get publicAboutUnavailableBody =>
      'It may still be in preparation. Please check back soon.';

  @override
  String get publicContentUnavailableTitle => 'This page isn’t available yet';

  @override
  String get publicContentUnavailableBody =>
      'It may still be in preparation. Please check back soon.';

  @override
  String get publicContentBackHome => 'Back to home';

  @override
  String get publicRegisterBadge => 'Invite only';

  @override
  String get publicRegisterTitle => 'Get an invitation';

  @override
  String get publicRegisterSubtitle =>
      'Dukavo creates merchant accounts by invitation, so onboarding stays deliberate and personal.';

  @override
  String get publicRegisterStepOneTitle => 'Join the waitlist';

  @override
  String get publicRegisterStepOneBody =>
      'Tell us about your store and the way you sell.';

  @override
  String get publicRegisterStepTwoTitle => 'Receive your invitation';

  @override
  String get publicRegisterStepTwoBody =>
      'We email an invitation when a place opens for your kind of business.';

  @override
  String get publicRegisterStepThreeTitle => 'Sign in and set up';

  @override
  String get publicRegisterStepThreeBody =>
      'Use the email in your invitation to sign in and create your workspace.';

  @override
  String get publicRegisterNoteTitle => 'Why invite-only?';

  @override
  String get publicRegisterNoteBody =>
      'It lets us help each merchant migrate products, stock and customers properly instead of leaving them to a blank screen.';

  @override
  String get publicVerifyTitle => 'Verify email';

  @override
  String get publicVerifyPendingTitle => 'Check your inbox';

  @override
  String get publicVerifyPendingBody =>
      'Verify your email so we can send invitations, receipts and account notices.';

  @override
  String get publicVerifyVerifiedTitle => 'Email verified';

  @override
  String get publicVerifyVerifiedBody =>
      'Your email is verified. You’re all set.';

  @override
  String get publicVerifyResend => 'Resend verification email';

  @override
  String get publicVerifyResendAgain => 'Send it again';

  @override
  String get publicVerifySent =>
      'If the server allows it, the email is on its way.';

  @override
  String get publicVerifySessionNote =>
      'Sending verification email requires a signed-in session. If the server refuses, sign in again and retry.';

  @override
  String get publicHowTitle => 'How Dukavo works';

  @override
  String get publicHowSubtitle =>
      'From a WhatsApp message to a fulfilled order, without re-typing anything.';

  @override
  String get publicHowSetupTitle => 'Setting up';

  @override
  String get publicHowSetupSubtitle =>
      'Three short steps when your invitation arrives.';

  @override
  String get publicHowSetupOneTitle => 'Add your products';

  @override
  String get publicHowSetupOneBody =>
      'Import a catalogue or add products one by one, with prices and stock.';

  @override
  String get publicHowSetupTwoTitle => 'Invite your team';

  @override
  String get publicHowSetupTwoBody =>
      'Give each person the permissions their job needs, nothing more.';

  @override
  String get publicHowSetupThreeTitle => 'Connect your channels';

  @override
  String get publicHowSetupThreeBody =>
      'Bring WhatsApp conversations into the same inbox as orders and customers.';

  @override
  String get publicHowSecurityTitle => 'Permissions are enforced by the server';

  @override
  String get publicHowSecurityBody =>
      'The app hides what you cannot use, and the API checks every request independently.';

  @override
  String get publicHowCtaTitle => 'Ready to get organised with us?';

  @override
  String get publicHowCtaBody =>
      'Join the waitlist and we’ll set up your products, orders, customers and conversations together.';

  @override
  String get translationAssistant => 'AI translations';

  @override
  String get translationOpen => 'Translations';

  @override
  String get translationReviewHint =>
      'AI drafts stay private until you approve them.';

  @override
  String get translationNoSelection => 'Nothing selected';

  @override
  String translationSelectedCount(Object count) {
    return '$count selected';
  }

  @override
  String translationApproveSelectedCount(Object count) {
    return 'Approve $count';
  }

  @override
  String get translationGenerateTitle => 'Generate translations';

  @override
  String get translationGenerateHint =>
      'Pick the fields and languages to translate. The result is a proposal, not a published change.';

  @override
  String get translationSourceLanguage => 'Source language';

  @override
  String get translationSourceUnknown =>
      'The source language could not be detected. Choose it explicitly.';

  @override
  String translationDetectedLanguage(Object confidence, Object language) {
    return 'Detected $language ($confidence% confidence)';
  }

  @override
  String get translationSourceRequired => 'Source language required';

  @override
  String get translationSourceRequiredHint =>
      'Choose the language this copy is written in so Dukavo translates from the right language.';

  @override
  String get translationFields => 'Fields';

  @override
  String get translationTargets => 'Target languages';

  @override
  String get translationNoTargets =>
      'No other enabled language is available yet.';

  @override
  String get translationGenerate => 'Generate';

  @override
  String get translationUsageTitle => 'AI usage today';

  @override
  String translationUsageSummary(Object cost, Object requests, Object tokens) {
    return '$requests requests · $tokens tokens · about $cost estimated cost';
  }

  @override
  String get translationReviewTitle => 'Review';

  @override
  String get translationStale => 'Stale';

  @override
  String get translationManuallyEdited => 'Manually edited';

  @override
  String get translationSourceCopy => 'Source';

  @override
  String get translationNotTranslatedYet => 'Not translated yet.';

  @override
  String translationRejectionReasonValue(Object reason) {
    return 'Rejected: $reason';
  }

  @override
  String get translationPublishedCopy => 'Still public';

  @override
  String get translationApprove => 'Approve';

  @override
  String get translationEdit => 'Edit';

  @override
  String get translationReject => 'Reject';

  @override
  String get translationRegenerate => 'Regenerate';

  @override
  String get translationStatusNotTranslated => 'Not translated';

  @override
  String get translationStatusGenerating => 'Generating';

  @override
  String get translationStatusGenerated => 'Generated';

  @override
  String get translationStatusNeedsReview => 'Needs review';

  @override
  String get translationStatusApproved => 'Approved';

  @override
  String get translationStatusRejected => 'Rejected';

  @override
  String get translationStatusFailed => 'Failed';

  @override
  String get translationStatusStale => 'Stale';

  @override
  String get translationGenerated => 'Translations generated for review.';

  @override
  String get translationApprovedMessage =>
      'Translation approved and published.';

  @override
  String get translationUpdated =>
      'Translation updated and returned to review.';

  @override
  String get translationRejectedMessage => 'Translation rejected.';

  @override
  String get translationNothingSelected =>
      'Select at least one translation first.';

  @override
  String get translationTextRequired => 'Enter the translated text.';

  @override
  String get translationEditApprovedTitle => 'Edit published translation?';

  @override
  String get translationEditApprovedMessage =>
      'The current public copy stays live until you approve the new text.';

  @override
  String get translationEditHint => 'Edit the translation';

  @override
  String get translationRejectReason => 'Reason (optional)';

  @override
  String get translationRejectReasonHint =>
      'Tell the reviewer why this proposal was rejected.';

  @override
  String get translationOverwriteMessage =>
      'This replaces the current draft. Manually edited text and published copy need your confirmation before regeneration.';

  @override
  String get register => 'Register';

  @override
  String get choosePaymentRail => 'Choose how to pay';

  @override
  String get onlineRedirectNote =>
      'You will continue to the provider\'s secure page. This order stays unpaid until the provider confirms.';

  @override
  String get bankTransferNote =>
      'Transfer the total to the store and keep the receipt. The store confirms the order when the money arrives.';

  @override
  String get paymentProvider => 'Provider';

  @override
  String get paymentRail => 'Payment method';

  @override
  String get paymentAttempt => 'Attempt';

  @override
  String get paymentAmount => 'Amount';

  @override
  String get paymentReference => 'Reference';

  @override
  String get paymentPendingNote =>
      'Waiting for the provider to confirm. This page refreshes automatically.';

  @override
  String get paymentPaidNote => 'The provider confirmed this payment.';

  @override
  String get paymentLinkHint =>
      'Open this link in your browser to pay. The order updates only after the provider confirms.';

  @override
  String get paymentLinkCopied => 'Payment link copied.';

  @override
  String get copyPaymentLink => 'Copy payment link';

  @override
  String get retryPayment => 'Try payment again';

  @override
  String get orderAwaitingPayment => 'Awaiting payment';

  @override
  String get bankTransfer => 'Bank transfer';

  @override
  String get codNote =>
      'Pay the courier on delivery. The order stays unpaid until then.';

  @override
  String get twoFactorTitle => 'Two-step verification';

  @override
  String get twoFactorSubtitle => 'Confirm it\'s you to finish signing in.';

  @override
  String get twoFactorPrompt =>
      'Enter the 6-digit code from your authenticator app.';

  @override
  String get twoFactorCode => 'Authentication code';

  @override
  String get twoFactorCodePlaceholder => '000000';

  @override
  String get twoFactorCodeLength => 'Enter the 6-digit code.';

  @override
  String get twoFactorVerify => 'Verify and sign in';

  @override
  String get verifying => 'Verifying';

  @override
  String get twoFactorUseRecovery => 'Use a recovery code';

  @override
  String get twoFactorUseCode => 'Use an authenticator code';

  @override
  String get twoFactorRecoveryCode => 'Recovery code';

  @override
  String get twoFactorRecoveryHint =>
      'One of the single-use codes you saved when you turned on two-step verification.';

  @override
  String get onboardingPreferencesTitle => 'A few things about you';

  @override
  String get onboardingPreferencesSubtitle =>
      'We guessed these from your network and browser to save you time. Check them, change anything that is wrong, or skip for now.';

  @override
  String get onboardingPersonalTitle => 'Personal information';

  @override
  String get onboardingPersonalHint =>
      'How your name and photo appear to your team.';

  @override
  String get onboardingLocationHint =>
      'Location helps us show local times. A guess from your network is approximate, never verified.';

  @override
  String get onboardingDisplayHint =>
      'Choose how Dukavo looks and reads for you.';

  @override
  String get onboardingDetectedBadge => 'Detected for you';

  @override
  String get onboardingApproximateBadge =>
      'Some values are an estimate from your network. Review them before saving.';

  @override
  String get onboardingSave => 'Save preferences';

  @override
  String get onboardingSkip => 'Skip for now';

  @override
  String get onboardingSaved => 'Preferences saved.';

  @override
  String get onboardingSkipped =>
      'No problem — you can change these any time in your profile.';

  @override
  String get onboardingFootnote =>
      'These are personal settings. They never change a store\'s currency, prices or past orders.';

  @override
  String get onboardingPromptBody =>
      'Confirm your language, currency and time zone so Dukavo feels right.';

  @override
  String get onboardingPromptAction => 'Review preferences';

  @override
  String get nameHint => 'Your full name.';

  @override
  String get bio => 'Bio';

  @override
  String get bioHint => 'A sentence or two about you. Optional.';

  @override
  String get location => 'Location';

  @override
  String get country => 'Country';

  @override
  String get countryPlaceholder => 'Choose a country';

  @override
  String get countrySearch => 'Search by name, code or dial code';

  @override
  String get cityManualHint =>
      'Can\'t find it? Type the name — manual entry is always accepted.';

  @override
  String get phoneCountry => 'Phone country code';

  @override
  String get phoneCountryHint => 'The country your phone number belongs to.';

  @override
  String get timezonePlaceholder => 'Choose a time zone';

  @override
  String get timezoneSearch => 'Search time zones';

  @override
  String get dateFormat => 'Date format';

  @override
  String get timeFormat => 'Time format';

  @override
  String get timeFormat24 => '24-hour (14:30)';

  @override
  String get timeFormat12 => '12-hour (2:30 PM)';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get preferences => 'Display preferences';

  @override
  String get accountInformation => 'Account information';

  @override
  String get accountMetaDesc => 'Membership and security at a glance.';

  @override
  String get accountType => 'Account type';

  @override
  String get accountTypeMember => 'Member';

  @override
  String get memberSince => 'Member since';

  @override
  String get passwordNever => 'Never changed';

  @override
  String get profileComplete => 'Your profile is complete.';

  @override
  String get profileCompletion => 'Profile completeness';

  @override
  String get workspaceSeparationHint =>
      'Changing these never changes a store\'s currency, prices or past orders.';

  @override
  String get locationAndPreferences => 'Location and preferences';

  @override
  String get locationAndPreferencesDesc =>
      'Personal to you — separate from any workspace settings.';

  @override
  String get securityCenter => 'Security centre';

  @override
  String get securityActivity => 'Security activity';

  @override
  String get securityActivityDesc =>
      'Sign-ins, password changes and session changes on your account.';

  @override
  String get securityActivityEmpty => 'No security activity yet.';

  @override
  String get sessionsDesc =>
      'Every device currently signed in to your account.';

  @override
  String get twoFactor => 'Two-step verification';

  @override
  String get twoFactorDesc =>
      'Ask for a code from your authenticator app when signing in.';

  @override
  String get twoFactorOn => 'On';

  @override
  String get twoFactorOff => 'Off';

  @override
  String get twoFactorEnable => 'Turn on';

  @override
  String get twoFactorEnabled => 'Two-step verification is on.';

  @override
  String get twoFactorDisabled => 'Two-step verification is off.';

  @override
  String get twoFactorConfirm => 'Turn on verification';

  @override
  String get twoFactorSetupIntro =>
      'Open your authenticator app, add this key, then enter the code it shows.';

  @override
  String get twoFactorSecret => 'Setup key';

  @override
  String get twoFactorSecretOnce =>
      'This key is shown once. Store it somewhere safe.';

  @override
  String get twoFactorProvisioningUri => 'Setup link';

  @override
  String twoFactorActiveSince(Object time) {
    return 'On since $time';
  }

  @override
  String get recoveryCodesTitle => 'Recovery codes';

  @override
  String get recoveryCodesOnce =>
      'Save these now. Each code works once, and they will not be shown again.';

  @override
  String get recoveryCodesRegenerated => 'New recovery codes created.';

  @override
  String recoveryCodesRemaining(Object count) {
    return '$count recovery codes left';
  }

  @override
  String get regenerateRecoveryCodes => 'New recovery codes';

  @override
  String get regenerateIntro =>
      'Enter a current authenticator code to replace your recovery codes. The old ones stop working.';

  @override
  String get disableTwoFactor => 'Turn off';

  @override
  String get currentPasswordRequired => 'Enter your current password.';

  @override
  String get requiresAuthenticationCode =>
      'Enter an authenticator code or a recovery code.';

  @override
  String get useAuthenticatorCode => 'Use an authenticator code';

  @override
  String get useRecoveryCode => 'Use a recovery code';

  @override
  String get recoveryCode => 'Recovery code';

  @override
  String get editProfileHint => 'Name, photo, bio and contact details.';

  @override
  String get changePasswordDesc =>
      'Use a strong password you do not use anywhere else.';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get supportSearchHint => 'Search guides and topics';

  @override
  String get supportBrowseTopics => 'Browse by topic';

  @override
  String get supportFeatured => 'Featured guides';

  @override
  String get supportPopular => 'Most read guides';

  @override
  String supportArticlesCount(Object count) {
    return '$count articles';
  }

  @override
  String get supportSearchEmptyTitle => 'No matching guides';

  @override
  String get supportSearchEmptyBody =>
      'Try a shorter term, or clear the search and browse by topic.';

  @override
  String get supportEmptyCategoryTitle => 'No articles yet';

  @override
  String get supportEmptyCategoryBody =>
      'Nothing has been published in this topic yet.';

  @override
  String get supportNotFoundTitle => 'We could not find this guide';

  @override
  String get supportNotFoundBody =>
      'It may have moved or been renamed, or it is not available to you.';

  @override
  String get supportRelated => 'Related guides';

  @override
  String get supportAllTopics => 'Back to all topics';

  @override
  String get supportFeedbackTitle => 'Was this guide helpful?';

  @override
  String get supportFeedbackYes => 'Yes';

  @override
  String get supportFeedbackNo => 'No';

  @override
  String get supportFeedbackCommentLabel => 'Anything to add? (optional)';

  @override
  String get supportFeedbackCommentHint => 'What were you trying to do?';

  @override
  String get supportFeedbackSend => 'Send answer';

  @override
  String get supportFeedbackThanks =>
      'Your answer helps us improve this guide.';

  @override
  String get supportFeedbackFailed =>
      'Could not send your answer. Please try again.';

  @override
  String get integrations => 'Integrations';

  @override
  String get integrationsSubtitle =>
      'Every channel your customers can reach you on.';

  @override
  String get integrationsRefresh => 'Refresh';

  @override
  String get integrationsConnect => 'Connect';

  @override
  String integrationsConnectChannel(Object channel) {
    return 'Connect $channel';
  }

  @override
  String get integrationsEditConnection => 'Edit connection';

  @override
  String get integrationsAvailabilityAvailable => 'Available';

  @override
  String get integrationsAvailabilityAwaitingConfiguration =>
      'Awaiting configuration';

  @override
  String get integrationsAvailabilityAwaitingProviderAccess =>
      'Awaiting provider access';

  @override
  String get integrationsStatusPending => 'Pending';

  @override
  String get integrationsStatusConnected => 'Connected';

  @override
  String get integrationsStatusDisconnected => 'Disconnected';

  @override
  String get integrationsStatusError => 'Error';

  @override
  String get integrationsHealthUnknown => 'Not checked';

  @override
  String get integrationsHealthHealthy => 'Healthy';

  @override
  String get integrationsHealthDegraded => 'Degraded';

  @override
  String get integrationsHealthFailing => 'Failing';

  @override
  String get integrationsCapabilities => 'Capabilities';

  @override
  String get integrationsConnections => 'Connections';

  @override
  String get integrationsNoConnections => 'Nothing connected yet.';

  @override
  String get integrationsAllStores => 'All stores';

  @override
  String get integrationsName => 'Connection name';

  @override
  String get integrationsNameHint => 'e.g. Sales line';

  @override
  String get integrationsStore => 'Store';

  @override
  String get integrationsCredentials => 'Credentials';

  @override
  String get integrationsCredentialsHint =>
      'Values are encrypted at rest and never shown again. Leave a secret blank to keep the stored value.';

  @override
  String get integrationsRequired => 'Required';

  @override
  String get integrationsOptional => 'Optional';

  @override
  String get integrationsConfigured => 'Stored';

  @override
  String get integrationsSecretHint => 'Stored — leave blank to keep it';

  @override
  String get integrationsAwaitingAccessTitle =>
      'Provider access not granted yet';

  @override
  String get integrationsAwaitingAccessBody =>
      'This channel is declared but Dukavo has no approved access to its API. You can save credentials now; the connection stays pending until access is granted and a real test succeeds.';

  @override
  String get integrationsAwaitingConfigTitle =>
      'Platform configuration missing';

  @override
  String get integrationsAwaitingConfigBody =>
      'The installation is missing the platform-level keys this channel needs. Ask a platform administrator to configure it.';

  @override
  String get integrationsWebhook => 'Webhook URL';

  @override
  String get integrationsCopied => 'Copied.';

  @override
  String get integrationsCopyFailed =>
      'This device blocked clipboard access — copy it by hand.';

  @override
  String get integrationsTest => 'Test';

  @override
  String get integrationsReconnect => 'Reconnect';

  @override
  String get integrationsDisconnect => 'Disconnect';

  @override
  String integrationsDisconnectTitle(Object name) {
    return 'Disconnect $name?';
  }

  @override
  String get integrationsDisconnectBody =>
      'Customers will no longer reach you through this connection. Conversations stay in the inbox.';

  @override
  String get integrationsSaved => 'Connection saved.';

  @override
  String get integrationsDisconnected => 'Connection disconnected.';

  @override
  String get integrationsTested => 'Connection tested.';

  @override
  String get integrationsReconnected => 'Connection re-established.';

  @override
  String get integrationsError => 'This connection reported an error.';

  @override
  String get integrationsEmptyTitle => 'No channels available';

  @override
  String get integrationsEmptyBody =>
      'No messaging channels are declared in this installation.';

  @override
  String get integrationsNeverChecked => 'Never checked';

  @override
  String get integrationsCapabilityText => 'Text';

  @override
  String get integrationsCapabilityImage => 'Images';

  @override
  String get integrationsCapabilityDocument => 'Documents';

  @override
  String get integrationsCapabilityAudio => 'Audio';

  @override
  String get integrationsCapabilityVoice => 'Voice notes';

  @override
  String get integrationsCapabilityVideo => 'Video';

  @override
  String get integrationsCapabilityTemplate => 'Templates';

  @override
  String get integrationsCapabilityDeliveryStatus => 'Delivery status';

  @override
  String get integrationsCapabilityReadStatus => 'Read receipts';

  @override
  String get integrationsCapabilityMediaDownload => 'Media download';

  @override
  String get integrationsCapabilityTyping => 'Typing indicator';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get environment => 'Environment';

  @override
  String get configuration => 'Configuration';

  @override
  String get platformSettings => 'Platform settings';

  @override
  String get platformSettingsSubtitle =>
      'One place for the configuration the whole platform shares. Tenant and store settings stay separate.';

  @override
  String get platformSettingsSpecialists =>
      'AI provider credentials and prompts, and the payment catalogue, are administered in the web platform console. This screen links to what the phone can safely change.';

  @override
  String get platformSettingsAuditNote =>
      'Every save is recorded in the audit log with the operator, the previous value and the new one. Secrets are redacted.';

  @override
  String get platformSettingsSections => 'Configuration sections';

  @override
  String get platformSettingsControls => 'Platform controls';

  @override
  String get platformSettingsOperations => 'Operations';

  @override
  String platformSettingsSectionMeta(Object overrides, Object settings) {
    return '$settings settings · $overrides overridden';
  }

  @override
  String platformSettingsSecretCount(Object count) {
    return '$count secret';
  }

  @override
  String get platformSettingsOverrides => 'Overrides';

  @override
  String get platformSettingsSecrets => 'Secrets';

  @override
  String get platformSettingsDefinitions => 'Definitions';

  @override
  String get platformSettingsRuntime => 'Runtime';

  @override
  String get platformSettingsMaintenanceActive => 'Maintenance mode is on';

  @override
  String get platformSettingsOpenMaintenance => 'Open maintenance';

  @override
  String get platformSettingsSaved => 'Settings saved.';

  @override
  String get platformSettingsReadOnlyTitle => 'Read-only for your role';

  @override
  String get platformSettingsReadOnlyBody =>
      'You can read this section but not change it. Ask a platform administrator for the matching permission.';

  @override
  String get platformSettingsEmptySection =>
      'No settings are defined for this section.';

  @override
  String platformSettingsUnsaved(Object count) {
    return '$count unsaved change(s)';
  }

  @override
  String get platformSettingsClearOverride =>
      'Reset to the environment or application default';

  @override
  String get platformSettingsRequiresRestart => 'Applies on next request';

  @override
  String platformSettingsSecretHint(Object hint) {
    return 'Ends in $hint';
  }

  @override
  String get platformSettingsSecretPlaceholder =>
      'Enter a new value to replace the stored secret';

  @override
  String get platformSettingsSecretConfigured => 'Configured';

  @override
  String get platformSettingsSecretMissing => 'Not configured';

  @override
  String get platformSettingsChooseOption => 'Choose an option';

  @override
  String platformSettingsRange(Object max, Object min) {
    return 'Range $min–$max';
  }

  @override
  String get platformSettingsSourceDatabase => 'Platform setting';

  @override
  String get platformSettingsSourceEnvironment => 'Environment';

  @override
  String get platformSettingsSourceDefault => 'Application default';

  @override
  String get settingsGroupIdentity => 'Identity';

  @override
  String get settingsGroupApplication => 'Application';

  @override
  String get settingsGroupBrand => 'Brand';

  @override
  String get settingsGroupContact => 'Contact';

  @override
  String get settingsGroupFormat => 'Formats';

  @override
  String get settingsGroupLanguage => 'Languages';

  @override
  String get settingsGroupNumber => 'Numbers';

  @override
  String get settingsGroupPassword => 'Password policy';

  @override
  String get settingsGroupRateLimits => 'Rate limits';

  @override
  String get settingsGroupRegion => 'Region';

  @override
  String get settingsGroupRouting => 'Routing';

  @override
  String get settingsGroupRuntime => 'Runtime';

  @override
  String get settingsGroupSession => 'Sessions';

  @override
  String get settingsGroupSocial => 'Social';

  @override
  String get settingsGroupState => 'State';

  @override
  String get settingsGroupTransport => 'Transport';

  @override
  String get settingsGroupDriver => 'Driver';

  @override
  String get settingsGroupGeneral => 'General';

  @override
  String get platformSettingsFeaturesTitle => 'Platform features';

  @override
  String get platformSettingsFeaturesSubtitle =>
      'Platform-wide availability switches.';

  @override
  String get platformSettingsFeaturesNoteTitle =>
      'Availability, not entitlement';

  @override
  String get platformSettingsFeaturesNoteBody =>
      'Turning a feature off removes it for every tenant, regardless of plan or permission. Data is preserved and the switch is reversible.';

  @override
  String platformSettingsFeaturesEnabled(Object count) {
    return '$count enabled';
  }

  @override
  String platformSettingsFeaturesTotal(Object count) {
    return 'of $count';
  }

  @override
  String get platformSettingsFeaturesSearch => 'Search features';

  @override
  String get platformSettingsFeaturesEmptyTitle => 'No features match';

  @override
  String get platformSettingsFeaturesEmptyBody =>
      'Try a different search term.';

  @override
  String platformSettingsFeatureEnabled(Object name) {
    return '$name is now available.';
  }

  @override
  String platformSettingsFeatureDisabled(Object name) {
    return '$name has been withdrawn.';
  }

  @override
  String get featureGroupIntelligence => 'Intelligence';

  @override
  String get featureGroupChannels => 'Channels';

  @override
  String get featureGroupCommunication => 'Communication';

  @override
  String get featureGroupOperations => 'Operations';

  @override
  String get featureGroupCommerce => 'Commerce';

  @override
  String get featureGroupGrowth => 'Growth';

  @override
  String get platformSettingsHealthTitle => 'Integration health';

  @override
  String get platformSettingsHealthSubtitle =>
      'Last recorded state and on-demand probes.';

  @override
  String get platformSettingsHealthReadTitle => 'Reading does not probe';

  @override
  String get platformSettingsHealthReadBody =>
      'This screen shows the last recorded state. A probe calls the provider, so it only runs when you ask for it.';

  @override
  String get platformSettingsHealthEmpty => 'No integrations are registered.';

  @override
  String get platformSettingsHealthStateConnected => 'Connected';

  @override
  String get platformSettingsHealthStateDisconnected => 'Disconnected';

  @override
  String get platformSettingsHealthStateInvalidCredentials =>
      'Invalid credentials';

  @override
  String get platformSettingsHealthStateRateLimited => 'Rate limited';

  @override
  String get platformSettingsHealthStateServiceUnavailable =>
      'Service unavailable';

  @override
  String get platformSettingsHealthStateConfigurationRequired =>
      'Configuration required';

  @override
  String get platformSettingsHealthStateNotTested => 'Not tested';

  @override
  String get platformSettingsHealthStateDisabled => 'Disabled';

  @override
  String platformSettingsHealthChecked(Object name) {
    return '$name probe completed.';
  }

  @override
  String platformSettingsHealthCheckedAt(Object when) {
    return 'Checked $when';
  }

  @override
  String get platformSettingsHealthNever => 'Never checked';

  @override
  String get platformSettingsHealthTest => 'Run check';

  @override
  String get platformSettingsHistoryTitle => 'Configuration history';

  @override
  String get platformSettingsHistorySubtitle =>
      'Who changed what, and what it replaced.';

  @override
  String get platformSettingsHistoryFilter => 'Setting key';

  @override
  String get platformSettingsHistoryFilterHint => 'email.mail_host';

  @override
  String get platformSettingsHistoryRows => 'Rows';

  @override
  String get platformSettingsHistoryEmpty => 'No changes yet';

  @override
  String get platformSettingsHistoryEmptyFiltered =>
      'No change matches this key.';

  @override
  String get platformSettingsHistoryEmptyBody =>
      'Saving a setting will record it here.';

  @override
  String get platformSettingsHistoryNone => 'None';

  @override
  String platformSettingsHistorySecret(Object hint) {
    return 'Secret · ends in $hint';
  }

  @override
  String get platformSettingsHistorySystem => 'System';

  @override
  String get platformSettingsInfrastructureTitle => 'Infrastructure';

  @override
  String get platformSettingsInfrastructureSubtitle =>
      'Read-only values managed by the deployment environment.';

  @override
  String get platformSettingsInfraReadOnlyTitle =>
      'Managed by the deployment environment';

  @override
  String get platformSettingsInfraReadOnlyBody =>
      'These values are read-only here by design. Change them in the deployment environment and redeploy; secrets are shown as configured or not configured only.';

  @override
  String get platformSettingsInfraRuntimeTitle => 'Running process';

  @override
  String get platformSettingsInfraVariablesTitle => 'Environment variables';

  @override
  String get platformSettingsInfraPhp => 'PHP';

  @override
  String get platformSettingsInfraLaravel => 'Laravel';

  @override
  String get platformSettingsInfraDatabase => 'Database';

  @override
  String get platformSettingsInfraCache => 'Cache';

  @override
  String get platformSettingsInfraQueue => 'Queue';

  @override
  String get platformSettingsInfraSession => 'Session';

  @override
  String get platformSettingsInfraMailer => 'Mailer';

  @override
  String get platformSettingsInfraFilesystem => 'Filesystem';

  @override
  String get actionPreviews => 'Action previews';

  @override
  String get actionUrl => 'Action URL';

  @override
  String get activateTenantMessage => 'Activate this tenant?';

  @override
  String get activeVersion => 'Active version';

  @override
  String get activityLog => 'Activity log';

  @override
  String get adapter => 'Adapter';

  @override
  String get addPaymentConnection => 'Add payment connection';

  @override
  String get aiAdminReadOnlyNote =>
      'This surface is read-only apart from credential rotation.';

  @override
  String get aiAdministration => 'AI administration';

  @override
  String get aiCopilot => 'AI copilot';

  @override
  String get aiCopilotHint =>
      'The copilot answers only from the dashboard\'s real figures and never invents numbers.';

  @override
  String get aiCopilotQuestionHint =>
      'Example: what should I focus on this week?';

  @override
  String get aiFeatureLimits => 'AI feature limits';

  @override
  String get aiInsights => 'AI insights';

  @override
  String get aiPrompts => 'Prompts';

  @override
  String get aiServing => 'AI serving';

  @override
  String get aiTasks => 'AI tasks';

  @override
  String get aiTestConnection => 'Test connection';

  @override
  String get aiUsage30Days => 'Usage over 30 days';

  @override
  String get apiKey => 'API key';

  @override
  String get applyTemplateUpdate => 'Apply template update';

  @override
  String get applyTemplateUpdateMessage =>
      'Apply the newer template version to this installation?';

  @override
  String get approveAiActionMessage => 'Approve this AI action?';

  @override
  String get archiveTemplate => 'Archive template';

  @override
  String get archiveTemplateMessage =>
      'Archive this template? New stores will no longer see it.';

  @override
  String get askCopilot => 'Ask copilot';

  @override
  String get attempt => 'Attempt';

  @override
  String get attempts => 'Attempts';

  @override
  String get audience => 'Audience';

  @override
  String get automationInstallations => 'Automation installations';

  @override
  String get automationInstallationsHint =>
      'Rules installed from platform templates.';

  @override
  String get automationTemplates => 'Automation templates';

  @override
  String get automationTemplatesHint =>
      'Ready-made platform blueprints you can install in your store.';

  @override
  String get availability => 'Availability';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get byokDisabled => 'Platform key is active';

  @override
  String get byokEnabled => 'Tenant key is active';

  @override
  String get cacheHit => 'Cache hit';

  @override
  String get cacheHits => 'Cache hits';

  @override
  String get campaigns => 'Campaigns';

  @override
  String get cancelCampaign => 'Cancel campaign';

  @override
  String get cancelCampaignMessage => 'Cancel this campaign?';

  @override
  String get cancelledAt => 'Cancelled at';

  @override
  String get capabilities => 'Capabilities';

  @override
  String get changelog => 'Changelog';

  @override
  String get channel => 'Channel';

  @override
  String get channelKey => 'Channel key';

  @override
  String get channels => 'Channels';

  @override
  String get configurationSchema => 'Configuration schema';

  @override
  String get connectionVerified => 'Connection verified';

  @override
  String get connections => 'Connections';

  @override
  String get correlationId => 'Correlation ID';

  @override
  String get countries => 'Countries';

  @override
  String get counts => 'Counts';

  @override
  String get credentialFields => 'Credential fields';

  @override
  String get credentialSource => 'Credential source';

  @override
  String get credentials => 'Credentials';

  @override
  String get currentVersion => 'Current version';

  @override
  String get dailyPerTenant => 'Daily per tenant';

  @override
  String get dailyPerUser => 'Daily per user';

  @override
  String get dataGaps => 'Data gaps';

  @override
  String get deliveredAt => 'Delivered at';

  @override
  String get deliveries => 'Deliveries';

  @override
  String get descriptionAr => 'Description (Arabic)';

  @override
  String get disableInstallation => 'Disable installation';

  @override
  String get disableInstallationMessage =>
      'Disable this installation? It will stop running.';

  @override
  String get disconnectAccountMessage => 'Disconnect this account?';

  @override
  String get dismissRecoveryMessage => 'Dismiss this recovery opportunity?';

  @override
  String get dismissTaskMessage => 'Dismiss this task?';

  @override
  String get doNotContactMessage => 'Mark this customer as do-not-contact?';

  @override
  String get docsUrl => 'Documentation URL';

  @override
  String get draftMessageMessage => 'Create a message draft?';

  @override
  String get driver => 'Driver';

  @override
  String get durationMs => 'Duration (ms)';

  @override
  String get effectiveCopy => 'Effective copy';

  @override
  String get emailTemplates => 'Email templates';

  @override
  String get enableInstallation => 'Enable installation';

  @override
  String get enabledAt => 'Enabled at';

  @override
  String get errorCategory => 'Error category';

  @override
  String get estimatedCost => 'Estimated cost';

  @override
  String get estimatesAndRecommendations => 'Estimates and recommendations';

  @override
  String get eventId => 'Event ID';

  @override
  String get eventKey => 'Event key';

  @override
  String get eventType => 'Event type';

  @override
  String get executeAiActionMessage => 'Execute this AI action now?';

  @override
  String get factsUsed => 'Facts used';

  @override
  String get failedAt => 'Failed at';

  @override
  String get failing => 'Failing';

  @override
  String get failureReason => 'Failure reason';

  @override
  String get failureType => 'Failure type';

  @override
  String get failures => 'Failures';

  @override
  String get fallbackAttempts => 'Fallback attempts';

  @override
  String get fallbackRequests => 'Fallback requests';

  @override
  String get feature => 'Feature';

  @override
  String get fromStore => 'From store';

  @override
  String get group => 'Group';

  @override
  String get headingAr => 'Heading (Arabic)';

  @override
  String get headingEn => 'Heading (English)';

  @override
  String get httpStatus => 'HTTP status';

  @override
  String get icon => 'Icon';

  @override
  String get inputTokens => 'Input tokens';

  @override
  String get installTemplate => 'Install template';

  @override
  String get installTemplateMessage =>
      'Install this template in your workspace?';

  @override
  String get installation => 'Installation';

  @override
  String get installations => 'Installations';

  @override
  String get installed => 'Installed';

  @override
  String get installedAt => 'Installed at';

  @override
  String get installedVersion => 'Installed version';

  @override
  String get installer => 'Installer';

  @override
  String get integrationEnabled => 'Integration enabled';

  @override
  String get integrationHealth => 'Integration health';

  @override
  String get introAr => 'Intro (Arabic)';

  @override
  String get introEn => 'Intro (English)';

  @override
  String get inventoryTransfer => 'Inventory transfer';

  @override
  String get inventoryTransferHint =>
      'Move a product variant between two stores in the same workspace. The server checks both stores and the stock.';

  @override
  String get isMarketing => 'Marketing message';

  @override
  String get key => 'Key';

  @override
  String get kind => 'Kind';

  @override
  String get lastSyncedAt => 'Last synced';

  @override
  String get lastVerified => 'Last verified';

  @override
  String get live => 'Live';

  @override
  String get makeDefaultMessage => 'Make this the default?';

  @override
  String get markCompletedMessage => 'Mark this as completed?';

  @override
  String get maxOutputTokens => 'Max output tokens';

  @override
  String get maxRetries => 'Max retries';

  @override
  String get merchantReference => 'Merchant reference';

  @override
  String get methodCode => 'Method code';

  @override
  String get metricExplanations => 'Metric explanations';

  @override
  String get missingData => 'Missing data';

  @override
  String get model => 'Model';

  @override
  String get models => 'Models';

  @override
  String get monthlyPerTenant => 'Monthly per tenant';

  @override
  String get monthlyPlatformRequests => 'Monthly platform requests';

  @override
  String get nameAr => 'Name (Arabic)';

  @override
  String get noAiPrompts => 'No prompts yet';

  @override
  String get noAiTasks => 'No AI tasks yet';

  @override
  String get noAnswerReturned => 'The copilot returned no answer.';

  @override
  String get noAutomationInstallations => 'No automation installations';

  @override
  String get noAutomationTemplates => 'No automation templates';

  @override
  String get noCampaigns => 'No campaigns';

  @override
  String get noConnections => 'No connections';

  @override
  String get noCountries => 'No countries';

  @override
  String get noCredentials => 'No credentials';

  @override
  String get noDeliveries => 'No deliveries';

  @override
  String get noEmailTemplates => 'No email templates';

  @override
  String get noIntegrations => 'No integrations';

  @override
  String get noPaymentConnections => 'No payment connections';

  @override
  String get noPaymentConnectionsMessage =>
      'Add a connection so the store can collect payments.';

  @override
  String get noPayments => 'No payments';

  @override
  String get noProviders => 'No providers';

  @override
  String get noVariantsToTransfer => 'No product variants to transfer';

  @override
  String get noWebhookEvents => 'No webhook events';

  @override
  String get nothingHereYet => 'Nothing here yet';

  @override
  String get notificationOperations => 'Notification operations';

  @override
  String get operations => 'Operations';

  @override
  String get outputTokens => 'Output tokens';

  @override
  String get paidAt => 'Paid at';

  @override
  String get payment => 'Payment';

  @override
  String get paymentCatalogue => 'Payment catalogue';

  @override
  String get paymentConnections => 'Payment connections';

  @override
  String get paymentHistory => 'Payment history';

  @override
  String get payments => 'Payments';

  @override
  String get period => 'Period';

  @override
  String get platformConfigured => 'Configured on the platform';

  @override
  String get processedAt => 'Processed at';

  @override
  String get productVariant => 'Product variant';

  @override
  String get promptKey => 'Prompt key';

  @override
  String get provider => 'Provider';

  @override
  String get providerCode => 'Provider code';

  @override
  String get providerCount => 'Provider count';

  @override
  String get providerCoverage => 'Provider coverage';

  @override
  String get providerKey => 'Provider key';

  @override
  String get providerMessageId => 'Provider message ID';

  @override
  String get providers => 'Providers';

  @override
  String get publicKey => 'Public key';

  @override
  String get publishCampaign => 'Publish campaign';

  @override
  String get publishCampaignMessage => 'Publish this campaign now?';

  @override
  String get publishTemplate => 'Publish template';

  @override
  String get publishTemplateMessage => 'Publish this template to stores?';

  @override
  String get questionTooLong =>
      'Your question is too long (1000 characters max).';

  @override
  String get queuedAt => 'Queued at';

  @override
  String get recheckComplete => 'Re-check complete';

  @override
  String get recheckIntegration => 'Re-check integration';

  @override
  String get recheckIntegrationMessage => 'Re-check this integration now?';

  @override
  String get recipient => 'Recipient';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get refundAmount => 'Refund amount';

  @override
  String get refundPayment => 'Refund payment';

  @override
  String get refundReason => 'Refund reason';

  @override
  String get refundSubmitted => 'Refund submitted';

  @override
  String get rejectAiActionMessage => 'Reject this AI action?';

  @override
  String get removed => 'Removed';

  @override
  String get requests => 'Requests';

  @override
  String get restoreTemplate => 'Restore template';

  @override
  String get restoreTemplateMessage => 'Restore this template\'s default copy?';

  @override
  String get retryDelivery => 'Retry delivery';

  @override
  String get retryDeliveryMessage => 'Retry delivering this message?';

  @override
  String get revokeConnectionMessage =>
      'Revoke this connection? The store will stop using it.';

  @override
  String get rotateCredential => 'Rotate credential';

  @override
  String get routes => 'Routes';

  @override
  String get rule => 'Rule';

  @override
  String get sandbox => 'Sandbox';

  @override
  String get scheduleCampaign => 'Schedule campaign';

  @override
  String get scheduledAt => 'Scheduled at';

  @override
  String get secretKey => 'Secret key';

  @override
  String get seedAiTasks => 'Seed AI tasks';

  @override
  String get seedAiTasksMessage => 'Create the missing default AI tasks?';

  @override
  String get selectPeriod => 'Select period';

  @override
  String get sendTestEmail => 'Send test email';

  @override
  String get sentAt => 'Sent at';

  @override
  String get signatureValid => 'Signature valid';

  @override
  String get stockTransferred => 'Stock transferred';

  @override
  String get subjectAr => 'Subject (Arabic)';

  @override
  String get subjectEn => 'Subject (English)';

  @override
  String get submitForApprovalMessage => 'Submit for approval?';

  @override
  String get suspendTenantMessage => 'Suspend this tenant?';

  @override
  String get syncPayment => 'Sync payment';

  @override
  String get taskKey => 'Task key';

  @override
  String get temperature => 'Temperature';

  @override
  String get template => 'Template';

  @override
  String get templateActionsHint =>
      'A JSON array of actions, for example the send_notification type.';

  @override
  String get templateCategoryHint =>
      'One of the template categories the server defines.';

  @override
  String get templateCustomized => 'Template customised';

  @override
  String get templateKey => 'Template key';

  @override
  String get templateKeyHint => 'A unique lowercase identifier with dashes.';

  @override
  String get templateTriggerHint =>
      'A trigger from the automation trigger list.';

  @override
  String get timeoutSeconds => 'Timeout (seconds)';

  @override
  String get toStore => 'To store';

  @override
  String get toggleCountry => 'Toggle country';

  @override
  String get toggleCountryMessage => 'Change whether this country is active?';

  @override
  String get toggleMethod => 'Toggle method';

  @override
  String get toggleMethodMessage =>
      'Change whether this payment method is active?';

  @override
  String get tokens => 'Tokens';

  @override
  String get transferNeedsTwoStores => 'Two stores are required';

  @override
  String get transferNeedsTwoStoresMessage =>
      'Create a second store before transferring stock between stores.';

  @override
  String get transferStock => 'Transfer stock';

  @override
  String get transferStockConfirm =>
      'Move this quantity between the two stores?';

  @override
  String get unprocessedEvents => 'Unprocessed events';

  @override
  String get unregisteredProviders => 'Unregistered providers';

  @override
  String get variables => 'Variables';

  @override
  String get verifyAccountMessage => 'Verify this account?';

  @override
  String get verifyConnection => 'Verify connection';

  @override
  String get versions => 'Versions';

  @override
  String get webhookDocsUrl => 'Webhook documentation URL';

  @override
  String get webhookEvents => 'Webhook events';

  @override
  String get webhookSecret => 'Webhook secret';

  @override
  String get yourQuestion => 'Your question';
}
