import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/marketing_providers.dart';
import '../domain/marketing_models.dart';

/// The public site chrome.
///
/// Marketing pages are readable without a session, so this shell never asks the
/// auth controller who is signed in. A signed-in merchant can still open it
/// from the "about Dukavo" link in the account menu.
class MarketingSiteShell extends StatelessWidget {
  const MarketingSiteShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  static const _tabs = <_SiteTab>[
    _SiteTab('/site', 'home', Icons.home_outlined, Icons.home),
    _SiteTab('/site/pricing', 'pricing', Icons.sell_outlined, Icons.sell),
    _SiteTab('/site/faq', 'faq', Icons.help_outline, Icons.help),
    _SiteTab(
      '/site/newsletter',
      'newsletter',
      Icons.newspaper_outlined,
      Icons.newspaper,
    ),
  ];

  int get _index {
    if (location.startsWith('/site/pricing')) return 1;
    if (location.startsWith('/site/faq')) return 2;
    if (location.startsWith('/site/newsletter')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(size: 26, showWordmark: true),
        actions: [
          IconButton(
            tooltip: context.tr('contactUs'),
            onPressed: () => context.push(RoutePaths.siteContact),
            icon: const Icon(Icons.mail_outline),
          ),
          IconButton(
            tooltip: context.tr('joinWaitlist'),
            onPressed: () => context.push(RoutePaths.siteWaitlist),
            icon: const Icon(Icons.hourglass_empty),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          final target = _tabs[index];
          if (location != target.path) context.go(target.path);
        },
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: context.tr(tab.labelKey),
            ),
        ],
      ),
    );
  }
}

class _SiteTab {
  const _SiteTab(this.path, this.labelKey, this.icon, this.selectedIcon);

  final String path;
  final String labelKey;
  final IconData icon;
  final IconData selectedIcon;
}

