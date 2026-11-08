import 'package:dukavo_mobile/core/providers.dart';
import 'package:dukavo_mobile/core/storage/app_preferences.dart';
import 'package:dukavo_mobile/core/widgets/app_widgets.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/auth/domain/auth_domain.dart';
import 'package:dukavo_mobile/features/auth/presentation/register_screen.dart';
import 'package:dukavo_mobile/features/marketing/application/marketing_providers.dart';
import 'package:dukavo_mobile/features/marketing/domain/marketing_models.dart';
import 'package:dukavo_mobile/features/marketing/presentation/public_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/test_app.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Session?> restoreSession() async => null;

  @override
  Future<Session> login({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> clearLocalSession() async {}

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<Session> switchTenant(String slug) => throw UnimplementedError();

  @override
  Future<Session> provisionTenant({
    required String name,
    String? storeName,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {}
}

class _TestAuthController extends AuthController {
  _TestAuthController()
      : super(_FakeAuthRepository(), autoBootstrap: false);

  void signedOut() => state = const AuthState(status: AuthStatus.unauthenticated);
}

const _features = <MarketingFeature>[
  MarketingFeature(
    slug: 'orders',
    name: 'Orders',
    description: 'Every order has a clear status.',
    status: 'available',
  ),
  MarketingFeature(
    slug: 'inventory',
    name: 'Inventory',
    description: 'Stock updates with every sale.',
    status: 'available',
  ),
  MarketingFeature(
    slug: 'ai-copilot',
    name: 'AI copilot',
    description: 'A grounded reply for every conversation.',
    status: 'coming_soon',
  ),
];

const _plans = <PricingPlan>[
  PricingPlan(
    id: 1,
    name: 'Starter',
    slug: 'starter',
    description: 'For a first store.',
    price: 0,
    currency: 'USD',
    billingInterval: 'month',
    billingIntervalLabel: 'per month',
    purchaseAvailable: true,
    highlighted: false,
    features: ['Products', 'Orders'],
    limits: ['One store'],
  ),
  PricingPlan(
    id: 2,
    name: 'Growth',
    slug: 'growth',
    description: 'For a growing team.',
    price: 49,
    currency: 'USD',
    billingInterval: 'month',
    billingIntervalLabel: 'per month',
    purchaseAvailable: true,
    highlighted: true,
    features: ['Everything in Starter', 'Team roles'],
    limits: [],
  ),
];

const _faq = <FaqEntry>[
  FaqEntry(
    id: 1,
    question: 'How do I join?',
    answer: 'Join the waitlist and we will send an invitation.',
    category: 'Onboarding',
  ),
];

const _articles = <Newsletter>[
  Newsletter(
    id: 1,
    slug: 'welcome',
    title: 'A calmer way to run orders',
    excerpt: 'Notes from the Dukavo team.',
    coverImageUrl: null,
    readingMinutes: 3,
    publishedAt: null,
    locale: 'en',
    body: '<h2>Start with the inbox</h2><p>Every order begins as a message.</p>',
  ),
];

void main() {
  late AppPreferences preferences;
  late _TestAuthController controller;

  setUpAll(() async {
    await preloadLocalizations();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = AppPreferences(await SharedPreferences.getInstance());
    controller = _TestAuthController()..signedOut();
  });

  List<Override> publicOverrides() => [
        appPreferencesProvider.overrideWithValue(preferences),
        authControllerProvider.overrideWith((ref) => controller),
        marketingFeaturesProvider.overrideWith((ref) => _features),
        marketingPricingProvider.overrideWith((ref) => _plans),
        marketingFaqProvider.overrideWith((ref) => _faq),
        marketingNewslettersProvider.overrideWith((ref) => _articles),
      ];

  Future<void> pumpPublic(
    WidgetTester tester,
    Widget screen, {
    Locale locale = const Locale('en'),
    List<Override> extra = const <Override>[],
  }) {
    return pumpTestApp(
      tester,
      Scaffold(body: screen),
      locale: locale,
      overrides: [...publicOverrides(), ...extra],
    );
  }

  testWidgets('home renders its hero, API features, pricing and FAQ',
      (tester) async {
    await pumpPublic(tester, const PublicHomeScreen());

    expect(
      find.text('Run your whole store from one place', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Join the waitlist'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Every order has a clear status.'), findsOneWidget);
    expect(find.text('Starter'), findsOneWidget);
    expect(find.text('How do I join?'), findsOneWidget);
    expect(find.text('A calmer way to run orders'), findsOneWidget);
  });

  testWidgets('home renders Arabic copy without hardcoded English',
      (tester) async {
    await pumpPublic(
      tester,
      const PublicHomeScreen(),
      locale: const Locale('ar'),
    );

    expect(
      find.text('أدر متجرك بالكامل من مكان واحد', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('انضم لقائمة الانتظار'), findsWidgets);
  });

  testWidgets('features separates available capabilities from upcoming ones',
      (tester) async {
    await pumpPublic(tester, const PublicFeaturesScreen());

    expect(find.text('Available now'), findsOneWidget);
    expect(find.text('Coming soon'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('AI copilot'), findsOneWidget);
  });

  testWidgets('pricing shows every published plan and the pricing FAQ',
      (tester) async {
    await pumpPublic(tester, const PublicPricingScreen());

    expect(find.text('Starter'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('How do I join?'), findsOneWidget);
  });

  testWidgets('FAQ expands an API entry', (tester) async {
    await pumpPublic(tester, const PublicFaqScreen());

    expect(find.text('How do I join?'), findsOneWidget);
    expect(
      find.text('Join the waitlist and we will send an invitation.'),
      findsNothing,
    );

    await tester.tap(find.text('How do I join?'));
    await tester.pumpAndSettle();

    expect(
      find.text('Join the waitlist and we will send an invitation.'),
      findsOneWidget,
    );
  });

  testWidgets('contact validates before it reaches the API', (tester) async {
    await pumpPublic(tester, const PublicContactScreen());

    final send = find.widgetWithText(AppButton, 'Send');
    await tester.scrollUntilVisible(
      send,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(send);
    await tester.pumpAndSettle();

    expect(find.text('This field is required.'), findsNWidgets(4));
  });

  testWidgets('waitlist validates the email before submitting',
      (tester) async {
    await pumpPublic(tester, const PublicWaitlistScreen());

    final submit = find.widgetWithText(AppButton, 'Join the waitlist').last;
    await tester.scrollUntilVisible(
      submit,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('This field is required.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'not-an-email',
    );
    await tester.scrollUntilVisible(
      submit,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('blog detail renders sanitized newsletter HTML', (tester) async {
    await pumpPublic(
      tester,
      const PublicBlogArticleScreen(slug: 'welcome'),
      extra: [
        marketingNewsletterProvider('welcome')
            .overrideWith((ref) => _articles.single),
      ],
    );

    expect(find.text('A calmer way to run orders'), findsOneWidget);
    expect(
      find.text('Start with the inbox', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text('Every order begins as a message.', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('register explains the invite-only path instead of a form',
      (tester) async {
    await pumpPublic(tester, const RegisterScreen());

    expect(find.text('Invite only'), findsOneWidget);
    expect(find.text('Get an invitation'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Join the waitlist'), findsWidgets);
  });
}
