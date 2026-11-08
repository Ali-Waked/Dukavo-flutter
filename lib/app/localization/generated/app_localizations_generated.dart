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
  /// **'Converting rewrites current product, variant and bundle prices. Historical orders keep their original currency.'**
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