class SiteHomeScreen extends ConsumerWidget {
  const SiteHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(marketingFeaturesProvider);
    final pricing = ref.watch(marketingPricingProvider);
    final newsletters = ref.watch(marketingNewslettersProvider);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(marketingFeaturesProvider);
        ref.invalidate(marketingPricingProvider);
        ref.invalidate(marketingNewslettersProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  theme.colorScheme.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('appName'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('appTagline'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr('siteHeroSubtitle'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                      ),
                      onPressed: () => context.go(RoutePaths.sitePricing),
                      child: Text(context.tr('seePricing')),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      onPressed: () => context.push(RoutePaths.siteWaitlist),
                      child: Text(context.tr('joinWaitlist')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeading(
            title: context.tr('features'),
            actionLabel: context.tr('viewAll'),
            onAction: () => context.push(RoutePaths.siteFeatures),
          ),
          const SizedBox(height: 10),
          features.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: LoadingView(),
            ),
            error: (error, stack) => ErrorView(
              message: _message(context, error),
              onRetry: () => ref.invalidate(marketingFeaturesProvider),
            ),
            data: (items) => Column(
              children: [
                for (final feature in items.take(4))
                  _FeatureTile(feature: feature),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeading(
            title: context.tr('pricing'),
            actionLabel: context.tr('viewAll'),
            onAction: () => context.go(RoutePaths.sitePricing),
          ),
          const SizedBox(height: 10),
          pricing.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: LoadingView(),
            ),
            error: (error, stack) => ErrorView(
              message: _message(context, error),
              onRetry: () => ref.invalidate(marketingPricingProvider),
            ),
            data: (plans) {
              if (plans.isEmpty) {
                return EmptyState(
                  title: context.tr('noPricingPlans'),
                  icon: Icons.sell_outlined,
                );
              }
              return SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: plans.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: 240,
                    child: _PlanCard(plan: plans[index], compact: true),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _SectionHeading(
            title: context.tr('newsletter'),
            actionLabel: context.tr('viewAll'),
            onAction: () => context.go(RoutePaths.siteNewsletter),
          ),
          const SizedBox(height: 10),
          newsletters.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: LoadingView(),
            ),
            error: (error, stack) => ErrorView(
              message: _message(context, error),
              onRetry: () => ref.invalidate(marketingNewslettersProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return EmptyState(
                  title: context.tr('noNewsletters'),
                  icon: Icons.newspaper_outlined,
                );
              }
              return Column(
                children: [
                  for (final article in items.take(3))
                    _ArticleTile(article: article),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: context.tr('company'),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline),
                  title: Text(context.tr('aboutUs')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(RoutePaths.sitePage('about')),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(context.tr('privacyPolicy')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(RoutePaths.sitePage('privacy')),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description_outlined),
                  title: Text(context.tr('termsOfService')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(RoutePaths.sitePage('terms')),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.mail_outline),
                  title: Text(context.tr('contactUs')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(RoutePaths.siteContact),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SiteFeaturesScreen extends ConsumerWidget {
  const SiteFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(marketingFeaturesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('features'))),
      body: features.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: _message(context, error),
          onRetry: () => ref.invalidate(marketingFeaturesProvider),
        ),
        data: (items) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            if (items.isEmpty)
              EmptyState(
                title: context.tr('noFeatures'),
                icon: Icons.auto_awesome_outlined,
              )
            else
              for (final feature in items) _FeatureTile(feature: feature),
          ],
        ),
      ),
    );
  }
}

class SitePricingScreen extends ConsumerWidget {
  const SitePricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricing = ref.watch(marketingPricingProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(marketingPricingProvider),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            context.tr('pricingSubtitle'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 14),
          pricing.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: LoadingView(),
            ),
            error: (error, stack) => ErrorView(
              message: _message(context, error),
              onRetry: () => ref.invalidate(marketingPricingProvider),
            ),
            data: (plans) => plans.isEmpty
                ? EmptyState(
                    title: context.tr('noPricingPlans'),
                    icon: Icons.sell_outlined,
                  )
                : Column(
                    children: [
                      for (final plan in plans)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PlanCard(plan: plan),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class SiteFaqScreen extends ConsumerWidget {
  const SiteFaqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faq = ref.watch(marketingFaqProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(marketingFaqProvider),
      child: faq.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: _message(context, error),
          onRetry: () => ref.invalidate(marketingFaqProvider),
        ),
        data: (entries) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            if (entries.isEmpty)
              EmptyState(
                title: context.tr('noFaqEntries'),
                icon: Icons.help_outline,
              )
            else
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final entry in entries)
                      ExpansionTile(
                        title: Text(entry.question),
                        subtitle: entry.category == null
                            ? null
                            : Text(entry.category!),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.answer,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SectionCard(
              title: context.tr('stillHaveQuestions'),
              child: AppButton(
                label: context.tr('contactUs'),
                icon: Icons.mail_outline,
                expand: true,
                onPressed: () => context.push(RoutePaths.siteContact),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SiteNewsletterScreen extends ConsumerStatefulWidget {
  const SiteNewsletterScreen({super.key});

  @override
  ConsumerState<SiteNewsletterScreen> createState() =>
      _SiteNewsletterScreenState();
}

class _SiteNewsletterScreenState extends ConsumerState<SiteNewsletterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(newsletterFeedProvider).items.isEmpty) {
        ref.read(newsletterFeedProvider.notifier).loadInitial();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsletterFeedProvider);
    final notifier = ref.read(newsletterFeedProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SectionCard(
            title: context.tr('subscribeToNewsletter'),
            subtitle: context.tr('subscribeToNewsletterHint'),
            child: AppButton(
              label: context.tr('subscribe'),
              icon: Icons.mark_email_read_outlined,
              expand: true,
              onPressed: () => _subscribe(context, ref),
            ),
          ),
        ),
        Expanded(
          child: PagedListView<Newsletter>(
            state: state,
            onRefresh: notifier.reload,
            onLoadMore: notifier.loadMore,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            empty: EmptyState(
              title: context.tr('noNewsletters'),
              icon: Icons.newspaper_outlined,
            ),
            itemBuilder: (context, article, index) =>
                _ArticleTile(article: article),
          ),
        ),
      ],
    );
  }

  Future<void> _subscribe(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('subscribeToNewsletter')),
        content: Form(
          key: formKey,
          child: AppTextField(
            controller: controller,
            label: context.tr('email'),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (value) => _emailError(context, value),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.of(dialogContext).pop(controller.text.trim());
            },
            child: Text(context.tr('subscribe')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (email == null || email.isEmpty) return;
    try {
      await ref
          .read(marketingActionsProvider)
          .subscribe(email, source: 'mobile_site');
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('subscribed'));
    } catch (error) {
      if (!context.mounted) return;
      AppSnack.show(context, _message(context, error), isError: true);
    }
  }
}

class SiteNewsletterArticleScreen extends ConsumerWidget {
  const SiteNewsletterArticleScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.watch(marketingNewsletterProvider(slug));
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('newsletter'))),
      body: article.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: _message(context, error),
          onRetry: () => ref.invalidate(marketingNewsletterProvider(slug)),
        ),
        data: (item) => Directionality(
          textDirection:
              item.isArabic ? TextDirection.rtl : Directionality.of(context),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              if (item.coverImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: item.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                item.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                [
                  if (item.publishedAt != null)
                    Formatters.date(item.publishedAt),
                  context.tr('readingMinutes',
                      args: {'count': item.readingMinutes}),
                ].join(' · '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                item.body?.isNotEmpty == true ? item.body! : item.excerpt,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SiteContactScreen extends ConsumerStatefulWidget {
  const SiteContactScreen({super.key});

  @override
  ConsumerState<SiteContactScreen> createState() => _SiteContactScreenState();
}

class _SiteContactScreenState extends ConsumerState<SiteContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _body = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('contactUs'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (_sent)
            SectionCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 42,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.tr('messageSent'),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('messageSentHint'),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    label: context.tr('sendAnotherMessage'),
                    variant: AppButtonVariant.outlined,
                    expand: true,
                    onPressed: () {
                      setState(() => _sent = false);
                      _subject.clear();
                      _body.clear();
                    },
                  ),
                ],
              ),
            )
          else
            Form(
              key: _formKey,
              child: SectionCard(
                title: context.tr('contactUs'),
                subtitle: context.tr('contactUsHint'),
                child: Column(
                  children: [
                    AppTextField(
                      controller: _name,
                      label: context.tr('name'),
                      textInputAction: TextInputAction.next,
                      validator: (value) => _requiredError(context, value),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _email,
                      label: context.tr('email'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) => _emailError(context, value),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _subject,
                      label: context.tr('subject'),
                      textInputAction: TextInputAction.next,
                      validator: (value) => _requiredError(context, value),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _body,
                      label: context.tr('message'),
                      maxLines: 6,
                      minLines: 4,
                      validator: (value) => _requiredError(context, value),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: context.tr('send'),
                      icon: Icons.send_outlined,
                      expand: true,
                      loading: _sending,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _sending = true);
    try {
      await ref.read(marketingActionsProvider).contact(
            name: _name.text.trim(),
            email: _email.text.trim(),
            subject: _subject.text.trim(),
            message: _body.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sent = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnack.show(context, _message(context, error), isError: true);
    }
  }
}

class SiteWaitlistScreen extends ConsumerStatefulWidget {
  const SiteWaitlistScreen({super.key});

  @override
  ConsumerState<SiteWaitlistScreen> createState() => _SiteWaitlistScreenState();
}

class _SiteWaitlistScreenState extends ConsumerState<SiteWaitlistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _businessType = TextEditingController();
  bool _sending = false;
  bool _joined = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _businessType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('joinWaitlist'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (_joined)
            SectionCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 42,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.tr('waitlistJoined'),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('waitlistJoinedHint'),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Form(
              key: _formKey,
              child: SectionCard(
                title: context.tr('joinWaitlist'),
                subtitle: context.tr('waitlistHint'),
                child: Column(
                  children: [
                    AppTextField(
                      controller: _email,
                      label: context.tr('email'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) => _emailError(context, value),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _name,
                      label: context.tr('name'),
                      helper: context.tr('optional'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _businessType,
                      label: context.tr('businessType'),
                      helper: context.tr('optional'),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: context.tr('joinWaitlist'),
                      icon: Icons.hourglass_empty,
                      expand: true,
                      loading: _sending,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _sending = true);
    try {
      await ref.read(marketingActionsProvider).joinWaitlist(
            email: _email.text.trim(),
            name: _name.text.trim(),
            businessType: _businessType.text.trim(),
            source: 'mobile_site',
          );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _joined = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnack.show(context, _message(context, error), isError: true);
    }
  }
}

class SitePageScreen extends ConsumerWidget {
  const SitePageScreen({super.key, required this.pageKey});

  final String pageKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(contentPageProvider(pageKey));
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('information'))),
      body: page.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: _message(context, error),
          onRetry: () => ref.invalidate(contentPageProvider(pageKey)),
        ),
        data: (document) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              document.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (document.intro.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                document.intro,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.55,
                    ),
              ),
            ],
            const SizedBox(height: 18),
            for (final section in document.sections) ...[
              if (section.title.isNotEmpty) ...[
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
              ],
              Text(
                section.body,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.6),
              ),
              const SizedBox(height: 16),
            ],
            if (document.publishedAt != null)
              Text(
                context.tr('lastUpdated', args: {
                  'date': Formatters.date(document.publishedAt),
                }),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});

  final MarketingFeature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = feature.isAvailable;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: available
                    ? AppColors.tint(theme.colorScheme.primary)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                available
                    ? Icons.check_circle_outline
                    : Icons.schedule_outlined,
                size: 20,
                color: available
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          feature.name,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (!available)
                        StatusChip(
                          status: 'coming_soon',
                          label: context.tr('comingSoon'),
                          compact: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, this.compact = false});

