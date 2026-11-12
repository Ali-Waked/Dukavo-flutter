import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_generated_ar.dart';
import 'app_localizations_generated_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations_generated.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Dukavo'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Run your store from anywhere.'**
  String get appTagline;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get noData;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach the server. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In en, this message translates to:
  /// **'Showing what was saved on this device. Actions that need the server are paused.'**
  String get offlineBody;

  /// No description provided for @offlineSyncingTitle.
  ///
  /// In en, this message translates to:
  /// **'Back online'**
  String get offlineSyncingTitle;

  /// No description provided for @offlineSyncingBody.
  ///
  /// In en, this message translates to:
  /// **'Syncing {count} saved change(s)…'**
  String offlineSyncingBody(Object count);

  /// No description provided for @offlineRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing the latest data…'**
  String get offlineRefreshing;

  /// No description provided for @offlineBackOnline.
  ///
  /// In en, this message translates to:
  /// **'You\'re back online'**
  String get offlineBackOnline;

  /// No description provided for @offlineBackOnlineBody.
  ///
  /// In en, this message translates to:
  /// **'Saved changes are syncing and screens will refresh.'**
  String get offlineBackOnlineBody;

  /// No description provided for @offlineActionBlocked.
  ///
  /// In en, this message translates to:
  /// **'This action needs a connection.'**
  String get offlineActionBlocked;

  /// No description provided for @offlineNoSavedData.
  ///
  /// In en, this message translates to:
  /// **'No saved copy yet'**
  String get offlineNoSavedData;

  /// No description provided for @offlineNoSavedDataBody.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet once to keep this screen available offline.'**
  String get offlineNoSavedDataBody;

  /// No description provided for @offlineQueued.
  ///
  /// In en, this message translates to:
  /// **'Saved for later'**
  String get offlineQueued;

  /// No description provided for @offlinePendingChanges.
  ///
  /// In en, this message translates to:
  /// **'{count} change(s) waiting to sync'**
  String offlinePendingChanges(Object count);

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get passwordTooShort;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sku;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get conversations;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your store.'**
  String get loginSubtitle;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signingIn;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get passwordHint;

  /// No description provided for @tenantSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your workspace'**
  String get tenantSetupTitle;

  /// No description provided for @tenantSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what your business is called. You can invite your team afterwards.'**
  String get tenantSetupSubtitle;

  /// No description provided for @workspaceName.
  ///
  /// In en, this message translates to:
  /// **'Workspace name'**
  String get workspaceName;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeName;

  /// No description provided for @createWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create workspace'**
  String get createWorkspace;

  /// No description provided for @switchWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Switch workspace'**
  String get switchWorkspace;

  /// No description provided for @selectWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Select a workspace'**
  String get selectWorkspace;

  /// No description provided for @noWorkspace.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a workspace yet.'**
  String get noWorkspace;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get unauthorized;

  /// No description provided for @forbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do that.'**
  String get forbidden;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get notFound;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our end. Please try again.'**
  String get serverError;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Some of the details need attention.'**
  String get validationError;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'You have been signed out.'**
  String get signedOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirm;

  /// No description provided for @signOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again on this device.'**
  String get signOutMessage;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboardTitle;

  /// No description provided for @revenueToday.
  ///
  /// In en, this message translates to:
  /// **'Revenue today'**
  String get revenueToday;

  /// No description provided for @ordersToday.
  ///
  /// In en, this message translates to:
  /// **'Orders today'**
  String get ordersToday;

  /// No description provided for @averageOrderValue.
  ///
  /// In en, this message translates to:
  /// **'Average order'**
  String get averageOrderValue;

  /// No description provided for @revenueMonth.
  ///
  /// In en, this message translates to:
  /// **'Revenue this month'**
  String get revenueMonth;

  /// No description provided for @ordersMonth.
  ///
  /// In en, this message translates to:
  /// **'Orders this month'**
  String get ordersMonth;

  /// No description provided for @openConversations.
  ///
  /// In en, this message translates to:
  /// **'Open chats'**
  String get openConversations;

  /// No description provided for @lowStockItems.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStockItems;

  /// No description provided for @activeCustomers.
  ///
  /// In en, this message translates to:
  /// **'Active customers'**
  String get activeCustomers;

  /// No description provided for @awaitingFulfilment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting fulfilment'**
  String get awaitingFulfilment;

  /// No description provided for @revenueTrend.
  ///
  /// In en, this message translates to:
  /// **'Revenue trend'**
  String get revenueTrend;

  /// No description provided for @topProducts.
  ///
  /// In en, this message translates to:
  /// **'Top products'**
  String get topProducts;

  /// No description provided for @deadStock.
  ///
  /// In en, this message translates to:
  /// **'Dead stock'**
  String get deadStock;

  /// No description provided for @noTopProducts.
  ///
  /// In en, this message translates to:
  /// **'No sales in this period yet.'**
  String get noTopProducts;

  /// No description provided for @noDeadStock.
  ///
  /// In en, this message translates to:
  /// **'Nothing is sitting still. Nice.'**
  String get noDeadStock;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get units;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @adjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust stock'**
  String get adjustStock;

  /// No description provided for @receiveStock.
  ///
  /// In en, this message translates to:
  /// **'Receive stock'**
  String get receiveStock;

  /// No description provided for @movements.
  ///
  /// In en, this message translates to:
  /// **'Movements'**
  String get movements;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @newQuantity.
  ///
  /// In en, this message translates to:
  /// **'New quantity'**
  String get newQuantity;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @createProduct.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get createProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @productStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get productStatus;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @partiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially paid'**
  String get partiallyPaid;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get refunded;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get orderNumber;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentStatus;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get grandTotal;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get customerName;

  /// No description provided for @customerPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer phone'**
  String get customerPhone;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get changeStatus;

  /// No description provided for @allowedTransitions.
  ///
  /// In en, this message translates to:
  /// **'Available actions'**
  String get allowedTransitions;

  /// No description provided for @orderTimeline.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get orderTimeline;

  /// No description provided for @createOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get createOrder;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select customer'**
  String get selectCustomer;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select product'**
  String get selectProduct;

  /// No description provided for @variant.
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get variant;

  /// No description provided for @addToOrder.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addToOrder;

  /// No description provided for @orderCreated.
  ///
  /// In en, this message translates to:
  /// **'Order created.'**
  String get orderCreated;

  /// No description provided for @orderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Order updated.'**
  String get orderUpdated;

  /// No description provided for @statusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated.'**
  String get statusUpdated;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get createCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @parentCategory.
  ///
  /// In en, this message translates to:
  /// **'Parent category'**
  String get parentCategory;

  /// No description provided for @sortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort order'**
  String get sortOrder;

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsCount;

  /// No description provided for @createCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get createCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get editCustomer;

  /// No description provided for @customerStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get customerStatus;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpent;

  /// No description provided for @ordersCount.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersCount;

  /// No description provided for @lastOrder.
  ///
  /// In en, this message translates to:
  /// **'Last order'**
  String get lastOrder;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @conversationStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get conversationStatus;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @assignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get assignedTo;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendMessage;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reply…'**
  String get messageHint;

  /// No description provided for @sendNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get sendNote;

  /// No description provided for @internalNote.
  ///
  /// In en, this message translates to:
  /// **'Internal note'**
  String get internalNote;

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markRead;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get noMessages;

  /// No description provided for @replyWindowClosed.
  ///
  /// In en, this message translates to:
  /// **'The reply window is closed. Send a template to continue.'**
  String get replyWindowClosed;

  /// No description provided for @templateRequired.
  ///
  /// In en, this message translates to:
  /// **'Template required'**
  String get templateRequired;

  /// No description provided for @notificationCenter.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationCenter;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @markAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get markAsUnread;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get noNotifications;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your email and choose a new password.'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetToken.
  ///
  /// In en, this message translates to:
  /// **'Reset code'**
  String get resetToken;

  /// No description provided for @resetTokenMissing.
  ///
  /// In en, this message translates to:
  /// **'This reset link is incomplete. Request a new one.'**
  String get resetTokenMissing;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordResetSuccess;

  /// No description provided for @passwordResetSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'You can now sign in with your new password.'**
  String get passwordResetSuccessMessage;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToLogin;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Signed-in devices'**
  String get sessions;

  /// No description provided for @revoke.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get revoke;

  /// No description provided for @revokeOthers.
  ///
  /// In en, this message translates to:
  /// **'Sign out other devices'**
  String get revokeOthers;

  /// No description provided for @currentSession.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get currentSession;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notificationPreferences;

  /// No description provided for @workspaceSettings.
  ///
  /// In en, this message translates to:
  /// **'Workspace settings'**
  String get workspaceSettings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRange;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @until.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get until;

  /// No description provided for @kpi.
  ///
  /// In en, this message translates to:
  /// **'Key figures'**
  String get kpi;

  /// No description provided for @salesTrend.
  ///
  /// In en, this message translates to:
  /// **'Sales trend'**
  String get salesTrend;

  /// No description provided for @productPerformance.
  ///
  /// In en, this message translates to:
  /// **'Product performance'**
  String get productPerformance;

  /// No description provided for @stockHealth.
  ///
  /// In en, this message translates to:
  /// **'Stock health'**
  String get stockHealth;

  /// No description provided for @noAnalytics.
  ///
  /// In en, this message translates to:
  /// **'No analytics for this period.'**
  String get noAnalytics;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @endOfList.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the end.'**
  String get endOfList;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect.'**
  String get invalidCredentials;

  /// No description provided for @accountSuspended.
  ///
  /// In en, this message translates to:
  /// **'This account is suspended. Contact support.'**
  String get accountSuspended;

  /// No description provided for @tenantRequired.
  ///
  /// In en, this message translates to:
  /// **'Create a workspace to continue.'**
  String get tenantRequired;

  /// No description provided for @noPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to view this.'**
  String get noPermission;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get avatar;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get uploadPhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @chooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose an image'**
  String get chooseImage;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'The image could not be uploaded.'**
  String get imageUploadFailed;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Other devices were signed out.'**
  String get passwordChanged;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdated;

  /// No description provided for @settingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Settings updated.'**
  String get settingsUpdated;

  /// No description provided for @preferencesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Preferences updated.'**
  String get preferencesUpdated;

  /// No description provided for @sessionRevoked.
  ///
  /// In en, this message translates to:
  /// **'Device signed out.'**
  String get sessionRevoked;

  /// No description provided for @allSessionsRevoked.
  ///
  /// In en, this message translates to:
  /// **'Other devices signed out.'**
  String get allSessionsRevoked;

  /// No description provided for @allNotificationsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read.'**
  String get allNotificationsRead;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent.'**
  String get messageSent;

  /// No description provided for @noteSent.
  ///
  /// In en, this message translates to:
  /// **'Note added.'**
  String get noteSent;

  /// No description provided for @stockAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Stock adjusted.'**
  String get stockAdjusted;

  /// No description provided for @stockReceived.
  ///
  /// In en, this message translates to:
  /// **'Stock received.'**
  String get stockReceived;

  /// No description provided for @customerCreated.
  ///
  /// In en, this message translates to:
  /// **'Customer created.'**
  String get customerCreated;

  /// No description provided for @customerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Customer updated.'**
  String get customerUpdated;

  /// No description provided for @customerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted.'**
  String get customerDeleted;

  /// No description provided for @customerCrm.
  ///
  /// In en, this message translates to:
  /// **'Customer CRM'**
  String get customerCrm;

  /// No description provided for @conversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get conversation;

  /// No description provided for @paidOrders.
  ///
  /// In en, this message translates to:
  /// **'Paid orders'**
  String get paidOrders;

  /// No description provided for @lastInteraction.
  ///
  /// In en, this message translates to:
  /// **'Last interaction'**
  String get lastInteraction;

  /// No description provided for @aiSummary.
  ///
  /// In en, this message translates to:
  /// **'AI summary'**
  String get aiSummary;

  /// No description provided for @aiSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No summary yet. Refresh to generate one from this customer\'s activity.'**
  String get aiSummaryEmpty;

  /// No description provided for @editSummary.
  ///
  /// In en, this message translates to:
  /// **'Edit summary'**
  String get editSummary;

  /// No description provided for @refreshSummary.
  ///
  /// In en, this message translates to:
  /// **'Refresh summary'**
  String get refreshSummary;

  /// No description provided for @summaryHint.
  ///
  /// In en, this message translates to:
  /// **'Write a short summary of this customer.'**
  String get summaryHint;

  /// No description provided for @summaryRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Summary refreshed.'**
  String get summaryRefreshed;

  /// No description provided for @summaryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Summary updated.'**
  String get summaryUpdated;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get highlights;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @shortDescription.
  ///
  /// In en, this message translates to:
  /// **'Short description'**
  String get shortDescription;

  /// No description provided for @seoTitle.
  ///
  /// In en, this message translates to:
  /// **'SEO title'**
  String get seoTitle;

  /// No description provided for @seoDescription.
  ///
  /// In en, this message translates to:
  /// **'SEO description'**
  String get seoDescription;

  /// No description provided for @seoKeywords.
  ///
  /// In en, this message translates to:
  /// **'SEO keywords'**
  String get seoKeywords;

  /// No description provided for @linesHint.
  ///
  /// In en, this message translates to:
  /// **'One item per line.'**
  String get linesHint;

  /// No description provided for @specificationsHint.
  ///
  /// In en, this message translates to:
  /// **'One specification per line, as Label: value.'**
  String get specificationsHint;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'Separate tags with commas.'**
  String get tagsHint;

  /// No description provided for @risks.
  ///
  /// In en, this message translates to:
  /// **'Risks'**
  String get risks;

  /// No description provided for @opportunities.
  ///
  /// In en, this message translates to:
  /// **'Opportunities'**
  String get opportunities;

  /// No description provided for @memories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memories;

  /// No description provided for @addMemory.
  ///
  /// In en, this message translates to:
  /// **'Add memory'**
  String get addMemory;

  /// No description provided for @editMemory.
  ///
  /// In en, this message translates to:
  /// **'Edit memory'**
  String get editMemory;

  /// No description provided for @noMemories.
  ///
  /// In en, this message translates to:
  /// **'No saved memories yet.'**
  String get noMemories;

  /// No description provided for @memoryKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get memoryKey;

  /// No description provided for @memoryValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get memoryValue;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @confidenceRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 0 and 100.'**
  String get confidenceRange;

  /// No description provided for @deleteMemory.
  ///
  /// In en, this message translates to:
  /// **'Delete memory'**
  String get deleteMemory;

  /// No description provided for @deleteMemoryMessage.
  ///
  /// In en, this message translates to:
  /// **'This memory will be removed from the customer record.'**
  String get deleteMemoryMessage;

  /// No description provided for @memorySaved.
  ///
  /// In en, this message translates to:
  /// **'Memory saved.'**
  String get memorySaved;

  /// No description provided for @memoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Memory deleted.'**
  String get memoryDeleted;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet.'**
  String get noActivity;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @productCreated.
  ///
  /// In en, this message translates to:
  /// **'Product created.'**
  String get productCreated;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated.'**
  String get productUpdated;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted.'**
  String get productDeleted;

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created.'**
  String get categoryCreated;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated.'**
  String get categoryUpdated;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted.'**
  String get categoryDeleted;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteConfirmMessage;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get unsavedChanges;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @storeCurrency.
  ///
  /// In en, this message translates to:
  /// **'Store currency'**
  String get storeCurrency;

  /// No description provided for @storeCurrencyHelp.
  ///
  /// In en, this message translates to:
  /// **'Converting rewrites current product, variant, bundle and shipping prices. Historical orders keep their original currency.'**
  String get storeCurrencyHelp;

  /// No description provided for @currentCurrency.
  ///
  /// In en, this message translates to:
  /// **'Current currency'**
  String get currentCurrency;

  /// No description provided for @targetCurrency.
  ///
  /// In en, this message translates to:
  /// **'New currency'**
  String get targetCurrency;

  /// No description provided for @previewConversion.
  ///
  /// In en, this message translates to:
  /// **'Preview conversion'**
  String get previewConversion;

  /// No description provided for @conversionRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate'**
  String get conversionRate;

  /// No description provided for @rateSource.
  ///
  /// In en, this message translates to:
  /// **'Rate source'**
  String get rateSource;

  /// No description provided for @rateFetchedAt.
  ///
  /// In en, this message translates to:
  /// **'Rate fetched'**
  String get rateFetchedAt;

  /// No description provided for @variants.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get variants;

  /// No description provided for @samplePrices.
  ///
  /// In en, this message translates to:
  /// **'Sample prices'**
  String get samplePrices;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @convertCurrency.
  ///
  /// In en, this message translates to:
  /// **'Convert currency'**
  String get convertCurrency;

  /// No description provided for @convertCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Convert store currency?'**
  String get convertCurrencyTitle;

  /// No description provided for @convertCurrencyMessage.
  ///
  /// In en, this message translates to:
  /// **'Current catalogue prices will be rewritten using the displayed rate. Historical orders and payments are not changed.'**
  String get convertCurrencyMessage;

  /// No description provided for @currencyConverted.
  ///
  /// In en, this message translates to:
  /// **'Currency converted.'**
  String get currencyConverted;

  /// No description provided for @conversionHistory.
  ///
  /// In en, this message translates to:
  /// **'Conversion history'**
  String get conversionHistory;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select a currency'**
  String get selectCurrency;

  /// No description provided for @sameCurrency.
  ///
  /// In en, this message translates to:
  /// **'The store already uses this currency.'**
  String get sameCurrency;

  /// No description provided for @displayCurrency.
  ///
  /// In en, this message translates to:
  /// **'Display currency'**
  String get displayCurrency;

  /// No description provided for @displayCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'Your own display preference. It never changes workspace prices or past transactions.'**
  String get displayCurrencyHint;

  /// No description provided for @workspaceCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'This follows the default store\'s base currency. Change it from the store\'s currency settings.'**
  String get workspaceCurrencyHint;

  /// No description provided for @changeStoreCurrency.
  ///
  /// In en, this message translates to:
  /// **'Change store currency'**
  String get changeStoreCurrency;

  /// No description provided for @searchCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Search currencies by name or code'**
  String get searchCurrencies;

  /// No description provided for @noCurrenciesMatch.
  ///
  /// In en, this message translates to:
  /// **'No currencies match your search.'**
  String get noCurrenciesMatch;

  /// No description provided for @decimalPlaces.
  ///
  /// In en, this message translates to:
  /// **'{count} decimal places'**
  String decimalPlaces(Object count);

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @locale.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get locale;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact email'**
  String get contactEmail;

  /// No description provided for @slug.
  ///
  /// In en, this message translates to:
  /// **'Slug'**
  String get slug;

  /// No description provided for @readOnly.
  ///
  /// In en, this message translates to:
  /// **'Read only'**
  String get readOnly;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number.'**
  String get invalidNumber;

  /// No description provided for @mustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Enter zero or a positive number.'**
  String get mustBePositive;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete'**
  String get confirmDelete;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailNotifications;

  /// No description provided for @whatsappNotifications.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsappNotifications;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products match your filters.'**
  String get noProducts;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders match your filters.'**
  String get noOrders;

  /// No description provided for @noCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers match your filters.'**
  String get noCustomers;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet.'**
  String get noCategories;

  /// No description provided for @noInventory.
  ///
  /// In en, this message translates to:
  /// **'No stock records yet.'**
  String get noInventory;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations match your filters.'**
  String get noConversations;

  /// No description provided for @addFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Add your first product'**
  String get addFirstProduct;

  /// No description provided for @addFirstCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add your first customer'**
  String get addFirstCustomer;

  /// No description provided for @addFirstCategory.
  ///
  /// In en, this message translates to:
  /// **'Add your first category'**
  String get addFirstCategory;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetails;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer details'**
  String get customerDetails;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get productDetails;

  /// No description provided for @inventoryDetails.
  ///
  /// In en, this message translates to:
  /// **'Stock details'**
  String get inventoryDetails;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reserved;

  /// No description provided for @threshold.
  ///
  /// In en, this message translates to:
  /// **'Low-stock threshold'**
  String get threshold;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updatedAt;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @adjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get adjustment;

  /// No description provided for @returnIn.
  ///
  /// In en, this message translates to:
  /// **'Return in'**
  String get returnIn;

  /// No description provided for @returnOut.
  ///
  /// In en, this message translates to:
  /// **'Return out'**
  String get returnOut;

  /// No description provided for @transferIn.
  ///
  /// In en, this message translates to:
  /// **'Transfer in'**
  String get transferIn;

  /// No description provided for @transferOut.
  ///
  /// In en, this message translates to:
  /// **'Transfer out'**
  String get transferOut;

  /// No description provided for @initial.
  ///
  /// In en, this message translates to:
  /// **'Initial'**
  String get initial;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @balanceAfter.
  ///
  /// In en, this message translates to:
  /// **'Balance after'**
  String get balanceAfter;

  /// No description provided for @markAll.
  ///
  /// In en, this message translates to:
  /// **'Mark all'**
  String get markAll;

  /// No description provided for @unreadOnly.
  ///
  /// In en, this message translates to:
  /// **'Unread only'**
  String get unreadOnly;

  /// No description provided for @readOnlyFilter.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readOnlyFilter;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @categoryFilter.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryFilter;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications match this filter.'**
  String get notificationsEmpty;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @inAppNotifications.
  ///
  /// In en, this message translates to:
  /// **'In-app notifications'**
  String get inAppNotifications;

  /// No description provided for @teamActivity.
  ///
  /// In en, this message translates to:
  /// **'Team activity'**
  String get teamActivity;

  /// No description provided for @securityAlerts.
  ///
  /// In en, this message translates to:
  /// **'Security alerts'**
  String get securityAlerts;

  /// No description provided for @mandatorySecurityHint.
  ///
  /// In en, this message translates to:
  /// **'Always on to keep your account secure.'**
  String get mandatorySecurityHint;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @allSeverities.
  ///
  /// In en, this message translates to:
  /// **'All priorities'**
  String get allSeverities;

  /// No description provided for @notificationNotFound.
  ///
  /// In en, this message translates to:
  /// **'This notification could not be found.'**
  String get notificationNotFound;

  /// No description provided for @deleteNotificationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this notification? This cannot be undone.'**
  String get deleteNotificationConfirm;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted.'**
  String get notificationDeleted;

  /// No description provided for @notificationDetail.
  ///
  /// In en, this message translates to:
  /// **'Notification details'**
  String get notificationDetail;

  /// No description provided for @openRelated.
  ///
  /// In en, this message translates to:
  /// **'Open related'**
  String get openRelated;

  /// No description provided for @categoryOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get categoryOrders;

  /// No description provided for @categoryInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get categoryInventory;

  /// No description provided for @categoryMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get categoryMessages;

  /// No description provided for @categoryCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get categoryCustomers;

  /// No description provided for @categoryBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get categoryBilling;

  /// No description provided for @categoryAi.
  ///
  /// In en, this message translates to:
  /// **'AI insights'**
  String get categoryAi;

  /// No description provided for @categoryApprovals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get categoryApprovals;

  /// No description provided for @categorySecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get categorySecurity;

  /// No description provided for @categoryReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get categoryReports;

  /// No description provided for @categoryAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get categoryAnnouncements;

  /// No description provided for @categoryTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get categoryTeam;

  /// No description provided for @severityInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get severityInfo;

  /// No description provided for @severitySuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get severitySuccess;

  /// No description provided for @severityWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get severityWarning;

  /// No description provided for @severityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get severityCritical;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @internal.
  ///
  /// In en, this message translates to:
  /// **'Internal'**
  String get internal;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @retryMessage.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryMessage;

  /// No description provided for @deliveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Delivery failed'**
  String get deliveryFailed;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @deliveredStatus.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveredStatus;

  /// No description provided for @readStatus.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readStatus;

  /// No description provided for @pendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingStatus;

  /// No description provided for @failedStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failedStatus;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @assignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign to'**
  String get assignTo;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @allConversations.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allConversations;

  /// No description provided for @mine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mine;

  /// No description provided for @unassignedFilter.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassignedFilter;

  /// No description provided for @unreadFilter.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unreadFilter;

  /// No description provided for @sendTemplate.
  ///
  /// In en, this message translates to:
  /// **'Send template'**
  String get sendTemplate;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get templateName;

  /// No description provided for @languageCode.
  ///
  /// In en, this message translates to:
  /// **'Language code'**
  String get languageCode;

  /// No description provided for @parameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get parameters;

  /// No description provided for @requiredParameters.
  ///
  /// In en, this message translates to:
  /// **'One value per line.'**
  String get requiredParameters;

  /// No description provided for @photoPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Photo access was denied. Enable it in Settings.'**
  String get photoPermissionDenied;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access was denied. Enable it in Settings.'**
  String get cameraPermissionDenied;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @productImage.
  ///
  /// In en, this message translates to:
  /// **'Product image'**
  String get productImage;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'No images yet.'**
  String get noImages;

  /// No description provided for @defaultVariant.
  ///
  /// In en, this message translates to:
  /// **'Default variant'**
  String get defaultVariant;

  /// No description provided for @variantName.
  ///
  /// In en, this message translates to:
  /// **'Variant name'**
  String get variantName;

  /// No description provided for @addVariant.
  ///
  /// In en, this message translates to:
  /// **'Add variant'**
  String get addVariant;

  /// No description provided for @removeVariant.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeVariant;

  /// No description provided for @stockLevel.
  ///
  /// In en, this message translates to:
  /// **'Stock level'**
  String get stockLevel;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'A price is required.'**
  String get priceRequired;

  /// No description provided for @orderItemsRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one item.'**
  String get orderItemsRequired;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchProducts;

  /// No description provided for @searchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search customers'**
  String get searchCustomers;

  /// No description provided for @searchOrders.
  ///
  /// In en, this message translates to:
  /// **'Search orders'**
  String get searchOrders;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations'**
  String get searchConversations;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get noResults;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFilters;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCount(Object count);

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {last}'**
  String pageOf(Object last, Object page);

  /// No description provided for @showingRange.
  ///
  /// In en, this message translates to:
  /// **'Showing {from}–{to} of {total}'**
  String showingRange(Object from, Object to, Object total);

  /// No description provided for @optionalNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get optionalNote;

  /// No description provided for @confirmStatusChange.
  ///
  /// In en, this message translates to:
  /// **'Change status?'**
  String get confirmStatusChange;

  /// No description provided for @statusChangeMessage.
  ///
  /// In en, this message translates to:
  /// **'The order will move to {status}.'**
  String statusChangeMessage(Object status);

  /// No description provided for @orderTransitionNote.
  ///
  /// In en, this message translates to:
  /// **'Note for the history (optional)'**
  String get orderTransitionNote;

  /// No description provided for @paymentMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as paid'**
  String get paymentMarkPaid;

  /// No description provided for @selectVariant.
  ///
  /// In en, this message translates to:
  /// **'Select a variant'**
  String get selectVariant;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @quantityAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} available'**
  String quantityAvailable(Object count);

  /// No description provided for @insufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock for this item.'**
  String get insufficientStock;

  /// No description provided for @workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspace;

  /// No description provided for @switchAction.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchAction;

  /// No description provided for @notificationsChannelsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Some channels are not configured on the server.'**
  String get notificationsChannelsUnavailable;

  /// No description provided for @channelAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get channelAvailable;

  /// No description provided for @channelUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get channelUnavailable;

  /// No description provided for @savePreferences.
  ///
  /// In en, this message translates to:
  /// **'Save preferences'**
  String get savePreferences;

  /// No description provided for @noPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Access restricted'**
  String get noPermissionTitle;

  /// No description provided for @noPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Your role does not include access to this area.'**
  String get noPermissionMessage;

  /// No description provided for @goToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to dashboard'**
  String get goToDashboard;

  /// No description provided for @sessionRevokeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign this device out?'**
  String get sessionRevokeConfirm;

  /// No description provided for @sessionRevokeMessage.
  ///
  /// In en, this message translates to:
  /// **'That device will need to sign in again.'**
  String get sessionRevokeMessage;

  /// No description provided for @revokeOthersConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out other devices?'**
  String get revokeOthersConfirm;

  /// No description provided for @revokeOthersMessage.
  ///
  /// In en, this message translates to:
  /// **'Every other device will need to sign in again.'**
  String get revokeOthersMessage;

  /// No description provided for @avatarRemoved.
  ///
  /// In en, this message translates to:
  /// **'Profile photo removed.'**
  String get avatarRemoved;

  /// No description provided for @avatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get avatarUpdated;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'The current password is incorrect.'**
  String get currentPasswordIncorrect;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied.'**
  String get copied;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @ordersLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersLabel;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @previousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get previousPeriod;

  /// No description provided for @notMeasurable.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get notMeasurable;

  /// No description provided for @margin.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get margin;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @costCoverage.
  ///
  /// In en, this message translates to:
  /// **'Cost coverage'**
  String get costCoverage;

  /// No description provided for @stockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock value'**
  String get stockValue;

  /// No description provided for @conversationResponse.
  ///
  /// In en, this message translates to:
  /// **'First response'**
  String get conversationResponse;

  /// No description provided for @deliveryRate.
  ///
  /// In en, this message translates to:
  /// **'Delivery rate'**
  String get deliveryRate;

  /// No description provided for @repeatPurchase.
  ///
  /// In en, this message translates to:
  /// **'Repeat purchase'**
  String get repeatPurchase;

  /// No description provided for @noStore.
  ///
  /// In en, this message translates to:
  /// **'No store selected'**
  String get noStore;

  /// No description provided for @selectStore.
  ///
  /// In en, this message translates to:
  /// **'Select store'**
  String get selectStore;

  /// No description provided for @storeFilter.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeFilter;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this screen.'**
  String get errorLoading;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See less'**
  String get seeLess;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvals;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @channelFilter.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channelFilter;

  /// No description provided for @conversationAssignments.
  ///
  /// In en, this message translates to:
  /// **'Conversation assignments'**
  String get conversationAssignments;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @deliveryFailures.
  ///
  /// In en, this message translates to:
  /// **'Delivery failures'**
  String get deliveryFailures;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset it.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @isTaxableHint.
  ///
  /// In en, this message translates to:
  /// **'Tax is calculated by the server when the order is placed.'**
  String get isTaxableHint;

  /// Number of line items in an order.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @lastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last sign-in'**
  String get lastLogin;

  /// No description provided for @limitations.
  ///
  /// In en, this message translates to:
  /// **'Data limitations'**
  String get limitations;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @newMessages.
  ///
  /// In en, this message translates to:
  /// **'New messages'**
  String get newMessages;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Write an internal note…'**
  String get noteHint;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order items'**
  String get orderItems;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order updates'**
  String get orderUpdates;

  /// No description provided for @productNews.
  ///
  /// In en, this message translates to:
  /// **'Product news'**
  String get productNews;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get resetLinkSent;

  /// No description provided for @resetLinkSentMessage.
  ///
  /// In en, this message translates to:
  /// **'If that email is registered, a reset link is on its way.'**
  String get resetLinkSentMessage;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @web.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get web;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary'**
  String get weeklySummary;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @partially_paid.
  ///
  /// In en, this message translates to:
  /// **'Partially paid'**
  String get partially_paid;

  /// No description provided for @low_stock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get low_stock;

  /// No description provided for @out_of_stock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get out_of_stock;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspended;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @invited.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get invited;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @pending_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Pending confirmation'**
  String get pending_confirmation;

  /// No description provided for @storefrontGroup.
  ///
  /// In en, this message translates to:
  /// **'Storefront'**
  String get storefrontGroup;

  /// No description provided for @storefrontSettings.
  ///
  /// In en, this message translates to:
  /// **'Shop settings'**
  String get storefrontSettings;

  /// No description provided for @shippingZones.
  ///
  /// In en, this message translates to:
  /// **'Shipping zones'**
  String get shippingZones;

  /// No description provided for @paymentSettings.
  ///
  /// In en, this message translates to:
  /// **'Payment settings'**
  String get paymentSettings;

  /// No description provided for @noStores.
  ///
  /// In en, this message translates to:
  /// **'No stores yet'**
  String get noStores;

  /// No description provided for @noStoresMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a store before managing its shop settings.'**
  String get noStoresMessage;

  /// No description provided for @storefrontEnabled.
  ///
  /// In en, this message translates to:
  /// **'Shop published'**
  String get storefrontEnabled;

  /// No description provided for @storefrontEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'Customers can browse the shop and place orders.'**
  String get storefrontEnabledHint;

  /// No description provided for @storefrontDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'The shop is hidden from customers.'**
  String get storefrontDisabledHint;

  /// No description provided for @storefrontDisabledWarning.
  ///
  /// In en, this message translates to:
  /// **'While unpublished, the shop link returns not found.'**
  String get storefrontDisabledWarning;

  /// No description provided for @branding.
  ///
  /// In en, this message translates to:
  /// **'Branding'**
  String get branding;

  /// No description provided for @logoUrl.
  ///
  /// In en, this message translates to:
  /// **'Logo URL'**
  String get logoUrl;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Tagline'**
  String get tagline;

  /// No description provided for @heroImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Cover image URL'**
  String get heroImageUrl;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact details'**
  String get contactDetails;

  /// No description provided for @whatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get whatsappNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get openingHours;

  /// No description provided for @socialLinks.
  ///
  /// In en, this message translates to:
  /// **'Social links'**
  String get socialLinks;

  /// No description provided for @policies.
  ///
  /// In en, this message translates to:
  /// **'Policies'**
  String get policies;

  /// No description provided for @deliveryNote.
  ///
  /// In en, this message translates to:
  /// **'Delivery note'**
  String get deliveryNote;

  /// No description provided for @returnPolicy.
  ///
  /// In en, this message translates to:
  /// **'Return policy'**
  String get returnPolicy;

  /// No description provided for @showOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Show out-of-stock products'**
  String get showOutOfStock;

  /// No description provided for @showOutOfStockHint.
  ///
  /// In en, this message translates to:
  /// **'Display sold-out items with an out-of-stock label.'**
  String get showOutOfStockHint;

  /// No description provided for @searchEngine.
  ///
  /// In en, this message translates to:
  /// **'Search and sharing'**
  String get searchEngine;

  /// No description provided for @searchEngineHint.
  ///
  /// In en, this message translates to:
  /// **'Used by search results and link previews.'**
  String get searchEngineHint;

  /// No description provided for @metaTitle.
  ///
  /// In en, this message translates to:
  /// **'Page title'**
  String get metaTitle;

  /// No description provided for @metaDescription.
  ///
  /// In en, this message translates to:
  /// **'Page description'**
  String get metaDescription;

  /// No description provided for @storefrontUpdated.
  ///
  /// In en, this message translates to:
  /// **'Shop settings updated.'**
  String get storefrontUpdated;

  /// No description provided for @addShippingZone.
  ///
  /// In en, this message translates to:
  /// **'Add shipping zone'**
  String get addShippingZone;

  /// No description provided for @editShippingZone.
  ///
  /// In en, this message translates to:
  /// **'Edit shipping zone'**
  String get editShippingZone;

  /// No description provided for @noShippingZones.
  ///
  /// In en, this message translates to:
  /// **'No shipping zones yet'**
  String get noShippingZones;

  /// No description provided for @noShippingZonesMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a zone to set the delivery fee for an area.'**
  String get noShippingZonesMessage;

  /// No description provided for @shippingZonesIntro.
  ///
  /// In en, this message translates to:
  /// **'Fees match the city or area and are recalculated on the server at checkout.'**
  String get shippingZonesIntro;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFee;

  /// No description provided for @freeShippingOver.
  ///
  /// In en, this message translates to:
  /// **'Free delivery over'**
  String get freeShippingOver;

  /// No description provided for @isActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get isActive;

  /// No description provided for @zoneName.
  ///
  /// In en, this message translates to:
  /// **'Zone name'**
  String get zoneName;

  /// No description provided for @englishHint.
  ///
  /// In en, this message translates to:
  /// **'English is the canonical copy customers see when a translation is missing.'**
  String get englishHint;

  /// No description provided for @arabicHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Arabic readers see the English copy when a field is empty.'**
  String get arabicHint;

  /// No description provided for @missingArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic missing'**
  String get missingArabic;

  /// No description provided for @zoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Zone description'**
  String get zoneDescription;

  /// No description provided for @shippingMethodName.
  ///
  /// In en, this message translates to:
  /// **'Delivery method name'**
  String get shippingMethodName;

  /// No description provided for @shippingMethodNameHint.
  ///
  /// In en, this message translates to:
  /// **'The delivery option customers see at checkout.'**
  String get shippingMethodNameHint;

  /// No description provided for @shippingMethodDescription.
  ///
  /// In en, this message translates to:
  /// **'Delivery method description'**
  String get shippingMethodDescription;

  /// No description provided for @shippingMethodDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Optional detail shown under the delivery option.'**
  String get shippingMethodDescriptionHint;

  /// No description provided for @deliveryInstructions.
  ///
  /// In en, this message translates to:
  /// **'Delivery instructions'**
  String get deliveryInstructions;

  /// No description provided for @deliveryInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'What the customer should know before the courier arrives.'**
  String get deliveryInstructionsHint;

  /// No description provided for @shippingTerms.
  ///
  /// In en, this message translates to:
  /// **'Delivery terms'**
  String get shippingTerms;

  /// No description provided for @shippingTermsHint.
  ///
  /// In en, this message translates to:
  /// **'Optional customer-facing terms for this delivery option.'**
  String get shippingTermsHint;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to apply to every city.'**
  String get cityHint;

  /// No description provided for @areas.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get areas;

  /// No description provided for @areasHint.
  ///
  /// In en, this message translates to:
  /// **'Separate areas with commas.'**
  String get areasHint;

  /// No description provided for @freeShippingThreshold.
  ///
  /// In en, this message translates to:
  /// **'Free delivery threshold'**
  String get freeShippingThreshold;

  /// No description provided for @freeShippingThresholdHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to disable free delivery.'**
  String get freeShippingThresholdHint;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number.'**
  String get enterNumber;

  /// No description provided for @enterPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter zero or a positive number.'**
  String get enterPositiveNumber;

  /// No description provided for @enterWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number.'**
  String get enterWholeNumber;

  /// No description provided for @shippingZoneCreated.
  ///
  /// In en, this message translates to:
  /// **'Shipping zone created.'**
  String get shippingZoneCreated;

  /// No description provided for @shippingZoneUpdated.
  ///
  /// In en, this message translates to:
  /// **'Shipping zone updated.'**
  String get shippingZoneUpdated;

  /// No description provided for @deleteShippingZoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? This cannot be undone.'**
  String deleteShippingZoneMessage(Object name);

  /// No description provided for @shippingZoneDeleted.
  ///
  /// In en, this message translates to:
  /// **'Shipping zone deleted.'**
  String get shippingZoneDeleted;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethods;

  /// No description provided for @paymentsIntro.
  ///
  /// In en, this message translates to:
  /// **'Customers only see methods the store can genuinely honour.'**
  String get paymentsIntro;

  /// No description provided for @noPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'No payment methods are available.'**
  String get noPaymentMethods;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get cashOnDelivery;

  /// No description provided for @codEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable cash on delivery'**
  String get codEnabled;

  /// No description provided for @codEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'Orders stay unpaid until the courier collects the amount.'**
  String get codEnabledHint;

  /// No description provided for @codInstructions.
  ///
  /// In en, this message translates to:
  /// **'Payment instructions'**
  String get codInstructions;

  /// No description provided for @codInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Shown to the customer at checkout.'**
  String get codInstructionsHint;

  /// No description provided for @onlinePaymentsNote.
  ///
  /// In en, this message translates to:
  /// **'Online payment is unavailable until a payment provider is connected. No card is charged and no fake payment is recorded.'**
  String get onlinePaymentsNote;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @paymentSettingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Payment settings updated.'**
  String get paymentSettingsUpdated;

  /// No description provided for @aboutDukavo.
  ///
  /// In en, this message translates to:
  /// **'About Dukavo'**
  String get aboutDukavo;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUs;

  /// No description provided for @accessControl.
  ///
  /// In en, this message translates to:
  /// **'Access control'**
  String get accessControl;

  /// No description provided for @accessToken.
  ///
  /// In en, this message translates to:
  /// **'Access token'**
  String get accessToken;

  /// No description provided for @accessTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Token issued by the messaging provider.'**
  String get accessTokenHint;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @actionType.
  ///
  /// In en, this message translates to:
  /// **'Action type'**
  String get actionType;

  /// No description provided for @activateTenant.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateTenant;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @addressLineOne.
  ///
  /// In en, this message translates to:
  /// **'Address line 1'**
  String get addressLineOne;

  /// No description provided for @addressLineTwo.
  ///
  /// In en, this message translates to:
  /// **'Address line 2'**
  String get addressLineTwo;

  /// No description provided for @aiActions.
  ///
  /// In en, this message translates to:
  /// **'AI actions'**
  String get aiActions;

  /// No description provided for @aiSettings.
  ///
  /// In en, this message translates to:
  /// **'AI settings'**
  String get aiSettings;

  /// No description provided for @aiSettingsByokLabel.
  ///
  /// In en, this message translates to:
  /// **'Route through my own keys'**
  String get aiSettingsByokLabel;

  /// No description provided for @aiSettingsByokOff.
  ///
  /// In en, this message translates to:
  /// **'The platform has not enabled bring-your-own-key, so this workspace cannot store its own provider keys.'**
  String get aiSettingsByokOff;

  /// No description provided for @aiSettingsByokOptedIn.
  ///
  /// In en, this message translates to:
  /// **'This workspace now prefers its own keys.'**
  String get aiSettingsByokOptedIn;

  /// No description provided for @aiSettingsByokOptedOut.
  ///
  /// In en, this message translates to:
  /// **'This workspace is back on platform keys.'**
  String get aiSettingsByokOptedOut;

  /// No description provided for @aiSettingsByokSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When on, tasks in this workspace prefer your own provider credentials over the platform\'s, with the platform\'s providers as fallback.'**
  String get aiSettingsByokSubtitle;

  /// No description provided for @aiSettingsByokTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring your own key'**
  String get aiSettingsByokTitle;

  /// No description provided for @aiSettingsFeatureDisabled.
  ///
  /// In en, this message translates to:
  /// **'Feature disabled for this workspace.'**
  String get aiSettingsFeatureDisabled;

  /// No description provided for @aiSettingsFeatureEnabled.
  ///
  /// In en, this message translates to:
  /// **'Feature enabled for this workspace.'**
  String get aiSettingsFeatureEnabled;

  /// No description provided for @aiSettingsFeaturePlatformOff.
  ///
  /// In en, this message translates to:
  /// **'The platform has this feature off, so it cannot be enabled here.'**
  String get aiSettingsFeaturePlatformOff;

  /// No description provided for @aiSettingsFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn a feature off for this workspace only; other workspaces are unaffected.'**
  String get aiSettingsFeaturesSubtitle;

  /// No description provided for @aiSettingsFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get aiSettingsFeaturesTitle;

  /// No description provided for @aiSettingsKeyApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the key once; it is never shown again.'**
  String get aiSettingsKeyApiKeyHint;

  /// No description provided for @aiSettingsKeyApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get aiSettingsKeyApiKeyLabel;

  /// No description provided for @aiSettingsKeyBaseUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Must be a public provider endpoint — local or private addresses are refused.'**
  String get aiSettingsKeyBaseUrlHint;

  /// No description provided for @aiSettingsKeyBaseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get aiSettingsKeyBaseUrlLabel;

  /// No description provided for @aiSettingsKeyFormHint.
  ///
  /// In en, this message translates to:
  /// **'Storing again for the same provider replaces that provider\'s key.'**
  String get aiSettingsKeyFormHint;

  /// No description provided for @aiSettingsKeyFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Store or rotate a key'**
  String get aiSettingsKeyFormTitle;

  /// No description provided for @aiSettingsKeyModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Default model'**
  String get aiSettingsKeyModelLabel;

  /// No description provided for @aiSettingsKeyProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get aiSettingsKeyProviderLabel;

  /// No description provided for @aiSettingsKeyRevokeBody.
  ///
  /// In en, this message translates to:
  /// **'Revoke {masked} on {provider}? Routing falls back to the platform\'s providers.'**
  String aiSettingsKeyRevokeBody(Object masked, Object provider);

  /// No description provided for @aiSettingsKeyRevokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke this key'**
  String get aiSettingsKeyRevokeTitle;

  /// No description provided for @aiSettingsKeyRevoked.
  ///
  /// In en, this message translates to:
  /// **'Key revoked.'**
  String get aiSettingsKeyRevoked;

  /// No description provided for @aiSettingsKeyStored.
  ///
  /// In en, this message translates to:
  /// **'Key stored.'**
  String get aiSettingsKeyStored;

  /// No description provided for @aiSettingsKeyTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get aiSettingsKeyTest;

  /// No description provided for @aiSettingsKeyTestFailed.
  ///
  /// In en, this message translates to:
  /// **'The connection check failed.'**
  String get aiSettingsKeyTestFailed;

  /// No description provided for @aiSettingsKeyTestOk.
  ///
  /// In en, this message translates to:
  /// **'Your key answered in {latency} ms.'**
  String aiSettingsKeyTestOk(Object latency);

  /// No description provided for @aiSettingsKeyTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get aiSettingsKeyTooShort;

  /// No description provided for @aiSettingsKeysEmpty.
  ///
  /// In en, this message translates to:
  /// **'No keys stored.'**
  String get aiSettingsKeysEmpty;

  /// No description provided for @aiSettingsKeysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your key is encrypted at rest and shown only as its last characters.'**
  String get aiSettingsKeysSubtitle;

  /// No description provided for @aiSettingsKeysTitle.
  ///
  /// In en, this message translates to:
  /// **'My keys'**
  String get aiSettingsKeysTitle;

  /// No description provided for @aiSettingsNoProviders.
  ///
  /// In en, this message translates to:
  /// **'No providers are available for a workspace key.'**
  String get aiSettingsNoProviders;

  /// No description provided for @aiSettingsPlatformOffBody.
  ///
  /// In en, this message translates to:
  /// **'AI is turned off for the whole platform. Nothing here will run until the Dukavo team enables it.'**
  String get aiSettingsPlatformOffBody;

  /// No description provided for @aiSettingsPlatformOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Off platform-wide'**
  String get aiSettingsPlatformOffTitle;

  /// No description provided for @aiSettingsUsageCost.
  ///
  /// In en, this message translates to:
  /// **'Estimated cost'**
  String get aiSettingsUsageCost;

  /// No description provided for @aiSettingsUsageEstimatesNote.
  ///
  /// In en, this message translates to:
  /// **'Costs are estimates from declared model prices — operational signal, never a billing figure.'**
  String get aiSettingsUsageEstimatesNote;

  /// No description provided for @aiSettingsUsageFailures.
  ///
  /// In en, this message translates to:
  /// **'Failed requests'**
  String get aiSettingsUsageFailures;

  /// No description provided for @aiSettingsUsageRow.
  ///
  /// In en, this message translates to:
  /// **'{requests} requests · {tokens} tokens'**
  String aiSettingsUsageRow(Object requests, Object tokens);

  /// No description provided for @aiSettingsUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'AI usage'**
  String get aiSettingsUsageTitle;

  /// No description provided for @aiSettingsUsageTodayRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests today'**
  String get aiSettingsUsageTodayRequests;

  /// No description provided for @aiSettingsUsageTodayTokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens today'**
  String get aiSettingsUsageTodayTokens;

  /// No description provided for @altText.
  ///
  /// In en, this message translates to:
  /// **'Alt text'**
  String get altText;

  /// No description provided for @altTextHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the image for screen readers.'**
  String get altTextHint;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @answerAr.
  ///
  /// In en, this message translates to:
  /// **'Answer (Arabic)'**
  String get answerAr;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @areaHint.
  ///
  /// In en, this message translates to:
  /// **'Delivery area within the city.'**
  String get areaHint;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get auditLog;

  /// No description provided for @auditLogHint.
  ///
  /// In en, this message translates to:
  /// **'Every sensitive change, with who made it and when.'**
  String get auditLogHint;

  /// No description provided for @automationActionsHint.
  ///
  /// In en, this message translates to:
  /// **'What the rule does when its conditions match.'**
  String get automationActionsHint;

  /// No description provided for @automationHub.
  ///
  /// In en, this message translates to:
  /// **'Automations'**
  String get automationHub;

  /// No description provided for @automationHubHint.
  ///
  /// In en, this message translates to:
  /// **'Rules that react to store events.'**
  String get automationHubHint;

  /// No description provided for @automationRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get automationRules;

  /// No description provided for @automationRulesHint.
  ///
  /// In en, this message translates to:
  /// **'Trigger, conditions and actions.'**
  String get automationRulesHint;

  /// No description provided for @automationRuns.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get automationRuns;

  /// No description provided for @automationRunsHint.
  ///
  /// In en, this message translates to:
  /// **'Each time a rule was evaluated.'**
  String get automationRunsHint;

  /// No description provided for @automationTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get automationTasks;

  /// No description provided for @automationTasksHint.
  ///
  /// In en, this message translates to:
  /// **'Deferred work created by automations.'**
  String get automationTasksHint;

  /// No description provided for @automations.
  ///
  /// In en, this message translates to:
  /// **'Automations'**
  String get automations;

  /// No description provided for @billingInterval.
  ///
  /// In en, this message translates to:
  /// **'Billing interval'**
  String get billingInterval;

  /// No description provided for @bodyHtml.
  ///
  /// In en, this message translates to:
  /// **'Body (HTML)'**
  String get bodyHtml;

  /// No description provided for @bodyHtmlAr.
  ///
  /// In en, this message translates to:
  /// **'Body (Arabic HTML)'**
  String get bodyHtmlAr;

  /// No description provided for @bodyHtmlHint.
  ///
  /// In en, this message translates to:
  /// **'Full article body in HTML.'**
  String get bodyHtmlHint;

  /// No description provided for @browseShop.
  ///
  /// In en, this message translates to:
  /// **'Browse a shop'**
  String get browseShop;

  /// No description provided for @bundleItems.
  ///
  /// In en, this message translates to:
  /// **'Bundle items'**
  String get bundleItems;

  /// No description provided for @bundleItemsHint.
  ///
  /// In en, this message translates to:
  /// **'JSON list of product variant ids and quantities.'**
  String get bundleItemsHint;

  /// No description provided for @bundles.
  ///
  /// In en, this message translates to:
  /// **'Bundles'**
  String get bundles;

  /// No description provided for @businessAccountId.
  ///
  /// In en, this message translates to:
  /// **'Business account ID'**
  String get businessAccountId;

  /// No description provided for @businessType.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get businessType;

  /// No description provided for @calculatedByStore.
  ///
  /// In en, this message translates to:
  /// **'Calculated by the store'**
  String get calculatedByStore;

  /// No description provided for @cancelledOrders.
  ///
  /// In en, this message translates to:
  /// **'Cancelled orders'**
  String get cancelledOrders;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add a product to start an order.'**
  String get cartEmptyHint;

  /// No description provided for @catalogue.
  ///
  /// In en, this message translates to:
  /// **'Catalogue'**
  String get catalogue;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @chooseDeliveryCity.
  ///
  /// In en, this message translates to:
  /// **'Choose a delivery city.'**
  String get chooseDeliveryCity;

  /// No description provided for @chooseVariant.
  ///
  /// In en, this message translates to:
  /// **'Choose a variant'**
  String get chooseVariant;

  /// No description provided for @classification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get classification;

  /// No description provided for @cogs.
  ///
  /// In en, this message translates to:
  /// **'Cost of goods'**
  String get cogs;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @completedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed at'**
  String get completedAt;

  /// No description provided for @conditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get conditions;

  /// No description provided for @conditionsHint.
  ///
  /// In en, this message translates to:
  /// **'JSON conditions that must all match.'**
  String get conditionsHint;

  /// No description provided for @connectedAt.
  ///
  /// In en, this message translates to:
  /// **'Connected at'**
  String get connectedAt;

  /// No description provided for @contactAttempts.
  ///
  /// In en, this message translates to:
  /// **'Contact attempts'**
  String get contactAttempts;

  /// No description provided for @contactMessages.
  ///
  /// In en, this message translates to:
  /// **'Contact messages'**
  String get contactMessages;

  /// No description provided for @contactMessagesHint.
  ///
  /// In en, this message translates to:
  /// **'Messages sent through the public contact form.'**
  String get contactMessagesHint;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @contactUsHint.
  ///
  /// In en, this message translates to:
  /// **'Send us a message and we will reply by email.'**
  String get contactUsHint;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @contentPages.
  ///
  /// In en, this message translates to:
  /// **'Content pages'**
  String get contentPages;

  /// No description provided for @contentPagesHint.
  ///
  /// In en, this message translates to:
  /// **'Editable legal and informational pages.'**
  String get contentPagesHint;

  /// No description provided for @context.
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get context;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue shopping'**
  String get continueShopping;

  /// No description provided for @cooldownSeconds.
  ///
  /// In en, this message translates to:
  /// **'Cooldown (seconds)'**
  String get cooldownSeconds;

  /// No description provided for @costIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Cost data is incomplete'**
  String get costIncomplete;

  /// No description provided for @countryCode.
  ///
  /// In en, this message translates to:
  /// **'Country code'**
  String get countryCode;

  /// No description provided for @countryCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Two-letter ISO code, e.g. SA.'**
  String get countryCodeHint;

  /// No description provided for @createAutomation.
  ///
  /// In en, this message translates to:
  /// **'New automation'**
  String get createAutomation;

  /// No description provided for @createTeamMember.
  ///
  /// In en, this message translates to:
  /// **'Invite team member'**
  String get createTeamMember;

  /// No description provided for @currencyCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Three-letter ISO code, e.g. SAR.'**
  String get currencyCodeHint;

  /// No description provided for @dailyDemand.
  ///
  /// In en, this message translates to:
  /// **'Daily demand'**
  String get dailyDemand;

  /// No description provided for @daysOfCover.
  ///
  /// In en, this message translates to:
  /// **'Days of cover'**
  String get daysOfCover;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @defaultStore.
  ///
  /// In en, this message translates to:
  /// **'Default store'**
  String get defaultStore;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete image'**
  String get deleteImage;

  /// No description provided for @deleteImageMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this image? This cannot be undone.'**
  String get deleteImageMessage;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddress;

  /// No description provided for @detectedAt.
  ///
  /// In en, this message translates to:
  /// **'Detected at'**
  String get detectedAt;

  /// No description provided for @disconnectAccount.
  ///
  /// In en, this message translates to:
  /// **'Disconnect account'**
  String get disconnectAccount;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @discountType.
  ///
  /// In en, this message translates to:
  /// **'Discount type'**
  String get discountType;

  /// No description provided for @discountValue.
  ///
  /// In en, this message translates to:
  /// **'Discount value'**
  String get discountValue;

  /// No description provided for @discounts.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get discounts;

  /// No description provided for @dismissalReason.
  ///
  /// In en, this message translates to:
  /// **'Dismissal reason'**
  String get dismissalReason;

  /// No description provided for @dismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get dismissed;

  /// No description provided for @disqualified.
  ///
  /// In en, this message translates to:
  /// **'Disqualified'**
  String get disqualified;

  /// No description provided for @doNotContact.
  ///
  /// In en, this message translates to:
  /// **'Do not contact'**
  String get doNotContact;

  /// No description provided for @draftMessage.
  ///
  /// In en, this message translates to:
  /// **'Draft message'**
  String get draftMessage;

  /// No description provided for @dueAt.
  ///
  /// In en, this message translates to:
  /// **'Due at'**
  String get dueAt;

  /// No description provided for @editAltText.
  ///
  /// In en, this message translates to:
  /// **'Edit alt text'**
  String get editAltText;

  /// No description provided for @editTeamMember.
  ///
  /// In en, this message translates to:
  /// **'Edit team member'**
  String get editTeamMember;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error message'**
  String get errorMessage;

  /// No description provided for @estimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get estimatedTotal;

  /// No description provided for @estimatedValue.
  ///
  /// In en, this message translates to:
  /// **'Estimated value'**
  String get estimatedValue;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @excerpt.
  ///
  /// In en, this message translates to:
  /// **'Excerpt'**
  String get excerpt;

  /// No description provided for @excerptAr.
  ///
  /// In en, this message translates to:
  /// **'Excerpt (Arabic)'**
  String get excerptAr;

  /// No description provided for @execute.
  ///
  /// In en, this message translates to:
  /// **'Execute'**
  String get execute;

  /// No description provided for @executed.
  ///
  /// In en, this message translates to:
  /// **'Executed'**
  String get executed;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String exportSaved(Object path);

  /// No description provided for @faqEntries.
  ///
  /// In en, this message translates to:
  /// **'FAQ entries'**
  String get faqEntries;

  /// No description provided for @faqEntriesHint.
  ///
  /// In en, this message translates to:
  /// **'Questions shown on the public FAQ page.'**
  String get faqEntriesHint;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @finalTotalOnConfirmation.
  ///
  /// In en, this message translates to:
  /// **'The store confirms the final total after checking stock and delivery.'**
  String get finalTotalOnConfirmation;

  /// No description provided for @finishedAt.
  ///
  /// In en, this message translates to:
  /// **'Finished at'**
  String get finishedAt;

  /// No description provided for @firstStoreName.
  ///
  /// In en, this message translates to:
  /// **'First store name'**
  String get firstStoreName;

  /// No description provided for @firstStoreNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your workspace starts with one store. You can add more later.'**
  String get firstStoreNameHint;

  /// No description provided for @fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixed;

  /// No description provided for @followUpSent.
  ///
  /// In en, this message translates to:
  /// **'Follow-up sent'**
  String get followUpSent;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @grossProfit.
  ///
  /// In en, this message translates to:
  /// **'Gross profit'**
  String get grossProfit;

  /// No description provided for @growthSeries.
  ///
  /// In en, this message translates to:
  /// **'Growth series'**
  String get growthSeries;

  /// No description provided for @growthSeriesHint.
  ///
  /// In en, this message translates to:
  /// **'Daily recovered value over the selected period.'**
  String get growthSeriesHint;

  /// No description provided for @highlighted.
  ///
  /// In en, this message translates to:
  /// **'Highlighted'**
  String get highlighted;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This image is too large.'**
  String get imageTooLarge;

  /// No description provided for @imagesUploaded.
  ///
  /// In en, this message translates to:
  /// **'Images uploaded.'**
  String get imagesUploaded;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @insufficientHistory.
  ///
  /// In en, this message translates to:
  /// **'Not enough history to forecast yet.'**
  String get insufficientHistory;

  /// No description provided for @intro.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get intro;

  /// No description provided for @invalidJson.
  ///
  /// In en, this message translates to:
  /// **'Enter valid JSON.'**
  String get invalidJson;

  /// No description provided for @inventoryIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Inventory intelligence'**
  String get inventoryIntelligence;

  /// No description provided for @inviteTeamMember.
  ///
  /// In en, this message translates to:
  /// **'Invite member'**
  String get inviteTeamMember;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP address'**
  String get ipAddress;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'Item count'**
  String get itemCount;

  /// No description provided for @joinWaitlist.
  ///
  /// In en, this message translates to:
  /// **'Join the waitlist'**
  String get joinWaitlist;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @lastContactedAt.
  ///
  /// In en, this message translates to:
  /// **'Last contacted'**
  String get lastContactedAt;

  /// No description provided for @lastTriggered.
  ///
  /// In en, this message translates to:
  /// **'Last triggered'**
  String get lastTriggered;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {date}'**
  String lastUpdated(Object date);

  /// No description provided for @leadsAndAudience.
  ///
  /// In en, this message translates to:
  /// **'Leads and audience'**
  String get leadsAndAudience;

  /// No description provided for @limitationsHint.
  ///
  /// In en, this message translates to:
  /// **'What this report cannot measure yet.'**
  String get limitationsHint;

  /// No description provided for @limits.
  ///
  /// In en, this message translates to:
  /// **'Limits'**
  String get limits;

  /// No description provided for @localeHint.
  ///
  /// In en, this message translates to:
  /// **'Language code, e.g. en or ar.'**
  String get localeHint;

  /// No description provided for @makeDefault.
  ///
  /// In en, this message translates to:
  /// **'Make default'**
  String get makeDefault;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark completed'**
  String get markCompleted;

  /// No description provided for @marketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get marketing;

  /// No description provided for @marketingHub.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get marketingHub;

  /// No description provided for @marketingHubHint.
  ///
  /// In en, this message translates to:
  /// **'Public content, plans, FAQs and audience.'**
  String get marketingHubHint;

  /// No description provided for @matched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get matched;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @merchantWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Merchant workspace'**
  String get merchantWorkspace;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @messageSentHint.
  ///
  /// In en, this message translates to:
  /// **'We reply to the email you provide.'**
  String get messageSentHint;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// No description provided for @netSales.
  ///
  /// In en, this message translates to:
  /// **'Net sales'**
  String get netSales;

  /// No description provided for @newInPeriod.
  ///
  /// In en, this message translates to:
  /// **'New in period'**
  String get newInPeriod;

  /// No description provided for @newStatus.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newStatus;

  /// No description provided for @newValues.
  ///
  /// In en, this message translates to:
  /// **'New values'**
  String get newValues;

  /// No description provided for @newsletter.
  ///
  /// In en, this message translates to:
  /// **'Newsletter'**
  String get newsletter;

  /// No description provided for @newsletters.
  ///
  /// In en, this message translates to:
  /// **'Newsletters'**
  String get newsletters;

  /// No description provided for @newslettersHint.
  ///
  /// In en, this message translates to:
  /// **'Articles published to the public newsletter.'**
  String get newslettersHint;

  /// No description provided for @nextFollowUpAt.
  ///
  /// In en, this message translates to:
  /// **'Next follow-up'**
  String get nextFollowUpAt;

  /// No description provided for @noAiActions.
  ///
  /// In en, this message translates to:
  /// **'No AI actions yet'**
  String get noAiActions;

  /// No description provided for @noAltText.
  ///
  /// In en, this message translates to:
  /// **'No alt text'**
  String get noAltText;

  /// No description provided for @noAuditEntries.
  ///
  /// In en, this message translates to:
  /// **'No audit entries'**
  String get noAuditEntries;

  /// No description provided for @noAutomationRules.
  ///
  /// In en, this message translates to:
  /// **'No automation rules'**
  String get noAutomationRules;

  /// No description provided for @noAutomationRuns.
  ///
  /// In en, this message translates to:
  /// **'No runs yet'**
  String get noAutomationRuns;

  /// No description provided for @noAutomationTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noAutomationTasks;

  /// No description provided for @noBundles.
  ///
  /// In en, this message translates to:
  /// **'No bundles yet'**
  String get noBundles;

  /// No description provided for @noContactMessages.
  ///
  /// In en, this message translates to:
  /// **'No contact messages'**
  String get noContactMessages;

  /// No description provided for @noContentPages.
  ///
  /// In en, this message translates to:
  /// **'No content pages'**
  String get noContentPages;

  /// No description provided for @noFaqEntries.
  ///
  /// In en, this message translates to:
  /// **'No FAQ entries'**
  String get noFaqEntries;

  /// No description provided for @noFeatures.
  ///
  /// In en, this message translates to:
  /// **'No features listed'**
  String get noFeatures;

  /// No description provided for @noMembers.
  ///
  /// In en, this message translates to:
  /// **'No members'**
  String get noMembers;

  /// No description provided for @noNewsletters.
  ///
  /// In en, this message translates to:
  /// **'No newsletters'**
  String get noNewsletters;

  /// No description provided for @noPlatformUsers.
  ///
  /// In en, this message translates to:
  /// **'No platform users'**
  String get noPlatformUsers;

  /// No description provided for @noPreviousData.
  ///
  /// In en, this message translates to:
  /// **'No previous data'**
  String get noPreviousData;

  /// No description provided for @noPricingPlans.
  ///
  /// In en, this message translates to:
  /// **'No pricing plans'**
  String get noPricingPlans;

  /// No description provided for @noRecoveryOpportunities.
  ///
  /// In en, this message translates to:
  /// **'No recovery opportunities'**
  String get noRecoveryOpportunities;

  /// No description provided for @noRoles.
  ///
  /// In en, this message translates to:
  /// **'No roles'**
  String get noRoles;

  /// No description provided for @noSubscribers.
  ///
  /// In en, this message translates to:
  /// **'No subscribers'**
  String get noSubscribers;

  /// No description provided for @noTeamMembers.
  ///
  /// In en, this message translates to:
  /// **'No team members'**
  String get noTeamMembers;

  /// No description provided for @noTenants.
  ///
  /// In en, this message translates to:
  /// **'No tenants'**
  String get noTenants;

  /// No description provided for @noWaitlistEntries.
  ///
  /// In en, this message translates to:
  /// **'No waitlist entries'**
  String get noWaitlistEntries;

  /// No description provided for @noWhatsappAccounts.
  ///
  /// In en, this message translates to:
  /// **'No WhatsApp accounts'**
  String get noWhatsappAccounts;

  /// No description provided for @oldValues.
  ///
  /// In en, this message translates to:
  /// **'Old values'**
  String get oldValues;

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'One time'**
  String get oneTime;

  /// No description provided for @onlyLeft.
  ///
  /// In en, this message translates to:
  /// **'Only {count} left'**
  String onlyLeft(Object count);

  /// No description provided for @openValue.
  ///
  /// In en, this message translates to:
  /// **'Open value'**
  String get openValue;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed'**
  String get orderConfirmed;

  /// No description provided for @orderNotes.
  ///
  /// In en, this message translates to:
  /// **'Order notes'**
  String get orderNotes;

  /// No description provided for @orderPlacedNoTracking.
  ///
  /// In en, this message translates to:
  /// **'Order placed, but no tracking link was returned.'**
  String get orderPlacedNoTracking;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @orderTracking.
  ///
  /// In en, this message translates to:
  /// **'Order tracking'**
  String get orderTracking;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @pageKey.
  ///
  /// In en, this message translates to:
  /// **'Page key'**
  String get pageKey;

  /// No description provided for @passwordMinHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters.'**
  String get passwordMinHint;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @payload.
  ///
  /// In en, this message translates to:
  /// **'Payload'**
  String get payload;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get pendingApproval;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @permissionsHint.
  ///
  /// In en, this message translates to:
  /// **'Choose what this role can do.'**
  String get permissionsHint;

  /// No description provided for @phoneNumberId.
  ///
  /// In en, this message translates to:
  /// **'Phone number ID'**
  String get phoneNumberId;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @platformConsole.
  ///
  /// In en, this message translates to:
  /// **'Platform console'**
  String get platformConsole;

  /// No description provided for @platformOverview.
  ///
  /// In en, this message translates to:
  /// **'Platform overview'**
  String get platformOverview;

  /// No description provided for @platformPasswordSelfService.
  ///
  /// In en, this message translates to:
  /// **'Platform accounts change their password from their profile.'**
  String get platformPasswordSelfService;

  /// No description provided for @platformRoles.
  ///
  /// In en, this message translates to:
  /// **'Platform roles'**
  String get platformRoles;

  /// No description provided for @platformScope.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platformScope;

  /// No description provided for @platformUsers.
  ///
  /// In en, this message translates to:
  /// **'Platform users'**
  String get platformUsers;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get postalCode;

  /// No description provided for @priceComingSoonHint.
  ///
  /// In en, this message translates to:
  /// **'Pricing is not enforced yet; leave empty if there is no price.'**
  String get priceComingSoonHint;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @pricingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Pricing is coming soon.'**
  String get pricingComingSoon;

  /// No description provided for @pricingPlans.
  ///
  /// In en, this message translates to:
  /// **'Pricing plans'**
  String get pricingPlans;

  /// No description provided for @pricingPlansHint.
  ///
  /// In en, this message translates to:
  /// **'Plans shown on the public pricing page.'**
  String get pricingPlansHint;

  /// No description provided for @pricingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Simple plans that grow with your store.'**
  String get pricingSubtitle;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to checkout'**
  String get proceedToCheckout;

  /// No description provided for @productImages.
  ///
  /// In en, this message translates to:
  /// **'Product images'**
  String get productImages;

  /// No description provided for @productImagesHint.
  ///
  /// In en, this message translates to:
  /// **'Upload, reorder and describe each image.'**
  String get productImagesHint;

  /// No description provided for @productImagesLimits.
  ///
  /// In en, this message translates to:
  /// **'JPEG, PNG or WebP up to 5 MB each.'**
  String get productImagesLimits;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @publishedAt.
  ///
  /// In en, this message translates to:
  /// **'Published at'**
  String get publishedAt;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @questionAr.
  ///
  /// In en, this message translates to:
  /// **'Question (Arabic)'**
  String get questionAr;

  /// No description provided for @readingMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min read'**
  String readingMinutes(Object count);

  /// No description provided for @readyToRecover.
  ///
  /// In en, this message translates to:
  /// **'Ready to recover'**
  String get readyToRecover;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @recovered.
  ///
  /// In en, this message translates to:
  /// **'Recovered'**
  String get recovered;

  /// No description provided for @recoveredRevenue.
  ///
  /// In en, this message translates to:
  /// **'Recovered revenue'**
  String get recoveredRevenue;

  /// No description provided for @recoveredValue.
  ///
  /// In en, this message translates to:
  /// **'Recovered value'**
  String get recoveredValue;

  /// No description provided for @recovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get recovery;

  /// No description provided for @recoveryOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Recovery opportunities'**
  String get recoveryOpportunities;

  /// No description provided for @recoverySummary.
  ///
  /// In en, this message translates to:
  /// **'Recovery summary'**
  String get recoverySummary;

  /// No description provided for @recoverySummaryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Recovery summary is unavailable.'**
  String get recoverySummaryUnavailable;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get rejectionReason;

  /// No description provided for @replied.
  ///
  /// In en, this message translates to:
  /// **'Replied'**
  String get replied;

  /// No description provided for @resourceType.
  ///
  /// In en, this message translates to:
  /// **'Resource type'**
  String get resourceType;

  /// No description provided for @responded.
  ///
  /// In en, this message translates to:
  /// **'Responded'**
  String get responded;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @rolesAndWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Roles and workspaces'**
  String get rolesAndWorkspaces;

  /// No description provided for @rolesHint.
  ///
  /// In en, this message translates to:
  /// **'Control what each team member can see and do.'**
  String get rolesHint;

  /// No description provided for @runCount.
  ///
  /// In en, this message translates to:
  /// **'Run count'**
  String get runCount;

  /// No description provided for @saveTrackingLink.
  ///
  /// In en, this message translates to:
  /// **'Save this link to check the order later.'**
  String get saveTrackingLink;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @scope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get scope;

  /// No description provided for @sectionsJson.
  ///
  /// In en, this message translates to:
  /// **'Sections (JSON)'**
  String get sectionsJson;

  /// No description provided for @sectionsJsonHint.
  ///
  /// In en, this message translates to:
  /// **'JSON array of content sections.'**
  String get sectionsJsonHint;

  /// No description provided for @seePricing.
  ///
  /// In en, this message translates to:
  /// **'See pricing'**
  String get seePricing;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(Object count);

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendAnotherMessage.
  ///
  /// In en, this message translates to:
  /// **'Send another message'**
  String get sendAnotherMessage;

  /// No description provided for @setPrimary.
  ///
  /// In en, this message translates to:
  /// **'Set primary'**
  String get setPrimary;

  /// No description provided for @shippingRevenue.
  ///
  /// In en, this message translates to:
  /// **'Shipping revenue'**
  String get shippingRevenue;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @shopLinkRequired.
  ///
  /// In en, this message translates to:
  /// **'Open a shop link'**
  String get shopLinkRequired;

  /// No description provided for @shopLinkRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'A shop link looks like /shop/{tenant}/{store}. Ask the merchant for theirs.'**
  String shopLinkRequiredHint(Object store, Object tenant);

  /// No description provided for @siteHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The commerce platform for modern merchants.'**
  String get siteHeroSubtitle;

  /// No description provided for @slugHint.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letters, numbers and dashes.'**
  String get slugHint;

  /// No description provided for @snoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed'**
  String get snoozed;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get sortPriceHigh;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceLow;

  /// No description provided for @sortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sortRecommended;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @startedAt.
  ///
  /// In en, this message translates to:
  /// **'Started at'**
  String get startedAt;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State / province'**
  String get state;

  /// No description provided for @stillHaveQuestions.
  ///
  /// In en, this message translates to:
  /// **'Still have questions?'**
  String get stillHaveQuestions;

  /// No description provided for @storeId.
  ///
  /// In en, this message translates to:
  /// **'Store ID'**
  String get storeId;

  /// No description provided for @stores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores;

  /// No description provided for @storesCount.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get storesCount;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @submitForApproval.
  ///
  /// In en, this message translates to:
  /// **'Submit for approval'**
  String get submitForApproval;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @subscribeToNewsletter.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to our newsletter'**
  String get subscribeToNewsletter;

  /// No description provided for @subscribeToNewsletterHint.
  ///
  /// In en, this message translates to:
  /// **'Product updates and merchant tips, no spam.'**
  String get subscribeToNewsletterHint;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscribed;

  /// No description provided for @subscribedAt.
  ///
  /// In en, this message translates to:
  /// **'Subscribed at'**
  String get subscribedAt;

  /// No description provided for @subscribers.
  ///
  /// In en, this message translates to:
  /// **'Subscribers'**
  String get subscribers;

  /// No description provided for @subscribersHint.
  ///
  /// In en, this message translates to:
  /// **'People who opted in to the newsletter.'**
  String get subscribersHint;

  /// No description provided for @subtotalEstimate.
  ///
  /// In en, this message translates to:
  /// **'Subtotal estimate'**
  String get subtotalEstimate;

  /// No description provided for @suggestedOrder.
  ///
  /// In en, this message translates to:
  /// **'Suggested order'**
  String get suggestedOrder;

  /// No description provided for @superAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super admin'**
  String get superAdmin;

  /// No description provided for @suspendTenant.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get suspendTenant;

  /// No description provided for @systemRole.
  ///
  /// In en, this message translates to:
  /// **'System role'**
  String get systemRole;

  /// No description provided for @systemRolePermissionsLocked.
  ///
  /// In en, this message translates to:
  /// **'System role permissions cannot be changed.'**
  String get systemRolePermissionsLocked;

  /// No description provided for @taxCollected.
  ///
  /// In en, this message translates to:
  /// **'Tax collected'**
  String get taxCollected;

  /// No description provided for @teamAndAccess.
  ///
  /// In en, this message translates to:
  /// **'Team and access'**
  String get teamAndAccess;

  /// No description provided for @teamHub.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get teamHub;

  /// No description provided for @teamHubHint.
  ///
  /// In en, this message translates to:
  /// **'People, roles and the audit trail.'**
  String get teamHubHint;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team members'**
  String get teamMembers;

  /// No description provided for @teamMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Invite people and manage their access.'**
  String get teamMembersHint;

  /// No description provided for @tenantScope.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get tenantScope;

  /// No description provided for @tenants.
  ///
  /// In en, this message translates to:
  /// **'Tenants'**
  String get tenants;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @timezoneHint.
  ///
  /// In en, this message translates to:
  /// **'IANA timezone, e.g. Asia/Riyadh.'**
  String get timezoneHint;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleAr.
  ///
  /// In en, this message translates to:
  /// **'Title (Arabic)'**
  String get titleAr;

  /// No description provided for @tooManyImages.
  ///
  /// In en, this message translates to:
  /// **'You can upload at most 8 images at once.'**
  String get tooManyImages;

  /// No description provided for @totalsResolvedAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'The final total is resolved by the store at checkout.'**
  String get totalsResolvedAtCheckout;

  /// No description provided for @findOrder.
  ///
  /// In en, this message translates to:
  /// **'Find order'**
  String get findOrder;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track an order'**
  String get trackOrder;

  /// No description provided for @trackOrderHelp.
  ///
  /// In en, this message translates to:
  /// **'Paste the token or the tracking link from your confirmation.'**
  String get trackOrderHelp;

  /// No description provided for @trackingToken.
  ///
  /// In en, this message translates to:
  /// **'Tracking token'**
  String get trackingToken;

  /// No description provided for @trackingTokenHint.
  ///
  /// In en, this message translates to:
  /// **'The token from your order confirmation.'**
  String get trackingTokenHint;

  /// No description provided for @trigger.
  ///
  /// In en, this message translates to:
  /// **'Trigger'**
  String get trigger;

  /// No description provided for @triggerConversationMessage.
  ///
  /// In en, this message translates to:
  /// **'Conversation message'**
  String get triggerConversationMessage;

  /// No description provided for @triggerInventoryLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get triggerInventoryLowStock;

  /// No description provided for @triggerOrderCreated.
  ///
  /// In en, this message translates to:
  /// **'Order created'**
  String get triggerOrderCreated;

  /// No description provided for @triggerOrderStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'Order status changed'**
  String get triggerOrderStatusChanged;

  /// No description provided for @triggerRecoveryDetected.
  ///
  /// In en, this message translates to:
  /// **'Recovery detected'**
  String get triggerRecoveryDetected;

  /// No description provided for @unsubscribed.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribed'**
  String get unsubscribed;

  /// No description provided for @unsubscribedAt.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribed at'**
  String get unsubscribedAt;

  /// No description provided for @uploadImages.
  ///
  /// In en, this message translates to:
  /// **'Upload images'**
  String get uploadImages;

  /// No description provided for @userAccounts.
  ///
  /// In en, this message translates to:
  /// **'User accounts'**
  String get userAccounts;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @usersCount.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersCount;

  /// No description provided for @verifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify account'**
  String get verifyAccount;

  /// No description provided for @viewDukavo.
  ///
  /// In en, this message translates to:
  /// **'View Dukavo'**
  String get viewDukavo;

  /// No description provided for @waitlist.
  ///
  /// In en, this message translates to:
  /// **'Waitlist'**
  String get waitlist;

  /// No description provided for @waitlistHint.
  ///
  /// In en, this message translates to:
  /// **'People waiting for an invitation.'**
  String get waitlistHint;

  /// No description provided for @waitlistJoined.
  ///
  /// In en, this message translates to:
  /// **'You are on the list'**
  String get waitlistJoined;

  /// No description provided for @waitlistJoinedHint.
  ///
  /// In en, this message translates to:
  /// **'We will email you when a place opens.'**
  String get waitlistJoinedHint;

  /// No description provided for @webhookVerifyToken.
  ///
  /// In en, this message translates to:
  /// **'Webhook verify token'**
  String get webhookVerifyToken;

  /// No description provided for @webhookVerifyTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Used to verify incoming webhook calls.'**
  String get webhookVerifyTokenHint;

  /// No description provided for @whatsappAccounts.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp accounts'**
  String get whatsappAccounts;

  /// No description provided for @workspaces.
  ///
  /// In en, this message translates to:
  /// **'Workspaces'**
  String get workspaces;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @pending_approval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get pending_approval;

  /// No description provided for @contacted.
  ///
  /// In en, this message translates to:
  /// **'Contacted'**
  String get contacted;

  /// No description provided for @eligible.
  ///
  /// In en, this message translates to:
  /// **'Eligible'**
  String get eligible;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @tenant.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get tenant;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Business. Connected.'**
  String get splashTagline;

  /// No description provided for @splashPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your workspace…'**
  String get splashPreparing;

  /// No description provided for @splashAi.
  ///
  /// In en, this message translates to:
  /// **'AI automation'**
  String get splashAi;

  /// No description provided for @publicNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get publicNavHome;

  /// No description provided for @publicNavFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get publicNavFeatures;

  /// No description provided for @publicNavPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get publicNavPricing;

  /// No description provided for @publicNavAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get publicNavAbout;

  /// No description provided for @publicNavMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get publicNavMore;

  /// No description provided for @publicNavHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get publicNavHowItWorks;

  /// No description provided for @publicNavFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get publicNavFaq;

  /// No description provided for @publicNavBlog.
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get publicNavBlog;

  /// No description provided for @publicNavContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get publicNavContact;

  /// No description provided for @publicOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open workspace'**
  String get publicOpenApp;

  /// No description provided for @publicBackToSite.
  ///
  /// In en, this message translates to:
  /// **'Back to site'**
  String get publicBackToSite;

  /// No description provided for @publicExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore Dukavo'**
  String get publicExplore;

  /// No description provided for @publicRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get publicRegister;

  /// No description provided for @publicCopyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} Dukavo. All rights reserved.'**
  String publicCopyright(Object year);

  /// No description provided for @publicLoginInviteOnly.
  ///
  /// In en, this message translates to:
  /// **'Accounts are created by invitation.'**
  String get publicLoginInviteOnly;

  /// No description provided for @publicRegisterHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get publicRegisterHaveAccount;

  /// No description provided for @publicFooterTagline.
  ///
  /// In en, this message translates to:
  /// **'Commerce operations for growing businesses.'**
  String get publicFooterTagline;

  /// No description provided for @publicFooterProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get publicFooterProduct;

  /// No description provided for @publicFooterResources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get publicFooterResources;

  /// No description provided for @publicFooterCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get publicFooterCompany;

  /// No description provided for @publicFooterLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get publicFooterLegal;

  /// No description provided for @publicMenuExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get publicMenuExplore;

  /// No description provided for @publicMenuAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get publicMenuAccount;

  /// No description provided for @publicMenuPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get publicMenuPreferences;

  /// No description provided for @publicMenuLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get publicMenuLegal;

  /// No description provided for @publicMenuOpenAppHint.
  ///
  /// In en, this message translates to:
  /// **'Continue to your workspace'**
  String get publicMenuOpenAppHint;

  /// No description provided for @publicMenuSignInHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your store'**
  String get publicMenuSignInHint;

  /// No description provided for @publicHomeBadge.
  ///
  /// In en, this message translates to:
  /// **'Arabic-first commerce platform'**
  String get publicHomeBadge;

  /// No description provided for @publicHomeTitleLine1.
  ///
  /// In en, this message translates to:
  /// **'Run your whole store'**
  String get publicHomeTitleLine1;

  /// No description provided for @publicHomeTitleFrom.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get publicHomeTitleFrom;

  /// No description provided for @publicHomeTitleAccent.
  ///
  /// In en, this message translates to:
  /// **'one place'**
  String get publicHomeTitleAccent;

  /// No description provided for @publicHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Products, inventory, orders, customers and WhatsApp conversations — everything you need to run your store in one place.'**
  String get publicHomeSubtitle;

  /// No description provided for @publicHomePrimary.
  ///
  /// In en, this message translates to:
  /// **'Join the waitlist'**
  String get publicHomePrimary;

  /// No description provided for @publicHomeSecondary.
  ///
  /// In en, this message translates to:
  /// **'See how Dukavo works'**
  String get publicHomeSecondary;

  /// No description provided for @publicHomeTickArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic-first'**
  String get publicHomeTickArabic;

  /// No description provided for @publicHomeTickWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp built in'**
  String get publicHomeTickWhatsapp;

  /// No description provided for @publicHomeTickTeam.
  ///
  /// In en, this message translates to:
  /// **'Team permissions'**
  String get publicHomeTickTeam;

  /// No description provided for @publicHomeEcosystemLabel.
  ///
  /// In en, this message translates to:
  /// **'What runs on Dukavo'**
  String get publicHomeEcosystemLabel;

  /// No description provided for @publicHomeEcosystemProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get publicHomeEcosystemProducts;

  /// No description provided for @publicHomeEcosystemInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get publicHomeEcosystemInventory;

  /// No description provided for @publicHomeEcosystemOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get publicHomeEcosystemOrders;

  /// No description provided for @publicHomeEcosystemCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get publicHomeEcosystemCustomers;

  /// No description provided for @publicHomeEcosystemConversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get publicHomeEcosystemConversations;

  /// No description provided for @publicHomeEcosystemTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get publicHomeEcosystemTeam;

  /// No description provided for @publicHomePillarsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get publicHomePillarsEyebrow;

  /// No description provided for @publicHomePillarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Five pillars, one system'**
  String get publicHomePillarsTitle;

  /// No description provided for @publicHomePillarsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One place for products, stock, orders, customers and conversations.'**
  String get publicHomePillarsSubtitle;

  /// No description provided for @publicHomeStoryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'From conversation to order'**
  String get publicHomeStoryEyebrow;

  /// No description provided for @publicHomeStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Without the chaos'**
  String get publicHomeStoryTitle;

  /// No description provided for @publicHomeStorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'The same five steps, every time.'**
  String get publicHomeStorySubtitle;

  /// No description provided for @publicHomePricingEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get publicHomePricingEyebrow;

  /// No description provided for @publicHomePricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Plans that grow with your business'**
  String get publicHomePricingTitle;

  /// No description provided for @publicHomePricingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Final pricing is being prepared. Join the waitlist to hear first.'**
  String get publicHomePricingSubtitle;

  /// No description provided for @publicHomeFaqEyebrow.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get publicHomeFaqEyebrow;

  /// No description provided for @publicHomeFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions you might have'**
  String get publicHomeFaqTitle;

  /// No description provided for @publicHomeBlogEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Blog & newsletter'**
  String get publicHomeBlogEyebrow;

  /// No description provided for @publicHomeBlogTitle.
  ///
  /// In en, this message translates to:
  /// **'Ideas for a more organised business'**
  String get publicHomeBlogTitle;

  /// No description provided for @publicHomeCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to get organised with us?'**
  String get publicHomeCtaTitle;

  /// No description provided for @publicHomeCtaBody.
  ///
  /// In en, this message translates to:
  /// **'Join the waitlist and we’ll set up your products, orders, customers and conversations together.'**
  String get publicHomeCtaBody;

  /// No description provided for @publicHomeCtaAction.
  ///
  /// In en, this message translates to:
  /// **'Join the waitlist'**
  String get publicHomeCtaAction;

  /// No description provided for @publicStepConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'The conversation'**
  String get publicStepConversationTitle;

  /// No description provided for @publicStepConversationBody.
  ///
  /// In en, this message translates to:
  /// **'The customer writes on WhatsApp, and the message lands in your Dukavo inbox.'**
  String get publicStepConversationBody;

  /// No description provided for @publicStepCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'The customer'**
  String get publicStepCustomerTitle;

  /// No description provided for @publicStepCustomerBody.
  ///
  /// In en, this message translates to:
  /// **'Dukavo recognises the customer and opens their profile with their history.'**
  String get publicStepCustomerBody;

  /// No description provided for @publicStepOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'The order'**
  String get publicStepOrderTitle;

  /// No description provided for @publicStepOrderBody.
  ///
  /// In en, this message translates to:
  /// **'Conversation becomes a structured order, with its items and its status.'**
  String get publicStepOrderBody;

  /// No description provided for @publicStepInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'The inventory'**
  String get publicStepInventoryTitle;

  /// No description provided for @publicStepInventoryBody.
  ///
  /// In en, this message translates to:
  /// **'Quantities drop automatically, with an alert when stock runs low.'**
  String get publicStepInventoryBody;

  /// No description provided for @publicStepTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'The team'**
  String get publicStepTeamTitle;

  /// No description provided for @publicStepTeamBody.
  ///
  /// In en, this message translates to:
  /// **'Every staff member sees and does only what their permissions allow.'**
  String get publicStepTeamBody;

  /// No description provided for @publicFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you need to run your store efficiently'**
  String get publicFeaturesTitle;

  /// No description provided for @publicFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The capabilities available today, and what is still on the way.'**
  String get publicFeaturesSubtitle;

  /// No description provided for @publicFeaturesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available now'**
  String get publicFeaturesAvailable;

  /// No description provided for @publicFeaturesAvailableHint.
  ///
  /// In en, this message translates to:
  /// **'These capabilities are live in the merchant workspace.'**
  String get publicFeaturesAvailableHint;

  /// No description provided for @publicFeaturesUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get publicFeaturesUpcoming;

  /// No description provided for @publicFeaturesUpcomingHint.
  ///
  /// In en, this message translates to:
  /// **'Planned capabilities, shown honestly until they ship.'**
  String get publicFeaturesUpcomingHint;

  /// No description provided for @publicFeaturesEmpty.
  ///
  /// In en, this message translates to:
  /// **'The public feature catalogue is empty.'**
  String get publicFeaturesEmpty;

  /// No description provided for @publicPricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Plans that fit how you sell'**
  String get publicPricingTitle;

  /// No description provided for @publicPricingHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transparent plans, published from the Dukavo platform.'**
  String get publicPricingHeroSubtitle;

  /// No description provided for @publicPricingInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite-only onboarding'**
  String get publicPricingInviteTitle;

  /// No description provided for @publicPricingInviteBody.
  ///
  /// In en, this message translates to:
  /// **'Dukavo is onboarding merchants from the waitlist. Join it and we’ll contact you when a place opens.'**
  String get publicPricingInviteBody;

  /// No description provided for @publicPricingTaxNote.
  ///
  /// In en, this message translates to:
  /// **'Prices shown are before tax unless the plan says otherwise.'**
  String get publicPricingTaxNote;

  /// No description provided for @publicPricingFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing questions'**
  String get publicPricingFaqTitle;

  /// No description provided for @publicPricingFaqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What merchants usually ask before choosing a plan.'**
  String get publicPricingFaqSubtitle;

  /// No description provided for @publicFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get publicFaqTitle;

  /// No description provided for @publicFaqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Short answers about Dukavo, onboarding and the waitlist.'**
  String get publicFaqSubtitle;

  /// No description provided for @publicFaqContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Still have questions?'**
  String get publicFaqContactTitle;

  /// No description provided for @publicFaqContactBody.
  ///
  /// In en, this message translates to:
  /// **'Send us a message and we’ll reply to the email you provide.'**
  String get publicFaqContactBody;

  /// No description provided for @publicBlogTitle.
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get publicBlogTitle;

  /// No description provided for @publicBlogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Guides and product notes from the Dukavo team.'**
  String get publicBlogSubtitle;

  /// No description provided for @publicBlogFeatured.
  ///
  /// In en, this message translates to:
  /// **'Latest article'**
  String get publicBlogFeatured;

  /// No description provided for @publicBlogAll.
  ///
  /// In en, this message translates to:
  /// **'All articles'**
  String get publicBlogAll;

  /// No description provided for @publicBlogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No articles yet'**
  String get publicBlogEmptyTitle;

  /// No description provided for @publicBlogEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'We haven’t published anything yet. Check back soon.'**
  String get publicBlogEmptyBody;

  /// No description provided for @publicBlogNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Article not found'**
  String get publicBlogNotFoundTitle;

  /// No description provided for @publicBlogNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This article may have been unpublished or removed.'**
  String get publicBlogNotFoundBody;

  /// No description provided for @publicBlogBack.
  ///
  /// In en, this message translates to:
  /// **'All articles'**
  String get publicBlogBack;

  /// No description provided for @publicContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Talk to us'**
  String get publicContactTitle;

  /// No description provided for @publicContactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Questions about Dukavo, pricing or onboarding? Send a message.'**
  String get publicContactSubtitle;

  /// No description provided for @publicContactResponse.
  ///
  /// In en, this message translates to:
  /// **'We usually reply within two business days.'**
  String get publicContactResponse;

  /// No description provided for @publicContactSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get publicContactSuccessTitle;

  /// No description provided for @publicContactSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'We reply to the email you provide.'**
  String get publicContactSuccessBody;

  /// No description provided for @publicContactHoneypot.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get publicContactHoneypot;

  /// No description provided for @publicWaitlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Join the waitlist'**
  String get publicWaitlistTitle;

  /// No description provided for @publicWaitlistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Be first to know when a place opens.'**
  String get publicWaitlistSubtitle;

  /// No description provided for @publicWaitlistBody.
  ///
  /// In en, this message translates to:
  /// **'Leave your email and we’ll contact you when Dukavo is ready for your store.'**
  String get publicWaitlistBody;

  /// No description provided for @publicWaitlistPrivacy.
  ///
  /// In en, this message translates to:
  /// **'We only use this email for your invitation.'**
  String get publicWaitlistPrivacy;

  /// No description provided for @publicAboutBadge.
  ///
  /// In en, this message translates to:
  /// **'About Dukavo'**
  String get publicAboutBadge;

  /// No description provided for @publicAboutContactCta.
  ///
  /// In en, this message translates to:
  /// **'Talk to us'**
  String get publicAboutContactCta;

  /// No description provided for @publicAboutUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'This page isn’t available yet'**
  String get publicAboutUnavailableTitle;

  /// No description provided for @publicAboutUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'It may still be in preparation. Please check back soon.'**
  String get publicAboutUnavailableBody;

  /// No description provided for @publicContentUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'This page isn’t available yet'**
  String get publicContentUnavailableTitle;

  /// No description provided for @publicContentUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'It may still be in preparation. Please check back soon.'**
  String get publicContentUnavailableBody;

  /// No description provided for @publicContentBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get publicContentBackHome;

  /// No description provided for @publicRegisterBadge.
  ///
  /// In en, this message translates to:
  /// **'Invite only'**
  String get publicRegisterBadge;

  /// No description provided for @publicRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Get an invitation'**
  String get publicRegisterTitle;

  /// No description provided for @publicRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dukavo creates merchant accounts by invitation, so onboarding stays deliberate and personal.'**
  String get publicRegisterSubtitle;

  /// No description provided for @publicRegisterStepOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Join the waitlist'**
  String get publicRegisterStepOneTitle;

  /// No description provided for @publicRegisterStepOneBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your store and the way you sell.'**
  String get publicRegisterStepOneBody;

  /// No description provided for @publicRegisterStepTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive your invitation'**
  String get publicRegisterStepTwoTitle;

  /// No description provided for @publicRegisterStepTwoBody.
  ///
  /// In en, this message translates to:
  /// **'We email an invitation when a place opens for your kind of business.'**
  String get publicRegisterStepTwoBody;

  /// No description provided for @publicRegisterStepThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in and set up'**
  String get publicRegisterStepThreeTitle;

  /// No description provided for @publicRegisterStepThreeBody.
  ///
  /// In en, this message translates to:
  /// **'Use the email in your invitation to sign in and create your workspace.'**
  String get publicRegisterStepThreeBody;

  /// No description provided for @publicRegisterNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Why invite-only?'**
  String get publicRegisterNoteTitle;

  /// No description provided for @publicRegisterNoteBody.
  ///
  /// In en, this message translates to:
  /// **'It lets us help each merchant migrate products, stock and customers properly instead of leaving them to a blank screen.'**
  String get publicRegisterNoteBody;

  /// No description provided for @publicVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get publicVerifyTitle;

  /// No description provided for @publicVerifyPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get publicVerifyPendingTitle;

  /// No description provided for @publicVerifyPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Verify your email so we can send invitations, receipts and account notices.'**
  String get publicVerifyPendingBody;

  /// No description provided for @publicVerifyVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get publicVerifyVerifiedTitle;

  /// No description provided for @publicVerifyVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Your email is verified. You’re all set.'**
  String get publicVerifyVerifiedBody;

  /// No description provided for @publicVerifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get publicVerifyResend;

  /// No description provided for @publicVerifyResendAgain.
  ///
  /// In en, this message translates to:
  /// **'Send it again'**
  String get publicVerifyResendAgain;

  /// No description provided for @publicVerifySent.
  ///
  /// In en, this message translates to:
  /// **'If the server allows it, the email is on its way.'**
  String get publicVerifySent;

  /// No description provided for @publicVerifySessionNote.
  ///
  /// In en, this message translates to:
  /// **'Sending verification email requires a signed-in session. If the server refuses, sign in again and retry.'**
  String get publicVerifySessionNote;

  /// No description provided for @publicHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How Dukavo works'**
  String get publicHowTitle;

  /// No description provided for @publicHowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From a WhatsApp message to a fulfilled order, without re-typing anything.'**
  String get publicHowSubtitle;

  /// No description provided for @publicHowSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Setting up'**
  String get publicHowSetupTitle;

  /// No description provided for @publicHowSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Three short steps when your invitation arrives.'**
  String get publicHowSetupSubtitle;

  /// No description provided for @publicHowSetupOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your products'**
  String get publicHowSetupOneTitle;

  /// No description provided for @publicHowSetupOneBody.
  ///
  /// In en, this message translates to:
  /// **'Import a catalogue or add products one by one, with prices and stock.'**
  String get publicHowSetupOneBody;

  /// No description provided for @publicHowSetupTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite your team'**
  String get publicHowSetupTwoTitle;

  /// No description provided for @publicHowSetupTwoBody.
  ///
  /// In en, this message translates to:
  /// **'Give each person the permissions their job needs, nothing more.'**
  String get publicHowSetupTwoBody;

  /// No description provided for @publicHowSetupThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your channels'**
  String get publicHowSetupThreeTitle;

  /// No description provided for @publicHowSetupThreeBody.
  ///
  /// In en, this message translates to:
  /// **'Bring WhatsApp conversations into the same inbox as orders and customers.'**
  String get publicHowSetupThreeBody;

  /// No description provided for @publicHowSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions are enforced by the server'**
  String get publicHowSecurityTitle;

  /// No description provided for @publicHowSecurityBody.
  ///
  /// In en, this message translates to:
  /// **'The app hides what you cannot use, and the API checks every request independently.'**
  String get publicHowSecurityBody;

  /// No description provided for @publicHowCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to get organised with us?'**
  String get publicHowCtaTitle;

  /// No description provided for @publicHowCtaBody.
  ///
  /// In en, this message translates to:
  /// **'Join the waitlist and we’ll set up your products, orders, customers and conversations together.'**
  String get publicHowCtaBody;

  /// No description provided for @translationAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI translations'**
  String get translationAssistant;

  /// No description provided for @translationOpen.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get translationOpen;

  /// No description provided for @translationReviewHint.
  ///
  /// In en, this message translates to:
  /// **'AI drafts stay private until you approve them.'**
  String get translationReviewHint;

  /// No description provided for @translationNoSelection.
  ///
  /// In en, this message translates to:
  /// **'Nothing selected'**
  String get translationNoSelection;

  /// No description provided for @translationSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String translationSelectedCount(Object count);

  /// No description provided for @translationApproveSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Approve {count}'**
  String translationApproveSelectedCount(Object count);

  /// No description provided for @translationGenerateTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate translations'**
  String get translationGenerateTitle;

  /// No description provided for @translationGenerateHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the fields and languages to translate. The result is a proposal, not a published change.'**
  String get translationGenerateHint;

  /// No description provided for @translationSourceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Source language'**
  String get translationSourceLanguage;

  /// No description provided for @translationSourceUnknown.
  ///
  /// In en, this message translates to:
  /// **'The source language could not be detected. Choose it explicitly.'**
  String get translationSourceUnknown;

  /// No description provided for @translationDetectedLanguage.
  ///
  /// In en, this message translates to:
  /// **'Detected {language} ({confidence}% confidence)'**
  String translationDetectedLanguage(Object confidence, Object language);

  /// No description provided for @translationSourceRequired.
  ///
  /// In en, this message translates to:
  /// **'Source language required'**
  String get translationSourceRequired;

  /// No description provided for @translationSourceRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the language this copy is written in so Dukavo translates from the right language.'**
  String get translationSourceRequiredHint;

  /// No description provided for @translationFields.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get translationFields;

  /// No description provided for @translationTargets.
  ///
  /// In en, this message translates to:
  /// **'Target languages'**
  String get translationTargets;

  /// No description provided for @translationNoTargets.
  ///
  /// In en, this message translates to:
  /// **'No other enabled language is available yet.'**
  String get translationNoTargets;

  /// No description provided for @translationGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get translationGenerate;

  /// No description provided for @translationUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'AI usage today'**
  String get translationUsageTitle;

  /// No description provided for @translationUsageSummary.
  ///
  /// In en, this message translates to:
  /// **'{requests} requests · {tokens} tokens · about {cost} estimated cost'**
  String translationUsageSummary(Object cost, Object requests, Object tokens);

  /// No description provided for @translationReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get translationReviewTitle;

  /// No description provided for @translationStale.
  ///
  /// In en, this message translates to:
  /// **'Stale'**
  String get translationStale;

  /// No description provided for @translationManuallyEdited.
  ///
  /// In en, this message translates to:
  /// **'Manually edited'**
  String get translationManuallyEdited;

  /// No description provided for @translationSourceCopy.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get translationSourceCopy;

  /// No description provided for @translationNotTranslatedYet.
  ///
  /// In en, this message translates to:
  /// **'Not translated yet.'**
  String get translationNotTranslatedYet;

  /// No description provided for @translationRejectionReasonValue.
  ///
  /// In en, this message translates to:
  /// **'Rejected: {reason}'**
  String translationRejectionReasonValue(Object reason);

  /// No description provided for @translationPublishedCopy.
  ///
  /// In en, this message translates to:
  /// **'Still public'**
  String get translationPublishedCopy;

  /// No description provided for @translationApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get translationApprove;

  /// No description provided for @translationEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get translationEdit;

  /// No description provided for @translationReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get translationReject;

  /// No description provided for @translationRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get translationRegenerate;

  /// No description provided for @translationStatusNotTranslated.
  ///
  /// In en, this message translates to:
  /// **'Not translated'**
  String get translationStatusNotTranslated;

  /// No description provided for @translationStatusGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating'**
  String get translationStatusGenerating;

  /// No description provided for @translationStatusGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get translationStatusGenerated;

  /// No description provided for @translationStatusNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get translationStatusNeedsReview;

  /// No description provided for @translationStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get translationStatusApproved;

  /// No description provided for @translationStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get translationStatusRejected;

  /// No description provided for @translationStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get translationStatusFailed;

  /// No description provided for @translationStatusStale.
  ///
  /// In en, this message translates to:
  /// **'Stale'**
  String get translationStatusStale;

  /// No description provided for @translationGenerated.
  ///
  /// In en, this message translates to:
  /// **'Translations generated for review.'**
  String get translationGenerated;

  /// No description provided for @translationApprovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Translation approved and published.'**
  String get translationApprovedMessage;

  /// No description provided for @translationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Translation updated and returned to review.'**
  String get translationUpdated;

  /// No description provided for @translationRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Translation rejected.'**
  String get translationRejectedMessage;

  /// No description provided for @translationNothingSelected.
  ///
  /// In en, this message translates to:
  /// **'Select at least one translation first.'**
  String get translationNothingSelected;

  /// No description provided for @translationTextRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the translated text.'**
  String get translationTextRequired;

  /// No description provided for @translationEditApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit published translation?'**
  String get translationEditApprovedTitle;

  /// No description provided for @translationEditApprovedMessage.
  ///
  /// In en, this message translates to:
  /// **'The current public copy stays live until you approve the new text.'**
  String get translationEditApprovedMessage;

  /// No description provided for @translationEditHint.
  ///
  /// In en, this message translates to:
  /// **'Edit the translation'**
  String get translationEditHint;

  /// No description provided for @translationRejectReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get translationRejectReason;

  /// No description provided for @translationRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Tell the reviewer why this proposal was rejected.'**
  String get translationRejectReasonHint;

  /// No description provided for @translationOverwriteMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces the current draft. Manually edited text and published copy need your confirmation before regeneration.'**
  String get translationOverwriteMessage;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @choosePaymentRail.
  ///
  /// In en, this message translates to:
  /// **'Choose how to pay'**
  String get choosePaymentRail;

  /// No description provided for @onlineRedirectNote.
  ///
  /// In en, this message translates to:
  /// **'You will continue to the provider\'s secure page. This order stays unpaid until the provider confirms.'**
  String get onlineRedirectNote;

  /// No description provided for @bankTransferNote.
  ///
  /// In en, this message translates to:
  /// **'Transfer the total to the store and keep the receipt. The store confirms the order when the money arrives.'**
  String get bankTransferNote;

  /// No description provided for @paymentProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get paymentProvider;

  /// No description provided for @paymentRail.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentRail;

  /// No description provided for @paymentAttempt.
  ///
  /// In en, this message translates to:
  /// **'Attempt'**
  String get paymentAttempt;

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentAmount;

  /// No description provided for @paymentReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get paymentReference;

  /// No description provided for @paymentPendingNote.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the provider to confirm. This page refreshes automatically.'**
  String get paymentPendingNote;

  /// No description provided for @paymentPaidNote.
  ///
  /// In en, this message translates to:
  /// **'The provider confirmed this payment.'**
  String get paymentPaidNote;

  /// No description provided for @paymentLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Open this link in your browser to pay. The order updates only after the provider confirms.'**
  String get paymentLinkHint;

  /// No description provided for @paymentLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Payment link copied.'**
  String get paymentLinkCopied;

  /// No description provided for @copyPaymentLink.
  ///
  /// In en, this message translates to:
  /// **'Copy payment link'**
  String get copyPaymentLink;

  /// No description provided for @retryPayment.
  ///
  /// In en, this message translates to:
  /// **'Try payment again'**
  String get retryPayment;

  /// No description provided for @orderAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get orderAwaitingPayment;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get bankTransfer;

  /// No description provided for @codNote.
  ///
  /// In en, this message translates to:
  /// **'Pay the courier on delivery. The order stays unpaid until then.'**
  String get codNote;

  /// No description provided for @twoFactorTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification'**
  String get twoFactorTitle;

  /// No description provided for @twoFactorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you to finish signing in.'**
  String get twoFactorSubtitle;

  /// No description provided for @twoFactorPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your authenticator app.'**
  String get twoFactorPrompt;

  /// No description provided for @twoFactorCode.
  ///
  /// In en, this message translates to:
  /// **'Authentication code'**
  String get twoFactorCode;

  /// No description provided for @twoFactorCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get twoFactorCodePlaceholder;

  /// No description provided for @twoFactorCodeLength.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code.'**
  String get twoFactorCodeLength;

  /// No description provided for @twoFactorVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify and sign in'**
  String get twoFactorVerify;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying'**
  String get verifying;

  /// No description provided for @twoFactorUseRecovery.
  ///
  /// In en, this message translates to:
  /// **'Use a recovery code'**
  String get twoFactorUseRecovery;

  /// No description provided for @twoFactorUseCode.
  ///
  /// In en, this message translates to:
  /// **'Use an authenticator code'**
  String get twoFactorUseCode;

  /// No description provided for @twoFactorRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get twoFactorRecoveryCode;

  /// No description provided for @twoFactorRecoveryHint.
  ///
  /// In en, this message translates to:
  /// **'One of the single-use codes you saved when you turned on two-step verification.'**
  String get twoFactorRecoveryHint;

  /// No description provided for @onboardingPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'A few things about you'**
  String get onboardingPreferencesTitle;

  /// No description provided for @onboardingPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We guessed these from your network and browser to save you time. Check them, change anything that is wrong, or skip for now.'**
  String get onboardingPreferencesSubtitle;

  /// No description provided for @onboardingPersonalTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get onboardingPersonalTitle;

  /// No description provided for @onboardingPersonalHint.
  ///
  /// In en, this message translates to:
  /// **'How your name and photo appear to your team.'**
  String get onboardingPersonalHint;

  /// No description provided for @onboardingLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Location helps us show local times. A guess from your network is approximate, never verified.'**
  String get onboardingLocationHint;

  /// No description provided for @onboardingDisplayHint.
  ///
  /// In en, this message translates to:
  /// **'Choose how Dukavo looks and reads for you.'**
  String get onboardingDisplayHint;

  /// No description provided for @onboardingDetectedBadge.
  ///
  /// In en, this message translates to:
  /// **'Detected for you'**
  String get onboardingDetectedBadge;

  /// No description provided for @onboardingApproximateBadge.
  ///
  /// In en, this message translates to:
  /// **'Some values are an estimate from your network. Review them before saving.'**
  String get onboardingApproximateBadge;

  /// No description provided for @onboardingSave.
  ///
  /// In en, this message translates to:
  /// **'Save preferences'**
  String get onboardingSave;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingSkip;

  /// No description provided for @onboardingSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved.'**
  String get onboardingSaved;

  /// No description provided for @onboardingSkipped.
  ///
  /// In en, this message translates to:
  /// **'No problem — you can change these any time in your profile.'**
  String get onboardingSkipped;

  /// No description provided for @onboardingFootnote.
  ///
  /// In en, this message translates to:
  /// **'These are personal settings. They never change a store\'s currency, prices or past orders.'**
  String get onboardingFootnote;

  /// No description provided for @onboardingPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm your language, currency and time zone so Dukavo feels right.'**
  String get onboardingPromptBody;

  /// No description provided for @onboardingPromptAction.
  ///
  /// In en, this message translates to:
  /// **'Review preferences'**
  String get onboardingPromptAction;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name.'**
  String get nameHint;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'A sentence or two about you. Optional.'**
  String get bioHint;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @countryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose a country'**
  String get countryPlaceholder;

  /// No description provided for @countrySearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name, code or dial code'**
  String get countrySearch;

  /// No description provided for @cityManualHint.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find it? Type the name — manual entry is always accepted.'**
  String get cityManualHint;

  /// No description provided for @phoneCountry.
  ///
  /// In en, this message translates to:
  /// **'Phone country code'**
  String get phoneCountry;

  /// No description provided for @phoneCountryHint.
  ///
  /// In en, this message translates to:
  /// **'The country your phone number belongs to.'**
  String get phoneCountryHint;

  /// No description provided for @timezonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose a time zone'**
  String get timezonePlaceholder;

  /// No description provided for @timezoneSearch.
  ///
  /// In en, this message translates to:
  /// **'Search time zones'**
  String get timezoneSearch;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get dateFormat;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time format'**
  String get timeFormat;

  /// No description provided for @timeFormat24.
  ///
  /// In en, this message translates to:
  /// **'24-hour (14:30)'**
  String get timeFormat24;

  /// No description provided for @timeFormat12.
  ///
  /// In en, this message translates to:
  /// **'12-hour (2:30 PM)'**
  String get timeFormat12;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Display preferences'**
  String get preferences;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account information'**
  String get accountInformation;

  /// No description provided for @accountMetaDesc.
  ///
  /// In en, this message translates to:
  /// **'Membership and security at a glance.'**
  String get accountMetaDesc;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get accountType;

  /// No description provided for @accountTypeMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get accountTypeMember;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @passwordNever.
  ///
  /// In en, this message translates to:
  /// **'Never changed'**
  String get passwordNever;

  /// No description provided for @profileComplete.
  ///
  /// In en, this message translates to:
  /// **'Your profile is complete.'**
  String get profileComplete;

  /// No description provided for @profileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Profile completeness'**
  String get profileCompletion;

  /// No description provided for @workspaceSeparationHint.
  ///
  /// In en, this message translates to:
  /// **'Changing these never changes a store\'s currency, prices or past orders.'**
  String get workspaceSeparationHint;

  /// No description provided for @locationAndPreferences.
  ///
  /// In en, this message translates to:
  /// **'Location and preferences'**
  String get locationAndPreferences;

  /// No description provided for @locationAndPreferencesDesc.
  ///
  /// In en, this message translates to:
  /// **'Personal to you — separate from any workspace settings.'**
  String get locationAndPreferencesDesc;

  /// No description provided for @securityCenter.
  ///
  /// In en, this message translates to:
  /// **'Security centre'**
  String get securityCenter;

  /// No description provided for @securityActivity.
  ///
  /// In en, this message translates to:
  /// **'Security activity'**
  String get securityActivity;

  /// No description provided for @securityActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign-ins, password changes and session changes on your account.'**
  String get securityActivityDesc;

  /// No description provided for @securityActivityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No security activity yet.'**
  String get securityActivityEmpty;

  /// No description provided for @sessionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Every device currently signed in to your account.'**
  String get sessionsDesc;

  /// No description provided for @twoFactor.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification'**
  String get twoFactor;

  /// No description provided for @twoFactorDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask for a code from your authenticator app when signing in.'**
  String get twoFactorDesc;

  /// No description provided for @twoFactorOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get twoFactorOn;

  /// No description provided for @twoFactorOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get twoFactorOff;

  /// No description provided for @twoFactorEnable.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get twoFactorEnable;

  /// No description provided for @twoFactorEnabled.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification is on.'**
  String get twoFactorEnabled;

  /// No description provided for @twoFactorDisabled.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification is off.'**
  String get twoFactorDisabled;

  /// No description provided for @twoFactorConfirm.
  ///
  /// In en, this message translates to:
  /// **'Turn on verification'**
  String get twoFactorConfirm;

  /// No description provided for @twoFactorSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Open your authenticator app, add this key, then enter the code it shows.'**
  String get twoFactorSetupIntro;

  /// No description provided for @twoFactorSecret.
  ///
  /// In en, this message translates to:
  /// **'Setup key'**
  String get twoFactorSecret;

  /// No description provided for @twoFactorSecretOnce.
  ///
  /// In en, this message translates to:
  /// **'This key is shown once. Store it somewhere safe.'**
  String get twoFactorSecretOnce;

  /// No description provided for @twoFactorProvisioningUri.
  ///
  /// In en, this message translates to:
  /// **'Setup link'**
  String get twoFactorProvisioningUri;

  /// No description provided for @twoFactorActiveSince.
  ///
  /// In en, this message translates to:
  /// **'On since {time}'**
  String twoFactorActiveSince(Object time);

  /// No description provided for @recoveryCodesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery codes'**
  String get recoveryCodesTitle;

  /// No description provided for @recoveryCodesOnce.
  ///
  /// In en, this message translates to:
  /// **'Save these now. Each code works once, and they will not be shown again.'**
  String get recoveryCodesOnce;

  /// No description provided for @recoveryCodesRegenerated.
  ///
  /// In en, this message translates to:
  /// **'New recovery codes created.'**
  String get recoveryCodesRegenerated;

  /// No description provided for @recoveryCodesRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} recovery codes left'**
  String recoveryCodesRemaining(Object count);

  /// No description provided for @regenerateRecoveryCodes.
  ///
  /// In en, this message translates to:
  /// **'New recovery codes'**
  String get regenerateRecoveryCodes;

  /// No description provided for @regenerateIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter a current authenticator code to replace your recovery codes. The old ones stop working.'**
  String get regenerateIntro;

  /// No description provided for @disableTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get disableTwoFactor;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password.'**
  String get currentPasswordRequired;

  /// No description provided for @requiresAuthenticationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter an authenticator code or a recovery code.'**
  String get requiresAuthenticationCode;

  /// No description provided for @useAuthenticatorCode.
  ///
  /// In en, this message translates to:
  /// **'Use an authenticator code'**
  String get useAuthenticatorCode;

  /// No description provided for @useRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Use a recovery code'**
  String get useRecoveryCode;

  /// No description provided for @recoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get recoveryCode;

  /// No description provided for @editProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Name, photo, bio and contact details.'**
  String get editProfileHint;

  /// No description provided for @changePasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Use a strong password you do not use anywhere else.'**
  String get changePasswordDesc;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @supportSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search guides and topics'**
  String get supportSearchHint;

  /// No description provided for @supportBrowseTopics.
  ///
  /// In en, this message translates to:
  /// **'Browse by topic'**
  String get supportBrowseTopics;

  /// No description provided for @supportFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured guides'**
  String get supportFeatured;

  /// No description provided for @supportPopular.
  ///
  /// In en, this message translates to:
  /// **'Most read guides'**
  String get supportPopular;

  /// No description provided for @supportArticlesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} articles'**
  String supportArticlesCount(Object count);

  /// No description provided for @supportSearchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching guides'**
  String get supportSearchEmptyTitle;

  /// No description provided for @supportSearchEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter term, or clear the search and browse by topic.'**
  String get supportSearchEmptyBody;

  /// No description provided for @supportEmptyCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No articles yet'**
  String get supportEmptyCategoryTitle;

  /// No description provided for @supportEmptyCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been published in this topic yet.'**
  String get supportEmptyCategoryBody;

  /// No description provided for @supportNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'We could not find this guide'**
  String get supportNotFoundTitle;

  /// No description provided for @supportNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'It may have moved or been renamed, or it is not available to you.'**
  String get supportNotFoundBody;

  /// No description provided for @supportRelated.
  ///
  /// In en, this message translates to:
  /// **'Related guides'**
  String get supportRelated;

  /// No description provided for @supportAllTopics.
  ///
  /// In en, this message translates to:
  /// **'Back to all topics'**
  String get supportAllTopics;

  /// No description provided for @supportFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Was this guide helpful?'**
  String get supportFeedbackTitle;

  /// No description provided for @supportFeedbackYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get supportFeedbackYes;

  /// No description provided for @supportFeedbackNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get supportFeedbackNo;

  /// No description provided for @supportFeedbackCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Anything to add? (optional)'**
  String get supportFeedbackCommentLabel;

  /// No description provided for @supportFeedbackCommentHint.
  ///
  /// In en, this message translates to:
  /// **'What were you trying to do?'**
  String get supportFeedbackCommentHint;

  /// No description provided for @supportFeedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send answer'**
  String get supportFeedbackSend;

  /// No description provided for @supportFeedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Your answer helps us improve this guide.'**
  String get supportFeedbackThanks;

  /// No description provided for @supportFeedbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send your answer. Please try again.'**
  String get supportFeedbackFailed;

  /// No description provided for @integrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get integrations;

  /// No description provided for @integrationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every channel your customers can reach you on.'**
  String get integrationsSubtitle;

  /// No description provided for @integrationsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get integrationsRefresh;

  /// No description provided for @integrationsConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get integrationsConnect;

  /// No description provided for @integrationsConnectChannel.
  ///
  /// In en, this message translates to:
  /// **'Connect {channel}'**
  String integrationsConnectChannel(Object channel);

  /// No description provided for @integrationsEditConnection.
  ///
  /// In en, this message translates to:
  /// **'Edit connection'**
  String get integrationsEditConnection;

  /// No description provided for @integrationsAvailabilityAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get integrationsAvailabilityAvailable;

  /// No description provided for @integrationsAvailabilityAwaitingConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Awaiting configuration'**
  String get integrationsAvailabilityAwaitingConfiguration;

  /// No description provided for @integrationsAvailabilityAwaitingProviderAccess.
  ///
  /// In en, this message translates to:
  /// **'Awaiting provider access'**
  String get integrationsAvailabilityAwaitingProviderAccess;

  /// No description provided for @integrationsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get integrationsStatusPending;

  /// No description provided for @integrationsStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get integrationsStatusConnected;

  /// No description provided for @integrationsStatusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get integrationsStatusDisconnected;

  /// No description provided for @integrationsStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get integrationsStatusError;

  /// No description provided for @integrationsHealthUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not checked'**
  String get integrationsHealthUnknown;

  /// No description provided for @integrationsHealthHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get integrationsHealthHealthy;

  /// No description provided for @integrationsHealthDegraded.
  ///
  /// In en, this message translates to:
  /// **'Degraded'**
  String get integrationsHealthDegraded;

  /// No description provided for @integrationsHealthFailing.
  ///
  /// In en, this message translates to:
  /// **'Failing'**
  String get integrationsHealthFailing;

  /// No description provided for @integrationsCapabilities.
  ///
  /// In en, this message translates to:
  /// **'Capabilities'**
  String get integrationsCapabilities;

  /// No description provided for @integrationsConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get integrationsConnections;

  /// No description provided for @integrationsNoConnections.
  ///
  /// In en, this message translates to:
  /// **'Nothing connected yet.'**
  String get integrationsNoConnections;

  /// No description provided for @integrationsAllStores.
  ///
  /// In en, this message translates to:
  /// **'All stores'**
  String get integrationsAllStores;

  /// No description provided for @integrationsName.
  ///
  /// In en, this message translates to:
  /// **'Connection name'**
  String get integrationsName;

  /// No description provided for @integrationsNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sales line'**
  String get integrationsNameHint;

  /// No description provided for @integrationsStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get integrationsStore;

  /// No description provided for @integrationsCredentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get integrationsCredentials;

  /// No description provided for @integrationsCredentialsHint.
  ///
  /// In en, this message translates to:
  /// **'Values are encrypted at rest and never shown again. Leave a secret blank to keep the stored value.'**
  String get integrationsCredentialsHint;

  /// No description provided for @integrationsRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get integrationsRequired;

  /// No description provided for @integrationsOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get integrationsOptional;

  /// No description provided for @integrationsConfigured.
  ///
  /// In en, this message translates to:
  /// **'Stored'**
  String get integrationsConfigured;

  /// No description provided for @integrationsSecretHint.
  ///
  /// In en, this message translates to:
  /// **'Stored — leave blank to keep it'**
  String get integrationsSecretHint;

  /// No description provided for @integrationsAwaitingAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Provider access not granted yet'**
  String get integrationsAwaitingAccessTitle;

  /// No description provided for @integrationsAwaitingAccessBody.
  ///
  /// In en, this message translates to:
  /// **'This channel is declared but Dukavo has no approved access to its API. You can save credentials now; the connection stays pending until access is granted and a real test succeeds.'**
  String get integrationsAwaitingAccessBody;

  /// No description provided for @integrationsAwaitingConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform configuration missing'**
  String get integrationsAwaitingConfigTitle;

  /// No description provided for @integrationsAwaitingConfigBody.
  ///
  /// In en, this message translates to:
  /// **'The installation is missing the platform-level keys this channel needs. Ask a platform administrator to configure it.'**
  String get integrationsAwaitingConfigBody;

  /// No description provided for @integrationsWebhook.
  ///
  /// In en, this message translates to:
  /// **'Webhook URL'**
  String get integrationsWebhook;

  /// No description provided for @integrationsCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied.'**
  String get integrationsCopied;

  /// No description provided for @integrationsCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'This device blocked clipboard access — copy it by hand.'**
  String get integrationsCopyFailed;

  /// No description provided for @integrationsTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get integrationsTest;

  /// No description provided for @integrationsReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get integrationsReconnect;

  /// No description provided for @integrationsDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get integrationsDisconnect;

  /// No description provided for @integrationsDisconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect {name}?'**
  String integrationsDisconnectTitle(Object name);

  /// No description provided for @integrationsDisconnectBody.
  ///
  /// In en, this message translates to:
  /// **'Customers will no longer reach you through this connection. Conversations stay in the inbox.'**
  String get integrationsDisconnectBody;

  /// No description provided for @integrationsSaved.
  ///
  /// In en, this message translates to:
  /// **'Connection saved.'**
  String get integrationsSaved;

  /// No description provided for @integrationsDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Connection disconnected.'**
  String get integrationsDisconnected;

  /// No description provided for @integrationsTested.
  ///
  /// In en, this message translates to:
  /// **'Connection tested.'**
  String get integrationsTested;

  /// No description provided for @integrationsReconnected.
  ///
  /// In en, this message translates to:
  /// **'Connection re-established.'**
  String get integrationsReconnected;

  /// No description provided for @integrationsError.
  ///
  /// In en, this message translates to:
  /// **'This connection reported an error.'**
  String get integrationsError;

  /// No description provided for @integrationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No channels available'**
  String get integrationsEmptyTitle;

  /// No description provided for @integrationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No messaging channels are declared in this installation.'**
  String get integrationsEmptyBody;

  /// No description provided for @integrationsNeverChecked.
  ///
  /// In en, this message translates to:
  /// **'Never checked'**
  String get integrationsNeverChecked;

  /// No description provided for @integrationsCapabilityText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get integrationsCapabilityText;

  /// No description provided for @integrationsCapabilityImage.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get integrationsCapabilityImage;

  /// No description provided for @integrationsCapabilityDocument.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get integrationsCapabilityDocument;

  /// No description provided for @integrationsCapabilityAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get integrationsCapabilityAudio;

  /// No description provided for @integrationsCapabilityVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice notes'**
  String get integrationsCapabilityVoice;

  /// No description provided for @integrationsCapabilityVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get integrationsCapabilityVideo;

  /// No description provided for @integrationsCapabilityTemplate.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get integrationsCapabilityTemplate;

  /// No description provided for @integrationsCapabilityDeliveryStatus.
  ///
  /// In en, this message translates to:
  /// **'Delivery status'**
  String get integrationsCapabilityDeliveryStatus;

  /// No description provided for @integrationsCapabilityReadStatus.
  ///
  /// In en, this message translates to:
  /// **'Read receipts'**
  String get integrationsCapabilityReadStatus;

  /// No description provided for @integrationsCapabilityMediaDownload.
  ///
  /// In en, this message translates to:
  /// **'Media download'**
  String get integrationsCapabilityMediaDownload;

  /// No description provided for @integrationsCapabilityTyping.
  ///
  /// In en, this message translates to:
  /// **'Typing indicator'**
  String get integrationsCapabilityTyping;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// No description provided for @platformSettings.
  ///
  /// In en, this message translates to:
  /// **'Platform settings'**
  String get platformSettings;

  /// No description provided for @platformSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One place for the configuration the whole platform shares. Tenant and store settings stay separate.'**
  String get platformSettingsSubtitle;

  /// No description provided for @platformSettingsSpecialists.
  ///
  /// In en, this message translates to:
  /// **'AI provider credentials and prompts, and the payment catalogue, are administered in the web platform console. This screen links to what the phone can safely change.'**
  String get platformSettingsSpecialists;

  /// No description provided for @platformSettingsAuditNote.
  ///
  /// In en, this message translates to:
  /// **'Every save is recorded in the audit log with the operator, the previous value and the new one. Secrets are redacted.'**
  String get platformSettingsAuditNote;

  /// No description provided for @platformSettingsSections.
  ///
  /// In en, this message translates to:
  /// **'Configuration sections'**
  String get platformSettingsSections;

  /// No description provided for @platformSettingsControls.
  ///
  /// In en, this message translates to:
  /// **'Platform controls'**
  String get platformSettingsControls;

  /// No description provided for @platformSettingsOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get platformSettingsOperations;

  /// No description provided for @platformSettingsSectionMeta.
  ///
  /// In en, this message translates to:
  /// **'{settings} settings · {overrides} overridden'**
  String platformSettingsSectionMeta(Object overrides, Object settings);

  /// No description provided for @platformSettingsSecretCount.
  ///
  /// In en, this message translates to:
  /// **'{count} secret'**
  String platformSettingsSecretCount(Object count);

  /// No description provided for @platformSettingsOverrides.
  ///
  /// In en, this message translates to:
  /// **'Overrides'**
  String get platformSettingsOverrides;

  /// No description provided for @platformSettingsSecrets.
  ///
  /// In en, this message translates to:
  /// **'Secrets'**
  String get platformSettingsSecrets;

  /// No description provided for @platformSettingsDefinitions.
  ///
  /// In en, this message translates to:
  /// **'Definitions'**
  String get platformSettingsDefinitions;

  /// No description provided for @platformSettingsRuntime.
  ///
  /// In en, this message translates to:
  /// **'Runtime'**
  String get platformSettingsRuntime;

  /// No description provided for @platformSettingsMaintenanceActive.
  ///
  /// In en, this message translates to:
  /// **'Maintenance mode is on'**
  String get platformSettingsMaintenanceActive;

  /// No description provided for @platformSettingsOpenMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Open maintenance'**
  String get platformSettingsOpenMaintenance;

  /// No description provided for @platformSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved.'**
  String get platformSettingsSaved;

  /// No description provided for @platformSettingsReadOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Read-only for your role'**
  String get platformSettingsReadOnlyTitle;

  /// No description provided for @platformSettingsReadOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'You can read this section but not change it. Ask a platform administrator for the matching permission.'**
  String get platformSettingsReadOnlyBody;

  /// No description provided for @platformSettingsEmptySection.
  ///
  /// In en, this message translates to:
  /// **'No settings are defined for this section.'**
  String get platformSettingsEmptySection;

  /// No description provided for @platformSettingsUnsaved.
  ///
  /// In en, this message translates to:
  /// **'{count} unsaved change(s)'**
  String platformSettingsUnsaved(Object count);

  /// No description provided for @platformSettingsClearOverride.
  ///
  /// In en, this message translates to:
  /// **'Reset to the environment or application default'**
  String get platformSettingsClearOverride;

  /// No description provided for @platformSettingsRequiresRestart.
  ///
  /// In en, this message translates to:
  /// **'Applies on next request'**
  String get platformSettingsRequiresRestart;

  /// No description provided for @platformSettingsSecretHint.
  ///
  /// In en, this message translates to:
  /// **'Ends in {hint}'**
  String platformSettingsSecretHint(Object hint);

  /// No description provided for @platformSettingsSecretPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter a new value to replace the stored secret'**
  String get platformSettingsSecretPlaceholder;

  /// No description provided for @platformSettingsSecretConfigured.
  ///
  /// In en, this message translates to:
  /// **'Configured'**
  String get platformSettingsSecretConfigured;

  /// No description provided for @platformSettingsSecretMissing.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get platformSettingsSecretMissing;

  /// No description provided for @platformSettingsChooseOption.
  ///
  /// In en, this message translates to:
  /// **'Choose an option'**
  String get platformSettingsChooseOption;

  /// No description provided for @platformSettingsRange.
  ///
  /// In en, this message translates to:
  /// **'Range {min}–{max}'**
  String platformSettingsRange(Object max, Object min);

  /// No description provided for @platformSettingsSourceDatabase.
  ///
  /// In en, this message translates to:
  /// **'Platform setting'**
  String get platformSettingsSourceDatabase;

  /// No description provided for @platformSettingsSourceEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get platformSettingsSourceEnvironment;

  /// No description provided for @platformSettingsSourceDefault.
  ///
  /// In en, this message translates to:
  /// **'Application default'**
  String get platformSettingsSourceDefault;

  /// No description provided for @settingsGroupIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get settingsGroupIdentity;

  /// No description provided for @settingsGroupApplication.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get settingsGroupApplication;

  /// No description provided for @settingsGroupBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get settingsGroupBrand;

  /// No description provided for @settingsGroupContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get settingsGroupContact;

  /// No description provided for @settingsGroupFormat.
  ///
  /// In en, this message translates to:
  /// **'Formats'**
  String get settingsGroupFormat;

  /// No description provided for @settingsGroupLanguage.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get settingsGroupLanguage;

  /// No description provided for @settingsGroupNumber.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get settingsGroupNumber;

  /// No description provided for @settingsGroupPassword.
  ///
  /// In en, this message translates to:
  /// **'Password policy'**
  String get settingsGroupPassword;

  /// No description provided for @settingsGroupRateLimits.
  ///
  /// In en, this message translates to:
  /// **'Rate limits'**
  String get settingsGroupRateLimits;

  /// No description provided for @settingsGroupRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get settingsGroupRegion;

  /// No description provided for @settingsGroupRouting.
  ///
  /// In en, this message translates to:
  /// **'Routing'**
  String get settingsGroupRouting;

  /// No description provided for @settingsGroupRuntime.
  ///
  /// In en, this message translates to:
  /// **'Runtime'**
  String get settingsGroupRuntime;

  /// No description provided for @settingsGroupSession.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get settingsGroupSession;

  /// No description provided for @settingsGroupSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get settingsGroupSocial;

  /// No description provided for @settingsGroupState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get settingsGroupState;

  /// No description provided for @settingsGroupTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get settingsGroupTransport;

  /// No description provided for @settingsGroupDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get settingsGroupDriver;

  /// No description provided for @settingsGroupGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGroupGeneral;

  /// No description provided for @platformSettingsFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform features'**
  String get platformSettingsFeaturesTitle;

  /// No description provided for @platformSettingsFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Platform-wide availability switches.'**
  String get platformSettingsFeaturesSubtitle;

  /// No description provided for @platformSettingsFeaturesNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Availability, not entitlement'**
  String get platformSettingsFeaturesNoteTitle;

  /// No description provided for @platformSettingsFeaturesNoteBody.
  ///
  /// In en, this message translates to:
  /// **'Turning a feature off removes it for every tenant, regardless of plan or permission. Data is preserved and the switch is reversible.'**
  String get platformSettingsFeaturesNoteBody;

  /// No description provided for @platformSettingsFeaturesEnabled.
  ///
  /// In en, this message translates to:
  /// **'{count} enabled'**
  String platformSettingsFeaturesEnabled(Object count);

  /// No description provided for @platformSettingsFeaturesTotal.
  ///
  /// In en, this message translates to:
  /// **'of {count}'**
  String platformSettingsFeaturesTotal(Object count);

  /// No description provided for @platformSettingsFeaturesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search features'**
  String get platformSettingsFeaturesSearch;

  /// No description provided for @platformSettingsFeaturesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No features match'**
  String get platformSettingsFeaturesEmptyTitle;

  /// No description provided for @platformSettingsFeaturesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get platformSettingsFeaturesEmptyBody;

  /// No description provided for @platformSettingsFeatureEnabled.
  ///
  /// In en, this message translates to:
  /// **'{name} is now available.'**
  String platformSettingsFeatureEnabled(Object name);

  /// No description provided for @platformSettingsFeatureDisabled.
  ///
  /// In en, this message translates to:
  /// **'{name} has been withdrawn.'**
  String platformSettingsFeatureDisabled(Object name);

  /// No description provided for @featureGroupIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Intelligence'**
  String get featureGroupIntelligence;

  /// No description provided for @featureGroupChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get featureGroupChannels;

  /// No description provided for @featureGroupCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get featureGroupCommunication;

  /// No description provided for @featureGroupOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get featureGroupOperations;

  /// No description provided for @featureGroupCommerce.
  ///
  /// In en, this message translates to:
  /// **'Commerce'**
  String get featureGroupCommerce;

  /// No description provided for @featureGroupGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get featureGroupGrowth;

  /// No description provided for @platformSettingsHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Integration health'**
  String get platformSettingsHealthTitle;

  /// No description provided for @platformSettingsHealthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last recorded state and on-demand probes.'**
  String get platformSettingsHealthSubtitle;

  /// No description provided for @platformSettingsHealthReadTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading does not probe'**
  String get platformSettingsHealthReadTitle;

  /// No description provided for @platformSettingsHealthReadBody.
  ///
  /// In en, this message translates to:
  /// **'This screen shows the last recorded state. A probe calls the provider, so it only runs when you ask for it.'**
  String get platformSettingsHealthReadBody;

  /// No description provided for @platformSettingsHealthEmpty.
  ///
  /// In en, this message translates to:
  /// **'No integrations are registered.'**
  String get platformSettingsHealthEmpty;

  /// No description provided for @platformSettingsHealthStateConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get platformSettingsHealthStateConnected;

  /// No description provided for @platformSettingsHealthStateDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get platformSettingsHealthStateDisconnected;

  /// No description provided for @platformSettingsHealthStateInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get platformSettingsHealthStateInvalidCredentials;

  /// No description provided for @platformSettingsHealthStateRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Rate limited'**
  String get platformSettingsHealthStateRateLimited;

  /// No description provided for @platformSettingsHealthStateServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable'**
  String get platformSettingsHealthStateServiceUnavailable;

  /// No description provided for @platformSettingsHealthStateConfigurationRequired.
  ///
  /// In en, this message translates to:
  /// **'Configuration required'**
  String get platformSettingsHealthStateConfigurationRequired;

  /// No description provided for @platformSettingsHealthStateNotTested.
  ///
  /// In en, this message translates to:
  /// **'Not tested'**
  String get platformSettingsHealthStateNotTested;

  /// No description provided for @platformSettingsHealthStateDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get platformSettingsHealthStateDisabled;

  /// No description provided for @platformSettingsHealthChecked.
  ///
  /// In en, this message translates to:
  /// **'{name} probe completed.'**
  String platformSettingsHealthChecked(Object name);

  /// No description provided for @platformSettingsHealthCheckedAt.
  ///
  /// In en, this message translates to:
  /// **'Checked {when}'**
  String platformSettingsHealthCheckedAt(Object when);

  /// No description provided for @platformSettingsHealthNever.
  ///
  /// In en, this message translates to:
  /// **'Never checked'**
  String get platformSettingsHealthNever;

  /// No description provided for @platformSettingsHealthTest.
  ///
  /// In en, this message translates to:
  /// **'Run check'**
  String get platformSettingsHealthTest;

  /// No description provided for @platformSettingsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration history'**
  String get platformSettingsHistoryTitle;

  /// No description provided for @platformSettingsHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who changed what, and what it replaced.'**
  String get platformSettingsHistorySubtitle;

  /// No description provided for @platformSettingsHistoryFilter.
  ///
  /// In en, this message translates to:
  /// **'Setting key'**
  String get platformSettingsHistoryFilter;

  /// No description provided for @platformSettingsHistoryFilterHint.
  ///
  /// In en, this message translates to:
  /// **'email.mail_host'**
  String get platformSettingsHistoryFilterHint;

  /// No description provided for @platformSettingsHistoryRows.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get platformSettingsHistoryRows;

  /// No description provided for @platformSettingsHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No changes yet'**
  String get platformSettingsHistoryEmpty;

  /// No description provided for @platformSettingsHistoryEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No change matches this key.'**
  String get platformSettingsHistoryEmptyFiltered;

  /// No description provided for @platformSettingsHistoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Saving a setting will record it here.'**
  String get platformSettingsHistoryEmptyBody;

  /// No description provided for @platformSettingsHistoryNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get platformSettingsHistoryNone;

  /// No description provided for @platformSettingsHistorySecret.
  ///
  /// In en, this message translates to:
  /// **'Secret · ends in {hint}'**
  String platformSettingsHistorySecret(Object hint);

  /// No description provided for @platformSettingsHistorySystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get platformSettingsHistorySystem;

  /// No description provided for @platformSettingsInfrastructureTitle.
  ///
  /// In en, this message translates to:
  /// **'Infrastructure'**
  String get platformSettingsInfrastructureTitle;

  /// No description provided for @platformSettingsInfrastructureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read-only values managed by the deployment environment.'**
  String get platformSettingsInfrastructureSubtitle;

  /// No description provided for @platformSettingsInfraReadOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Managed by the deployment environment'**
  String get platformSettingsInfraReadOnlyTitle;

  /// No description provided for @platformSettingsInfraReadOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'These values are read-only here by design. Change them in the deployment environment and redeploy; secrets are shown as configured or not configured only.'**
  String get platformSettingsInfraReadOnlyBody;

  /// No description provided for @platformSettingsInfraRuntimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Running process'**
  String get platformSettingsInfraRuntimeTitle;

  /// No description provided for @platformSettingsInfraVariablesTitle.
  ///
  /// In en, this message translates to:
  /// **'Environment variables'**
  String get platformSettingsInfraVariablesTitle;

  /// No description provided for @platformSettingsInfraPhp.
  ///
  /// In en, this message translates to:
  /// **'PHP'**
  String get platformSettingsInfraPhp;

  /// No description provided for @platformSettingsInfraLaravel.
  ///
  /// In en, this message translates to:
  /// **'Laravel'**
  String get platformSettingsInfraLaravel;

  /// No description provided for @platformSettingsInfraDatabase.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get platformSettingsInfraDatabase;

  /// No description provided for @platformSettingsInfraCache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get platformSettingsInfraCache;

  /// No description provided for @platformSettingsInfraQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get platformSettingsInfraQueue;

  /// No description provided for @platformSettingsInfraSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get platformSettingsInfraSession;

  /// No description provided for @platformSettingsInfraMailer.
  ///
  /// In en, this message translates to:
  /// **'Mailer'**
  String get platformSettingsInfraMailer;

  /// No description provided for @platformSettingsInfraFilesystem.
  ///
  /// In en, this message translates to:
  /// **'Filesystem'**
  String get platformSettingsInfraFilesystem;

  /// No description provided for @actionPreviews.
  ///
  /// In en, this message translates to:
  /// **'Action previews'**
  String get actionPreviews;

  /// No description provided for @actionUrl.
  ///
  /// In en, this message translates to:
  /// **'Action URL'**
  String get actionUrl;

  /// No description provided for @activateTenantMessage.
  ///
  /// In en, this message translates to:
  /// **'Activate this tenant?'**
  String get activateTenantMessage;

  /// No description provided for @activeVersion.
  ///
  /// In en, this message translates to:
  /// **'Active version'**
  String get activeVersion;

  /// No description provided for @activityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity log'**
  String get activityLog;

  /// No description provided for @adapter.
  ///
  /// In en, this message translates to:
  /// **'Adapter'**
  String get adapter;

  /// No description provided for @addPaymentConnection.
  ///
  /// In en, this message translates to:
  /// **'Add payment connection'**
  String get addPaymentConnection;

  /// No description provided for @aiAdminReadOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'This surface is read-only apart from credential rotation.'**
  String get aiAdminReadOnlyNote;

  /// No description provided for @aiAdministration.
  ///
  /// In en, this message translates to:
  /// **'AI administration'**
  String get aiAdministration;

  /// No description provided for @aiCopilot.
  ///
  /// In en, this message translates to:
  /// **'AI copilot'**
  String get aiCopilot;

  /// No description provided for @aiCopilotHint.
  ///
  /// In en, this message translates to:
  /// **'The copilot answers only from the dashboard\'s real figures and never invents numbers.'**
  String get aiCopilotHint;

  /// No description provided for @aiCopilotQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'Example: what should I focus on this week?'**
  String get aiCopilotQuestionHint;

  /// No description provided for @aiFeatureLimits.
  ///
  /// In en, this message translates to:
  /// **'AI feature limits'**
  String get aiFeatureLimits;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI insights'**
  String get aiInsights;

  /// No description provided for @aiPrompts.
  ///
  /// In en, this message translates to:
  /// **'Prompts'**
  String get aiPrompts;

  /// No description provided for @aiServing.
  ///
  /// In en, this message translates to:
  /// **'AI serving'**
  String get aiServing;

  /// No description provided for @aiTasks.
  ///
  /// In en, this message translates to:
  /// **'AI tasks'**
  String get aiTasks;

  /// No description provided for @aiTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get aiTestConnection;

  /// No description provided for @aiUsage30Days.
  ///
  /// In en, this message translates to:
  /// **'Usage over 30 days'**
  String get aiUsage30Days;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get apiKey;

  /// No description provided for @applyTemplateUpdate.
  ///
  /// In en, this message translates to:
  /// **'Apply template update'**
  String get applyTemplateUpdate;

  /// No description provided for @applyTemplateUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'Apply the newer template version to this installation?'**
  String get applyTemplateUpdateMessage;

  /// No description provided for @approveAiActionMessage.
  ///
  /// In en, this message translates to:
  /// **'Approve this AI action?'**
  String get approveAiActionMessage;

  /// No description provided for @archiveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Archive template'**
  String get archiveTemplate;

  /// No description provided for @archiveTemplateMessage.
  ///
  /// In en, this message translates to:
  /// **'Archive this template? New stores will no longer see it.'**
  String get archiveTemplateMessage;

  /// No description provided for @askCopilot.
  ///
  /// In en, this message translates to:
  /// **'Ask copilot'**
  String get askCopilot;

  /// No description provided for @attempt.
  ///
  /// In en, this message translates to:
  /// **'Attempt'**
  String get attempt;

  /// No description provided for @attempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get attempts;

  /// No description provided for @audience.
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get audience;

  /// No description provided for @automationInstallations.
  ///
  /// In en, this message translates to:
  /// **'Automation installations'**
  String get automationInstallations;

  /// No description provided for @automationInstallationsHint.
  ///
  /// In en, this message translates to:
  /// **'Rules installed from platform templates.'**
  String get automationInstallationsHint;

  /// No description provided for @automationTemplates.
  ///
  /// In en, this message translates to:
  /// **'Automation templates'**
  String get automationTemplates;

  /// No description provided for @automationTemplatesHint.
  ///
  /// In en, this message translates to:
  /// **'Ready-made platform blueprints you can install in your store.'**
  String get automationTemplatesHint;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @baseUrl.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get baseUrl;

  /// No description provided for @byokDisabled.
  ///
  /// In en, this message translates to:
  /// **'Platform key is active'**
  String get byokDisabled;

  /// No description provided for @byokEnabled.
  ///
  /// In en, this message translates to:
  /// **'Tenant key is active'**
  String get byokEnabled;

  /// No description provided for @cacheHit.
  ///
  /// In en, this message translates to:
  /// **'Cache hit'**
  String get cacheHit;

  /// No description provided for @cacheHits.
  ///
  /// In en, this message translates to:
  /// **'Cache hits'**
  String get cacheHits;

  /// No description provided for @campaigns.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get campaigns;

  /// No description provided for @cancelCampaign.
  ///
  /// In en, this message translates to:
  /// **'Cancel campaign'**
  String get cancelCampaign;

  /// No description provided for @cancelCampaignMessage.
  ///
  /// In en, this message translates to:
  /// **'Cancel this campaign?'**
  String get cancelCampaignMessage;

  /// No description provided for @cancelledAt.
  ///
  /// In en, this message translates to:
  /// **'Cancelled at'**
  String get cancelledAt;

  /// No description provided for @capabilities.
  ///
  /// In en, this message translates to:
  /// **'Capabilities'**
  String get capabilities;

  /// No description provided for @changelog.
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelog;

  /// No description provided for @channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channel;

  /// No description provided for @channelKey.
  ///
  /// In en, this message translates to:
  /// **'Channel key'**
  String get channelKey;

  /// No description provided for @channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// No description provided for @configurationSchema.
  ///
  /// In en, this message translates to:
  /// **'Configuration schema'**
  String get configurationSchema;

  /// No description provided for @connectionVerified.
  ///
  /// In en, this message translates to:
  /// **'Connection verified'**
  String get connectionVerified;

  /// No description provided for @connections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get connections;

  /// No description provided for @correlationId.
  ///
  /// In en, this message translates to:
  /// **'Correlation ID'**
  String get correlationId;

  /// No description provided for @countries.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get countries;

  /// No description provided for @counts.
  ///
  /// In en, this message translates to:
  /// **'Counts'**
  String get counts;

  /// No description provided for @credentialFields.
  ///
  /// In en, this message translates to:
  /// **'Credential fields'**
  String get credentialFields;

  /// No description provided for @credentialSource.
  ///
  /// In en, this message translates to:
  /// **'Credential source'**
  String get credentialSource;

  /// No description provided for @credentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get credentials;

  /// No description provided for @currentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get currentVersion;

  /// No description provided for @dailyPerTenant.
  ///
  /// In en, this message translates to:
  /// **'Daily per tenant'**
  String get dailyPerTenant;

  /// No description provided for @dailyPerUser.
  ///
  /// In en, this message translates to:
  /// **'Daily per user'**
  String get dailyPerUser;

  /// No description provided for @dataGaps.
  ///
  /// In en, this message translates to:
  /// **'Data gaps'**
  String get dataGaps;

  /// No description provided for @deliveredAt.
  ///
  /// In en, this message translates to:
  /// **'Delivered at'**
  String get deliveredAt;

  /// No description provided for @deliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveries;

  /// No description provided for @descriptionAr.
  ///
  /// In en, this message translates to:
  /// **'Description (Arabic)'**
  String get descriptionAr;

  /// No description provided for @disableInstallation.
  ///
  /// In en, this message translates to:
  /// **'Disable installation'**
  String get disableInstallation;

  /// No description provided for @disableInstallationMessage.
  ///
  /// In en, this message translates to:
  /// **'Disable this installation? It will stop running.'**
  String get disableInstallationMessage;

  /// No description provided for @disconnectAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Disconnect this account?'**
  String get disconnectAccountMessage;

  /// No description provided for @dismissRecoveryMessage.
  ///
  /// In en, this message translates to:
  /// **'Dismiss this recovery opportunity?'**
  String get dismissRecoveryMessage;

  /// No description provided for @dismissTaskMessage.
  ///
  /// In en, this message translates to:
  /// **'Dismiss this task?'**
  String get dismissTaskMessage;

  /// No description provided for @doNotContactMessage.
  ///
  /// In en, this message translates to:
  /// **'Mark this customer as do-not-contact?'**
  String get doNotContactMessage;

  /// No description provided for @docsUrl.
  ///
  /// In en, this message translates to:
  /// **'Documentation URL'**
  String get docsUrl;

  /// No description provided for @draftMessageMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a message draft?'**
  String get draftMessageMessage;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @durationMs.
  ///
  /// In en, this message translates to:
  /// **'Duration (ms)'**
  String get durationMs;

  /// No description provided for @effectiveCopy.
  ///
  /// In en, this message translates to:
  /// **'Effective copy'**
  String get effectiveCopy;

  /// No description provided for @emailTemplates.
  ///
  /// In en, this message translates to:
  /// **'Email templates'**
  String get emailTemplates;

  /// No description provided for @enableInstallation.
  ///
  /// In en, this message translates to:
  /// **'Enable installation'**
  String get enableInstallation;

  /// No description provided for @enabledAt.
  ///
  /// In en, this message translates to:
  /// **'Enabled at'**
  String get enabledAt;

  /// No description provided for @errorCategory.
  ///
  /// In en, this message translates to:
  /// **'Error category'**
  String get errorCategory;

  /// No description provided for @estimatedCost.
  ///
  /// In en, this message translates to:
  /// **'Estimated cost'**
  String get estimatedCost;

  /// No description provided for @estimatesAndRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Estimates and recommendations'**
  String get estimatesAndRecommendations;

  /// No description provided for @eventId.
  ///
  /// In en, this message translates to:
  /// **'Event ID'**
  String get eventId;

  /// No description provided for @eventKey.
  ///
  /// In en, this message translates to:
  /// **'Event key'**
  String get eventKey;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'Event type'**
  String get eventType;

  /// No description provided for @executeAiActionMessage.
  ///
  /// In en, this message translates to:
  /// **'Execute this AI action now?'**
  String get executeAiActionMessage;

  /// No description provided for @factsUsed.
  ///
  /// In en, this message translates to:
  /// **'Facts used'**
  String get factsUsed;

  /// No description provided for @failedAt.
  ///
  /// In en, this message translates to:
  /// **'Failed at'**
  String get failedAt;

  /// No description provided for @failing.
  ///
  /// In en, this message translates to:
  /// **'Failing'**
  String get failing;

  /// No description provided for @failureReason.
  ///
  /// In en, this message translates to:
  /// **'Failure reason'**
  String get failureReason;

  /// No description provided for @failureType.
  ///
  /// In en, this message translates to:
  /// **'Failure type'**
  String get failureType;

  /// No description provided for @failures.
  ///
  /// In en, this message translates to:
  /// **'Failures'**
  String get failures;

  /// No description provided for @fallbackAttempts.
  ///
  /// In en, this message translates to:
  /// **'Fallback attempts'**
  String get fallbackAttempts;

  /// No description provided for @fallbackRequests.
  ///
  /// In en, this message translates to:
  /// **'Fallback requests'**
  String get fallbackRequests;

  /// No description provided for @feature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get feature;

  /// No description provided for @fromStore.
  ///
  /// In en, this message translates to:
  /// **'From store'**
  String get fromStore;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @headingAr.
  ///
  /// In en, this message translates to:
  /// **'Heading (Arabic)'**
  String get headingAr;

  /// No description provided for @headingEn.
  ///
  /// In en, this message translates to:
  /// **'Heading (English)'**
  String get headingEn;

  /// No description provided for @httpStatus.
  ///
  /// In en, this message translates to:
  /// **'HTTP status'**
  String get httpStatus;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @inputTokens.
  ///
  /// In en, this message translates to:
  /// **'Input tokens'**
  String get inputTokens;

  /// No description provided for @installTemplate.
  ///
  /// In en, this message translates to:
  /// **'Install template'**
  String get installTemplate;

  /// No description provided for @installTemplateMessage.
  ///
  /// In en, this message translates to:
  /// **'Install this template in your workspace?'**
  String get installTemplateMessage;

  /// No description provided for @installation.
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get installation;

  /// No description provided for @installations.
  ///
  /// In en, this message translates to:
  /// **'Installations'**
  String get installations;

  /// No description provided for @installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installed;

  /// No description provided for @installedAt.
  ///
  /// In en, this message translates to:
  /// **'Installed at'**
  String get installedAt;

  /// No description provided for @installedVersion.
  ///
  /// In en, this message translates to:
  /// **'Installed version'**
  String get installedVersion;

  /// No description provided for @installer.
  ///
  /// In en, this message translates to:
  /// **'Installer'**
  String get installer;

  /// No description provided for @integrationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Integration enabled'**
  String get integrationEnabled;

  /// No description provided for @integrationHealth.
  ///
  /// In en, this message translates to:
  /// **'Integration health'**
  String get integrationHealth;

  /// No description provided for @introAr.
  ///
  /// In en, this message translates to:
  /// **'Intro (Arabic)'**
  String get introAr;

  /// No description provided for @introEn.
  ///
  /// In en, this message translates to:
  /// **'Intro (English)'**
  String get introEn;

  /// No description provided for @inventoryTransfer.
  ///
  /// In en, this message translates to:
  /// **'Inventory transfer'**
  String get inventoryTransfer;

  /// No description provided for @inventoryTransferHint.
  ///
  /// In en, this message translates to:
  /// **'Move a product variant between two stores in the same workspace. The server checks both stores and the stock.'**
  String get inventoryTransferHint;

  /// No description provided for @isMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing message'**
  String get isMarketing;

  /// No description provided for @key.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get key;

  /// No description provided for @kind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get kind;

  /// No description provided for @lastSyncedAt.
  ///
  /// In en, this message translates to:
  /// **'Last synced'**
  String get lastSyncedAt;

  /// No description provided for @lastVerified.
  ///
  /// In en, this message translates to:
  /// **'Last verified'**
  String get lastVerified;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @makeDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Make this the default?'**
  String get makeDefaultMessage;

  /// No description provided for @markCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Mark this as completed?'**
  String get markCompletedMessage;

  /// No description provided for @maxOutputTokens.
  ///
  /// In en, this message translates to:
  /// **'Max output tokens'**
  String get maxOutputTokens;

  /// No description provided for @maxRetries.
  ///
  /// In en, this message translates to:
  /// **'Max retries'**
  String get maxRetries;

  /// No description provided for @merchantReference.
  ///
  /// In en, this message translates to:
  /// **'Merchant reference'**
  String get merchantReference;

  /// No description provided for @methodCode.
  ///
  /// In en, this message translates to:
  /// **'Method code'**
  String get methodCode;

  /// No description provided for @metricExplanations.
  ///
  /// In en, this message translates to:
  /// **'Metric explanations'**
  String get metricExplanations;

  /// No description provided for @missingData.
  ///
  /// In en, this message translates to:
  /// **'Missing data'**
  String get missingData;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @models.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get models;

  /// No description provided for @monthlyPerTenant.
  ///
  /// In en, this message translates to:
  /// **'Monthly per tenant'**
  String get monthlyPerTenant;

  /// No description provided for @monthlyPlatformRequests.
  ///
  /// In en, this message translates to:
  /// **'Monthly platform requests'**
  String get monthlyPlatformRequests;

  /// No description provided for @nameAr.
  ///
  /// In en, this message translates to:
  /// **'Name (Arabic)'**
  String get nameAr;

  /// No description provided for @noAiPrompts.
  ///
  /// In en, this message translates to:
  /// **'No prompts yet'**
  String get noAiPrompts;

  /// No description provided for @noAiTasks.
  ///
  /// In en, this message translates to:
  /// **'No AI tasks yet'**
  String get noAiTasks;

  /// No description provided for @noAnswerReturned.
  ///
  /// In en, this message translates to:
  /// **'The copilot returned no answer.'**
  String get noAnswerReturned;

  /// No description provided for @noAutomationInstallations.
  ///
  /// In en, this message translates to:
  /// **'No automation installations'**
  String get noAutomationInstallations;

  /// No description provided for @noAutomationTemplates.
  ///
  /// In en, this message translates to:
  /// **'No automation templates'**
  String get noAutomationTemplates;

  /// No description provided for @noCampaigns.
  ///
  /// In en, this message translates to:
  /// **'No campaigns'**
  String get noCampaigns;

  /// No description provided for @noConnections.
  ///
  /// In en, this message translates to:
  /// **'No connections'**
  String get noConnections;

  /// No description provided for @noCountries.
  ///
  /// In en, this message translates to:
  /// **'No countries'**
  String get noCountries;

  /// No description provided for @noCredentials.
  ///
  /// In en, this message translates to:
  /// **'No credentials'**
  String get noCredentials;

  /// No description provided for @noDeliveries.
  ///
  /// In en, this message translates to:
  /// **'No deliveries'**
  String get noDeliveries;

  /// No description provided for @noEmailTemplates.
  ///
  /// In en, this message translates to:
  /// **'No email templates'**
  String get noEmailTemplates;

  /// No description provided for @noIntegrations.
  ///
  /// In en, this message translates to:
  /// **'No integrations'**
  String get noIntegrations;

  /// No description provided for @noPaymentConnections.
  ///
  /// In en, this message translates to:
  /// **'No payment connections'**
  String get noPaymentConnections;

  /// No description provided for @noPaymentConnectionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a connection so the store can collect payments.'**
  String get noPaymentConnectionsMessage;

  /// No description provided for @noPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments'**
  String get noPayments;

  /// No description provided for @noProviders.
  ///
  /// In en, this message translates to:
  /// **'No providers'**
  String get noProviders;

  /// No description provided for @noVariantsToTransfer.
  ///
  /// In en, this message translates to:
  /// **'No product variants to transfer'**
  String get noVariantsToTransfer;

  /// No description provided for @noWebhookEvents.
  ///
  /// In en, this message translates to:
  /// **'No webhook events'**
  String get noWebhookEvents;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @notificationOperations.
  ///
  /// In en, this message translates to:
  /// **'Notification operations'**
  String get notificationOperations;

  /// No description provided for @operations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get operations;

  /// No description provided for @outputTokens.
  ///
  /// In en, this message translates to:
  /// **'Output tokens'**
  String get outputTokens;

  /// No description provided for @paidAt.
  ///
  /// In en, this message translates to:
  /// **'Paid at'**
  String get paidAt;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentCatalogue.
  ///
  /// In en, this message translates to:
  /// **'Payment catalogue'**
  String get paymentCatalogue;

  /// No description provided for @paymentConnections.
  ///
  /// In en, this message translates to:
  /// **'Payment connections'**
  String get paymentConnections;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get paymentHistory;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @platformConfigured.
  ///
  /// In en, this message translates to:
  /// **'Configured on the platform'**
  String get platformConfigured;

  /// No description provided for @processedAt.
  ///
  /// In en, this message translates to:
  /// **'Processed at'**
  String get processedAt;

  /// No description provided for @productVariant.
  ///
  /// In en, this message translates to:
  /// **'Product variant'**
  String get productVariant;

  /// No description provided for @promptKey.
  ///
  /// In en, this message translates to:
  /// **'Prompt key'**
  String get promptKey;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @providerCode.
  ///
  /// In en, this message translates to:
  /// **'Provider code'**
  String get providerCode;

  /// No description provided for @providerCount.
  ///
  /// In en, this message translates to:
  /// **'Provider count'**
  String get providerCount;

  /// No description provided for @providerCoverage.
  ///
  /// In en, this message translates to:
  /// **'Provider coverage'**
  String get providerCoverage;

  /// No description provided for @providerKey.
  ///
  /// In en, this message translates to:
  /// **'Provider key'**
  String get providerKey;

  /// No description provided for @providerMessageId.
  ///
  /// In en, this message translates to:
  /// **'Provider message ID'**
  String get providerMessageId;

  /// No description provided for @providers.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get providers;

  /// No description provided for @publicKey.
  ///
  /// In en, this message translates to:
  /// **'Public key'**
  String get publicKey;

  /// No description provided for @publishCampaign.
  ///
  /// In en, this message translates to:
  /// **'Publish campaign'**
  String get publishCampaign;

  /// No description provided for @publishCampaignMessage.
  ///
  /// In en, this message translates to:
  /// **'Publish this campaign now?'**
  String get publishCampaignMessage;

  /// No description provided for @publishTemplate.
  ///
  /// In en, this message translates to:
  /// **'Publish template'**
  String get publishTemplate;

  /// No description provided for @publishTemplateMessage.
  ///
  /// In en, this message translates to:
  /// **'Publish this template to stores?'**
  String get publishTemplateMessage;

  /// No description provided for @questionTooLong.
  ///
  /// In en, this message translates to:
  /// **'Your question is too long (1000 characters max).'**
  String get questionTooLong;

  /// No description provided for @queuedAt.
  ///
  /// In en, this message translates to:
  /// **'Queued at'**
  String get queuedAt;

  /// No description provided for @recheckComplete.
  ///
  /// In en, this message translates to:
  /// **'Re-check complete'**
  String get recheckComplete;

  /// No description provided for @recheckIntegration.
  ///
  /// In en, this message translates to:
  /// **'Re-check integration'**
  String get recheckIntegration;

  /// No description provided for @recheckIntegrationMessage.
  ///
  /// In en, this message translates to:
  /// **'Re-check this integration now?'**
  String get recheckIntegrationMessage;

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipient;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @refundAmount.
  ///
  /// In en, this message translates to:
  /// **'Refund amount'**
  String get refundAmount;

  /// No description provided for @refundPayment.
  ///
  /// In en, this message translates to:
  /// **'Refund payment'**
  String get refundPayment;

  /// No description provided for @refundReason.
  ///
  /// In en, this message translates to:
  /// **'Refund reason'**
  String get refundReason;

  /// No description provided for @refundSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Refund submitted'**
  String get refundSubmitted;

  /// No description provided for @rejectAiActionMessage.
  ///
  /// In en, this message translates to:
  /// **'Reject this AI action?'**
  String get rejectAiActionMessage;

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get removed;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @restoreTemplate.
  ///
  /// In en, this message translates to:
  /// **'Restore template'**
  String get restoreTemplate;

  /// No description provided for @restoreTemplateMessage.
  ///
  /// In en, this message translates to:
  /// **'Restore this template\'s default copy?'**
  String get restoreTemplateMessage;

  /// No description provided for @retryDelivery.
  ///
  /// In en, this message translates to:
  /// **'Retry delivery'**
  String get retryDelivery;

  /// No description provided for @retryDeliveryMessage.
  ///
  /// In en, this message translates to:
  /// **'Retry delivering this message?'**
  String get retryDeliveryMessage;

  /// No description provided for @revokeConnectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Revoke this connection? The store will stop using it.'**
  String get revokeConnectionMessage;

  /// No description provided for @rotateCredential.
  ///
  /// In en, this message translates to:
  /// **'Rotate credential'**
  String get rotateCredential;

  /// No description provided for @routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routes;

  /// No description provided for @rule.
  ///
  /// In en, this message translates to:
  /// **'Rule'**
  String get rule;

  /// No description provided for @sandbox.
  ///
  /// In en, this message translates to:
  /// **'Sandbox'**
  String get sandbox;

  /// No description provided for @scheduleCampaign.
  ///
  /// In en, this message translates to:
  /// **'Schedule campaign'**
  String get scheduleCampaign;

  /// No description provided for @scheduledAt.
  ///
  /// In en, this message translates to:
  /// **'Scheduled at'**
  String get scheduledAt;

  /// No description provided for @secretKey.
  ///
  /// In en, this message translates to:
  /// **'Secret key'**
  String get secretKey;

  /// No description provided for @seedAiTasks.
  ///
  /// In en, this message translates to:
  /// **'Seed AI tasks'**
  String get seedAiTasks;

  /// No description provided for @seedAiTasksMessage.
  ///
  /// In en, this message translates to:
  /// **'Create the missing default AI tasks?'**
  String get seedAiTasksMessage;

  /// No description provided for @selectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select period'**
  String get selectPeriod;

  /// No description provided for @sendTestEmail.
  ///
  /// In en, this message translates to:
  /// **'Send test email'**
  String get sendTestEmail;

  /// No description provided for @sentAt.
  ///
  /// In en, this message translates to:
  /// **'Sent at'**
  String get sentAt;

  /// No description provided for @signatureValid.
  ///
  /// In en, this message translates to:
  /// **'Signature valid'**
  String get signatureValid;

  /// No description provided for @stockTransferred.
  ///
  /// In en, this message translates to:
  /// **'Stock transferred'**
  String get stockTransferred;

  /// No description provided for @subjectAr.
  ///
  /// In en, this message translates to:
  /// **'Subject (Arabic)'**
  String get subjectAr;

  /// No description provided for @subjectEn.
  ///
  /// In en, this message translates to:
  /// **'Subject (English)'**
  String get subjectEn;

  /// No description provided for @submitForApprovalMessage.
  ///
  /// In en, this message translates to:
  /// **'Submit for approval?'**
  String get submitForApprovalMessage;

  /// No description provided for @suspendTenantMessage.
  ///
  /// In en, this message translates to:
  /// **'Suspend this tenant?'**
  String get suspendTenantMessage;

  /// No description provided for @syncPayment.
  ///
  /// In en, this message translates to:
  /// **'Sync payment'**
  String get syncPayment;

  /// No description provided for @taskKey.
  ///
  /// In en, this message translates to:
  /// **'Task key'**
  String get taskKey;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @template.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get template;

  /// No description provided for @templateActionsHint.
  ///
  /// In en, this message translates to:
  /// **'A JSON array of actions, for example the send_notification type.'**
  String get templateActionsHint;

  /// No description provided for @templateCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'One of the template categories the server defines.'**
  String get templateCategoryHint;

  /// No description provided for @templateCustomized.
  ///
  /// In en, this message translates to:
  /// **'Template customised'**
  String get templateCustomized;

  /// No description provided for @templateKey.
  ///
  /// In en, this message translates to:
  /// **'Template key'**
  String get templateKey;

  /// No description provided for @templateKeyHint.
  ///
  /// In en, this message translates to:
  /// **'A unique lowercase identifier with dashes.'**
  String get templateKeyHint;

  /// No description provided for @templateTriggerHint.
  ///
  /// In en, this message translates to:
  /// **'A trigger from the automation trigger list.'**
  String get templateTriggerHint;

  /// No description provided for @timeoutSeconds.
  ///
  /// In en, this message translates to:
  /// **'Timeout (seconds)'**
  String get timeoutSeconds;

  /// No description provided for @toStore.
  ///
  /// In en, this message translates to:
  /// **'To store'**
  String get toStore;

  /// No description provided for @toggleCountry.
  ///
  /// In en, this message translates to:
  /// **'Toggle country'**
  String get toggleCountry;

  /// No description provided for @toggleCountryMessage.
  ///
  /// In en, this message translates to:
  /// **'Change whether this country is active?'**
  String get toggleCountryMessage;

  /// No description provided for @toggleMethod.
  ///
  /// In en, this message translates to:
  /// **'Toggle method'**
  String get toggleMethod;

  /// No description provided for @toggleMethodMessage.
  ///
  /// In en, this message translates to:
  /// **'Change whether this payment method is active?'**
  String get toggleMethodMessage;

  /// No description provided for @tokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get tokens;

  /// No description provided for @transferNeedsTwoStores.
  ///
  /// In en, this message translates to:
  /// **'Two stores are required'**
  String get transferNeedsTwoStores;

  /// No description provided for @transferNeedsTwoStoresMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a second store before transferring stock between stores.'**
  String get transferNeedsTwoStoresMessage;

  /// No description provided for @transferStock.
  ///
  /// In en, this message translates to:
  /// **'Transfer stock'**
  String get transferStock;

  /// No description provided for @transferStockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Move this quantity between the two stores?'**
  String get transferStockConfirm;

  /// No description provided for @unprocessedEvents.
  ///
  /// In en, this message translates to:
  /// **'Unprocessed events'**
  String get unprocessedEvents;

  /// No description provided for @unregisteredProviders.
  ///
  /// In en, this message translates to:
  /// **'Unregistered providers'**
  String get unregisteredProviders;

  /// No description provided for @variables.
  ///
  /// In en, this message translates to:
  /// **'Variables'**
  String get variables;

  /// No description provided for @verifyAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Verify this account?'**
  String get verifyAccountMessage;

  /// No description provided for @verifyConnection.
  ///
  /// In en, this message translates to:
  /// **'Verify connection'**
  String get verifyConnection;

  /// No description provided for @versions.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get versions;

  /// No description provided for @webhookDocsUrl.
  ///
  /// In en, this message translates to:
  /// **'Webhook documentation URL'**
  String get webhookDocsUrl;

  /// No description provided for @webhookEvents.
  ///
  /// In en, this message translates to:
  /// **'Webhook events'**
  String get webhookEvents;

  /// No description provided for @webhookSecret.
  ///
  /// In en, this message translates to:
  /// **'Webhook secret'**
  String get webhookSecret;

  /// No description provided for @yourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Your question'**
  String get yourQuestion;
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
      'that was used.');
}