  final PricingPlan plan;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = plan.price;
    final priceLabel = price == null
        ? context.tr('pricingComingSoon')
        : price == 0
            ? context.tr('free')
            : Formatters.currency(price, plan.currency);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: plan.highlighted
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          width: plan.highlighted ? 1.6 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (plan.highlighted)
                  StatusChip(
                    status: 'active',
                    label: context.tr('recommended'),
                    compact: true,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              priceLabel,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (price != null && price > 0)
              Text(
                plan.billingIntervalLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (plan.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(plan.description, style: theme.textTheme.bodySmall),
            ],
            if (!compact) ...[
              const SizedBox(height: 12),
              for (final feature in plan.features)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              if (plan.limits.isNotEmpty) ...[
                const SizedBox(height: 6),
                for (final limit in plan.limits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.remove,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            limit,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              AppButton(
                label: plan.purchaseAvailable
                    ? context.tr('getStarted')
                    : context.tr('joinWaitlist'),
                expand: true,
                onPressed: () {
                  if (plan.purchaseAvailable) {
                    context.push(RoutePaths.login);
                  } else {
                    context.push(RoutePaths.siteWaitlist);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article});

  final Newsletter article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Arabic articles keep their natural RTL direction even when the app UI is
    // in English. Text in other scripts follows the ambient direction.
    final textDirection =
        article.isArabic ? TextDirection.rtl : Directionality.of(context);
    return Directionality(
      textDirection: textDirection,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.push(RoutePaths.siteNewsletterArticle(article.slug)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (article.coverImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: CachedNetworkImage(
                        imageUrl: article.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.newspaper_outlined, size: 20),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.newspaper_outlined),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (article.publishedAt != null)
                            Formatters.date(article.publishedAt),
                          context.tr(
                            'readingMinutes',
                            args: {'count': article.readingMinutes},
                          ),
                        ].join(' · '),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

String _message(BuildContext context, Object error) =>
    error is ApiException ? error.message : context.tr('errorGeneric');

String? _requiredError(BuildContext context, String? value) {
  if (value == null || value.trim().isEmpty) {
    return context.tr('requiredField');
  }
  return null;
}

String? _emailError(BuildContext context, String? value) {
  final required = _requiredError(context, value);
  if (required != null) return required;
  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!pattern.hasMatch(value!.trim())) return context.tr('invalidEmail');
  return null;
}
