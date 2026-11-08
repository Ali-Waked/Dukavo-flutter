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
import 'public_content.dart';
import 'public_widgets.dart';

const _sectionGap = SizedBox(height: 28);

/* ------------------------------------------------------------------- home */

class PublicHomeScreen extends ConsumerWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(marketingFeaturesProvider);
    final pricing = ref.watch(marketingPricingProvider);
    final faq = ref.watch(marketingFaqProvider);
    final newsletters = ref.watch(marketingNewslettersProvider);

    Future<void> refresh() async {
      ref.invalidate(marketingFeaturesProvider);
      ref.invalidate(marketingPricingProvider);
      ref.invalidate(marketingFaqProvider);
      ref.invalidate(marketingNewslettersProvider);
    }

    final title = [
      context.tr('publicHomeTitleLine1'),
      context.tr('publicHomeTitleFrom'),
      context.tr('publicHomeTitleAccent'),
    ].join(' ');

    return PublicScrollView(
      onRefresh: refresh,
      children: [
        PublicHero(
          badge: context.tr('publicHomeBadge'),
          title: title,
          accent: context.tr('publicHomeTitleAccent'),
          subtitle: context.tr('publicHomeSubtitle'),
          primaryLabel: context.tr('publicHomePrimary'),
          primaryIcon: Icons.hourglass_empty,
          onPrimary: () => context.push(RoutePaths.waitlist),
          secondaryLabel: context.tr('publicHomeSecondary'),
          onSecondary: () => context.push(RoutePaths.publicHowItWorks),
          ticks: [
            context.tr('publicHomeTickArabic'),
            context.tr('publicHomeTickWhatsapp'),
            context.tr('publicHomeTickTeam'),
          ],
        ),
        const SizedBox(height: 16),
        const _EcosystemCard(),
        _sectionGap,
        PublicSectionHeader(
          eyebrow: context.tr('publicHomePillarsEyebrow'),
          title: context.tr('publicHomePillarsTitle'),
          subtitle: context.tr('publicHomePillarsSubtitle'),
          actionLabel: context.tr('viewAll'),
          onAction: () => context.push(RoutePaths.publicFeatures),
        ),
        const SizedBox(height: 12),
        features.when(
          loading: () => const PublicLoadingCard(height: 260),
          error: (error, stack) => PublicErrorCard(
            message: publicErrorMessage(context, error),
            onRetry: () => ref.invalidate(marketingFeaturesProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return PublicNoteCard(
                icon: Icons.auto_awesome_outlined,
                title: context.tr('features'),
                body: context.tr('publicFeaturesEmpty'),
              );
            }
            return Column(
              children: [
                for (final feature in items.take(6)) ...[
                  PublicFeatureCard(feature: feature),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
        _sectionGap,
        const _StepsSection(compact: true),
        _sectionGap,
        PublicSectionHeader(
          eyebrow: context.tr('publicHomePricingEyebrow'),
          title: context.tr('publicHomePricingTitle'),
          subtitle: context.tr('publicHomePricingSubtitle'),
          actionLabel: context.tr('viewAll'),
          onAction: () => context.push(RoutePaths.publicPricing),
        ),
        const SizedBox(height: 12),
        pricing.when(
          loading: () => const PublicLoadingCard(),
          error: (error, stack) => PublicErrorCard(
            message: publicErrorMessage(context, error),
            onRetry: () => ref.invalidate(marketingPricingProvider),
          ),
          data: (plans) {
            if (plans.isEmpty) {
              return PublicNoteCard(
                icon: Icons.sell_outlined,
                title: context.tr('pricing'),
                body: context.tr('noPricingPlans'),
              );
            }
            return Column(
              children: [
                for (final plan in plans.take(3)) ...[
                  _MiniPlanCard(plan: plan),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
        _sectionGap,
        PublicSectionHeader(
          eyebrow: context.tr('publicHomeFaqEyebrow'),
          title: context.tr('publicHomeFaqTitle'),
          actionLabel: context.tr('viewAll'),
          onAction: () => context.push(RoutePaths.publicFaq),
        ),
        const SizedBox(height: 12),
        faq.when(
          loading: () => const PublicLoadingCard(height: 140),
          error: (error, stack) => PublicErrorCard(
            message: publicErrorMessage(context, error),
            onRetry: () => ref.invalidate(marketingFaqProvider),
          ),
          data: (entries) => entries.isEmpty
              ? PublicNoteCard(
                  icon: Icons.help_outline,
                  title: context.tr('faqEntries'),
                  body: context.tr('noFaqEntries'),
                )
              : _FaqList(entries: entries.take(4).toList()),
        ),
        _sectionGap,
        PublicSectionHeader(
          eyebrow: context.tr('publicHomeBlogEyebrow'),
          title: context.tr('publicHomeBlogTitle'),
          actionLabel: context.tr('viewAll'),
          onAction: () => context.push(RoutePaths.publicBlog),
        ),
        const SizedBox(height: 12),
        newsletters.when(
          loading: () => const PublicLoadingCard(height: 140),
          error: (error, stack) => PublicErrorCard(
            message: publicErrorMessage(context, error),
            onRetry: () => ref.invalidate(marketingNewslettersProvider),
          ),
          data: (items) => items.isEmpty
              ? PublicNoteCard(
                  icon: Icons.newspaper_outlined,
                  title: context.tr('publicNavBlog'),
                  body: context.tr('publicBlogEmptyBody'),
                )
              : Column(
                  children: [
                    for (final article in items.take(3)) ...[
                      PublicArticleCard(article: article),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
        ),
        _sectionGap,
        PublicCtaBand(
          title: context.tr('publicHomeCtaTitle'),
          body: context.tr('publicHomeCtaBody'),
          actionLabel: context.tr('publicHomeCtaAction'),
          onAction: () => context.push(RoutePaths.waitlist),
        ),
        const PublicFooter(),
      ],
    );
  }
}

class _EcosystemCard extends StatelessWidget {
  const _EcosystemCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labels = <(IconData, String)>[
      (Icons.inventory_2_outlined, context.tr('publicHomeEcosystemProducts')),
      (Icons.warehouse_outlined, context.tr('publicHomeEcosystemInventory')),
      (Icons.receipt_long_outlined, context.tr('publicHomeEcosystemOrders')),
      (Icons.people_outline, context.tr('publicHomeEcosystemCustomers')),
      (Icons.chat_bubble_outline, context.tr('publicHomeEcosystemConversations')),
      (Icons.groups_outlined, context.tr('publicHomeEcosystemTeam')),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('publicHomeEcosystemLabel').toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 560 ? 3 : 2;
              final width =
                  (constraints.maxWidth - (columns - 1) * 10) / columns;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final tile in labels)
                    SizedBox(
                      width: width,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.tint(scheme.primary),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(tile.$1, size: 20, color: scheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tile.$2,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MiniPlanCard extends StatelessWidget {
  const _MiniPlanCard({required this.plan});

  final PricingPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final price = plan.price;
    final priceLabel = price == null
        ? context.tr('pricingComingSoon')
        : price == 0
            ? context.tr('free')
            : Formatters.currency(price, plan.currency);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push(RoutePaths.publicPricing),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                plan.highlighted ? scheme.primary : scheme.outlineVariant,
            width: plan.highlighted ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          plan.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (plan.highlighted) ...[
                        const SizedBox(width: 8),
                        StatusChip(
                          status: 'active',
                          label: context.tr('recommended'),
                          compact: true,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priceLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (price != null && price > 0)
                    Text(
                      plan.billingIntervalLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

/* --------------------------------------------------------------- features */

class PublicFeaturesScreen extends ConsumerWidget {
  const PublicFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(marketingFeaturesProvider);

    return PublicDetailScaffold(
      embedded: true,
      title: context.tr('publicNavFeatures'),
      child: PublicScrollView(
        onRefresh: () async => ref.invalidate(marketingFeaturesProvider),
        children: [
          PublicHero(
            compact: true,
            badge: context.tr('publicNavFeatures'),
            title: context.tr('publicFeaturesTitle'),
            subtitle: context.tr('publicFeaturesSubtitle'),
            primaryLabel: context.tr('joinWaitlist'),
            primaryIcon: Icons.hourglass_empty,
            onPrimary: () => context.push(RoutePaths.waitlist),
          ),
          _sectionGap,
          features.when(
            loading: () => const PublicLoadingCard(height: 300),
            error: (error, stack) => PublicErrorCard(
              message: publicErrorMessage(context, error),
              onRetry: () => ref.invalidate(marketingFeaturesProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return PublicNoteCard(
                  icon: Icons.auto_awesome_outlined,
                  title: context.tr('features'),
                  body: context.tr('publicFeaturesEmpty'),
                );
              }
              final available =
                  items.where((feature) => feature.isAvailable).toList();
              final upcoming =
                  items.where((feature) => !feature.isAvailable).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (available.isNotEmpty) ...[
                    PublicSectionHeader(
                      title: context.tr('publicFeaturesAvailable'),
                      subtitle: context.tr('publicFeaturesAvailableHint'),
                    ),
                    const SizedBox(height: 10),
                    for (final feature in available) ...[
                      PublicFeatureCard(feature: feature, showStatus: false),
                      const SizedBox(height: 10),
                    ],
                  ],
                  if (upcoming.isNotEmpty) ...[
                    if (available.isNotEmpty) const SizedBox(height: 18),
                    PublicSectionHeader(
                      title: context.tr('publicFeaturesUpcoming'),
                      subtitle: context.tr('publicFeaturesUpcomingHint'),
                    ),
                    const SizedBox(height: 10),
                    for (final feature in upcoming) ...[
                      PublicFeatureCard(feature: feature),
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              );
            },
          ),
          _sectionGap,
          PublicCtaBand(
            title: context.tr('publicHowCtaTitle'),
            body: context.tr('publicHowCtaBody'),
            actionLabel: context.tr('joinWaitlist'),
            onAction: () => context.push(RoutePaths.waitlist),
          ),
          const PublicFooter(),
        ],
      ),
    );
  }
}

/* ---------------------------------------------------------------- pricing */

class PublicPricingScreen extends ConsumerWidget {
  const PublicPricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricing = ref.watch(marketingPricingProvider);
    final faq = ref.watch(marketingFaqProvider);

    return PublicDetailScaffold(
      embedded: true,
      title: context.tr('publicNavPricing'),
      child: PublicScrollView(
        onRefresh: () async {
          ref.invalidate(marketingPricingProvider);
          ref.invalidate(marketingFaqProvider);
        },
        children: [
          PublicHero(
            compact: true,
            badge: context.tr('publicNavPricing'),
            title: context.tr('publicPricingTitle'),
            subtitle: context.tr('publicPricingHeroSubtitle'),
            primaryLabel: context.tr('joinWaitlist'),
            primaryIcon: Icons.hourglass_empty,
            onPrimary: () => context.push(RoutePaths.waitlist),
          ),
          const SizedBox(height: 16),
          PublicNoteCard(
            icon: Icons.mail_outline,
            title: context.tr('publicPricingInviteTitle'),
            body: context.tr('publicPricingInviteBody'),
          ),
          const SizedBox(height: 20),
          pricing.when(
            loading: () => const PublicLoadingCard(height: 300),
            error: (error, stack) => PublicErrorCard(
              message: publicErrorMessage(context, error),
              onRetry: () => ref.invalidate(marketingPricingProvider),
            ),
            data: (plans) => plans.isEmpty
                ? EmptyState(
                    title: context.tr('noPricingPlans'),
                    icon: Icons.sell_outlined,
                  )
                : Column(
                    children: [
                      for (final plan in plans) ...[
                        PublicPlanCard(plan: plan),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
          ),
          if (pricing.hasValue && pricing.value!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              context.tr('publicPricingTaxNote'),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ],
          _sectionGap,
          PublicSectionHeader(
            title: context.tr('publicPricingFaqTitle'),
            subtitle: context.tr('publicPricingFaqSubtitle'),
          ),
          const SizedBox(height: 10),
          faq.when(
            loading: () => const PublicLoadingCard(height: 140),
            error: (error, stack) => PublicErrorCard(
              message: publicErrorMessage(context, error),
              onRetry: () => ref.invalidate(marketingFaqProvider),
            ),
            data: (entries) => entries.isEmpty
                ? PublicNoteCard(
                    icon: Icons.help_outline,
                    title: context.tr('publicPricingFaqTitle'),
                    body: context.tr('noFaqEntries'),
                  )
                : _FaqList(entries: entries.take(5).toList()),
          ),
          _sectionGap,
          PublicCtaBand(
            title: context.tr('publicHomeCtaTitle'),
            body: context.tr('publicHomeCtaBody'),
            actionLabel: context.tr('joinWaitlist'),
            onAction: () => context.push(RoutePaths.waitlist),
          ),
          const PublicFooter(),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------ about */

class PublicAboutScreen extends ConsumerWidget {
  const PublicAboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(contentPageProvider('about'));

    return PublicDetailScaffold(
      embedded: true,
      title: context.tr('publicNavAbout'),
      child: page.when(
        loading: () => PublicScrollView(
          children: [
            PublicHero(
              compact: true,
              badge: context.tr('publicAboutBadge'),
              title: context.tr('publicNavAbout'),
              subtitle: context.tr('publicHomePillarsSubtitle'),
            ),
            _sectionGap,
            const PublicLoadingCard(height: 320),
            const PublicFooter(),
          ],
        ),
        error: (error, stack) {
          final unavailable =
              error is ApiException && error.statusCode == 404;
          return PublicScrollView(
            children: [
              PublicHero(
                compact: true,
                badge: context.tr('publicAboutBadge'),
                title: unavailable
                    ? context.tr('publicAboutUnavailableTitle')
                    : context.tr('publicNavAbout'),
                subtitle: unavailable
                    ? context.tr('publicAboutUnavailableBody')
                    : publicErrorMessage(context, error),
                primaryLabel: context.tr('publicAboutContactCta'),
                primaryIcon: Icons.mail_outline,
                onPrimary: () => context.push(RoutePaths.publicContact),
              ),
              const SizedBox(height: 16),
              PublicErrorCard(
                message: publicErrorMessage(context, error),
                onRetry: () =>
                    ref.invalidate(contentPageProvider('about')),
              ),
              const PublicFooter(),
            ],
          );
        },
        data: (document) => PublicScrollView(
          onRefresh: () async =>
              ref.invalidate(contentPageProvider('about')),
          children: [
            PublicHero(
              compact: true,
              badge: context.tr('publicAboutBadge'),
              title: document.title,
              subtitle: document.intro,
              primaryLabel: context.tr('publicAboutContactCta'),
              primaryIcon: Icons.mail_outline,
              onPrimary: () => context.push(RoutePaths.publicContact),
            ),
            _sectionGap,
            _ContentSections(sections: document.sections),
            if (document.publishedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 20),
                child: Text(
                  context.tr(
                    'lastUpdated',
                    args: {'date': Formatters.date(document.publishedAt)},
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            PublicCtaBand(
              title: context.tr('publicHomeCtaTitle'),
              body: context.tr('publicHomeCtaBody'),
              actionLabel: context.tr('joinWaitlist'),
              onAction: () => context.push(RoutePaths.waitlist),
            ),
            const PublicFooter(),
          ],
        ),
      ),
    );
  }
}

class _ContentSections extends StatelessWidget {
  const _ContentSections({required this.sections});

  final List<ContentSection> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: _ContentSection(section: section),
          ),
      ],
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.section});

  final ContentSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (section.layout) {
      case 'steps':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading(context),
            const SizedBox(height: 12),
            for (var index = 0;
                index < parseLabeledItems(section.body).length;
                index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NumberedItem(
                  index: index + 1,
                  item: parseLabeledItems(section.body)[index],
                ),
              ),
          ],
        );
      case 'cards':
        final items = parseLabeledItems(section.body);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading(context),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 560 ? 2 : 1;
                final width = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: width,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (item.description.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Text(
                                  item.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      case 'cta':
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.title.isNotEmpty)
                Text(
                  section.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                section.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                ),
                onPressed: () => context.push(RoutePaths.publicContact),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(context.tr('publicAboutContactCta')),
              ),
            ],
          ),
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading(context),
            const SizedBox(height: 10),
            ContentBlocksView(body: section.body),
          ],
        );
    }
  }

  Widget _heading(BuildContext context) {
    if (section.title.isEmpty) return const SizedBox.shrink();
    return Text(
      section.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _NumberedItem extends StatelessWidget {
  const _NumberedItem({required this.index, required this.item});

  final int index;
  final LabeledItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.tint(scheme.primary),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$index',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ----------------------------------------------------------- how it works */

class PublicHowItWorksScreen extends StatelessWidget {
  const PublicHowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = <(String, String)>[
      (
        context.tr('publicHowSetupOneTitle'),
        context.tr('publicHowSetupOneBody')
      ),
      (
        context.tr('publicHowSetupTwoTitle'),
        context.tr('publicHowSetupTwoBody')
      ),
      (
        context.tr('publicHowSetupThreeTitle'),
        context.tr('publicHowSetupThreeBody')
      ),
    ];

    return PublicDetailScaffold(
      title: context.tr('publicNavHowItWorks'),
      child: PublicScrollView(
        children: [
          PublicHero(
            compact: true,
            badge: context.tr('publicNavHowItWorks'),
            title: context.tr('publicHowTitle'),
            subtitle: context.tr('publicHowSubtitle'),
            primaryLabel: context.tr('joinWaitlist'),
            primaryIcon: Icons.hourglass_empty,
            onPrimary: () => context.push(RoutePaths.waitlist),
          ),
          _sectionGap,
          const _StepsSection(compact: false),
          _sectionGap,
          PublicSectionHeader(
            title: context.tr('publicHowSetupTitle'),
            subtitle: context.tr('publicHowSetupSubtitle'),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < steps.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _NumberedItem(
                index: index + 1,
                item: LabeledItem(
                  title: steps[index].$1,
                  description: steps[index].$2,
                ),
              ),
            ),
          _sectionGap,
          PublicNoteCard(
            icon: Icons.shield_outlined,
            title: context.tr('publicHowSecurityTitle'),
            body: context.tr('publicHowSecurityBody'),
          ),
          _sectionGap,
          PublicCtaBand(
            title: context.tr('publicHowCtaTitle'),
            body: context.tr('publicHowCtaBody'),
            actionLabel: context.tr('joinWaitlist'),
            onAction: () => context.push(RoutePaths.waitlist),
          ),
          const PublicFooter(),
        ],
      ),
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final steps = <(IconData, String, String)>[
      (
        Icons.chat_bubble_outline,
        context.tr('publicStepConversationTitle'),
        context.tr('publicStepConversationBody'),
      ),
      (
        Icons.person_search_outlined,
        context.tr('publicStepCustomerTitle'),
        context.tr('publicStepCustomerBody'),
      ),
      (
        Icons.receipt_long_outlined,
        context.tr('publicStepOrderTitle'),
        context.tr('publicStepOrderBody'),
      ),
      (
        Icons.warehouse_outlined,
        context.tr('publicStepInventoryTitle'),
        context.tr('publicStepInventoryBody'),
      ),
      (
        Icons.groups_outlined,
        context.tr('publicStepTeamTitle'),
        context.tr('publicStepTeamBody'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PublicSectionHeader(
          eyebrow: context.tr('publicHomeStoryEyebrow'),
          title: context.tr('publicHomeStoryTitle'),
          subtitle: context.tr('publicHomeStorySubtitle'),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < steps.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.tint(
                        Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      steps[index].$1,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${steps[index].$2}',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          steps[index].$3,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    height: 1.5,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!compact) const SizedBox(height: 2),
      ],
    );
  }
}

/* -------------------------------------------------------------------- faq */

class PublicFaqScreen extends ConsumerWidget {
  const PublicFaqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faq = ref.watch(marketingFaqProvider);

    return PublicDetailScaffold(
      title: context.tr('publicNavFaq'),
      child: PublicScrollView(
        onRefresh: () async => ref.invalidate(marketingFaqProvider),
        children: [
          PublicHero(
            compact: true,
            badge: context.tr('publicNavFaq'),
            title: context.tr('publicFaqTitle'),
            subtitle: context.tr('publicFaqSubtitle'),
            primaryLabel: context.tr('publicNavContact'),
            primaryIcon: Icons.mail_outline,
            onPrimary: () => context.push(RoutePaths.publicContact),
          ),
          _sectionGap,
          faq.when(
            loading: () => const PublicLoadingCard(height: 280),
            error: (error, stack) => PublicErrorCard(
              message: publicErrorMessage(context, error),
              onRetry: () => ref.invalidate(marketingFaqProvider),
            ),
            data: (entries) => entries.isEmpty
                ? EmptyState(
                    title: context.tr('noFaqEntries'),
                    icon: Icons.help_outline,
                  )
                : _FaqList(entries: entries),
          ),
          _sectionGap,
          PublicNoteCard(
            icon: Icons.mail_outline,
            title: context.tr('publicFaqContactTitle'),
            body: context.tr('publicFaqContactBody'),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: context.tr('publicNavContact'),
            icon: Icons.send_outlined,
            expand: true,
            onPressed: () => context.push(RoutePaths.publicContact),
          ),
          const PublicFooter(),
        ],
      ),
    );
  }
}

class _FaqList extends StatelessWidget {
  const _FaqList({required this.entries});

  final List<FaqEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < entries.length; index++) ...[
            if (index > 0) const Divider(height: 1),
            ExpansionTile(
              title: Text(
                entries[index].question,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              subtitle: entries[index].category == null
                  ? null
                  : Text(entries[index].category!),
              childrenPadding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              shape: const Border(),
              collapsedShape: const Border(),
              children: [
                Text(
                  entries[index].answer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------- blog */

class PublicBlogScreen extends ConsumerStatefulWidget {
  const PublicBlogScreen({super.key});

  @override
  ConsumerState<PublicBlogScreen> createState() => _PublicBlogScreenState();
}

class _PublicBlogScreenState extends ConsumerState<PublicBlogScreen> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeLoadMore);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(newsletterFeedProvider).items.isEmpty) {
        ref.read(newsletterFeedProvider.notifier).loadInitial();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_maybeLoadMore);
    _controller.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_controller.hasClients) return;
    if (_controller.position.extentAfter < 500) {
      ref.read(newsletterFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsletterFeedProvider);
    final notifier = ref.read(newsletterFeedProvider.notifier);
    final featured = state.items.isEmpty ? null : state.items.first;
    final rest = state.items.skip(1).toList();

    final content = <Widget>[
      PublicHero(
        compact: true,
        badge: context.tr('publicNavBlog'),
        title: context.tr('publicBlogTitle'),
        subtitle: context.tr('publicBlogSubtitle'),
        primaryLabel: context.tr('joinWaitlist'),
        primaryIcon: Icons.hourglass_empty,
        onPrimary: () => context.push(RoutePaths.waitlist),
      ),
      _sectionGap,
      if (state.isLoading && state.items.isEmpty)
        const PublicLoadingCard(height: 280)
      else if (state.error != null && state.items.isEmpty)
        PublicErrorCard(
          message: state.error!,
          onRetry: notifier.reload,
        )
      else if (state.items.isEmpty)
        EmptyState(
          title: context.tr('publicBlogEmptyTitle'),
          message: context.tr('publicBlogEmptyBody'),
          icon: Icons.newspaper_outlined,
        )
      else ...[
        PublicSectionHeader(title: context.tr('publicBlogFeatured')),
        const SizedBox(height: 10),
        PublicArticleCard(article: featured!, featured: true),
        if (rest.isNotEmpty) ...[
          _sectionGap,
          PublicSectionHeader(title: context.tr('publicBlogAll')),
          const SizedBox(height: 10),
          for (final article in rest) ...[
            PublicArticleCard(article: article),
            const SizedBox(height: 10),
          ],
        ],
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: PublicErrorCard(
              message: state.error!,
              onRetry: notifier.reload,
            ),
          ),
      ],
      const PublicFooter(),
    ];

    return PublicDetailScaffold(
      title: context.tr('publicNavBlog'),
      child: RefreshIndicator(
        onRefresh: notifier.reload,
        child: ListView(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: content,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PublicBlogArticleScreen extends ConsumerWidget {
  const PublicBlogArticleScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.watch(marketingNewsletterProvider(slug));

    return PublicDetailScaffold(
      title: context.tr('publicNavBlog'),
      child: article.when(
        loading: () => const LoadingView(),
        error: (error, stack) {
          final missing = error is ApiException && error.statusCode == 404;
          return PublicScrollView(
            children: [
              PublicHero(
                compact: true,
                badge: context.tr('publicNavBlog'),
                title: missing
                    ? context.tr('publicBlogNotFoundTitle')
                    : context.tr('publicNavBlog'),
                subtitle: missing
                    ? context.tr('publicBlogNotFoundBody')
                    : publicErrorMessage(context, error),
                primaryLabel: context.tr('publicBlogBack'),
                primaryIcon: Icons.arrow_back,
                onPrimary: () => context.go(RoutePaths.publicBlog),
              ),
              const SizedBox(height: 16),
              PublicErrorCard(
                message: publicErrorMessage(context, error),
                onRetry: () =>
                    ref.invalidate(marketingNewsletterProvider(slug)),
              ),
              const PublicFooter(),
            ],
          );
        },
        data: (item) => _ArticleBody(article: item),
      ),
    );
  }
}

class _ArticleBody extends StatelessWidget {
  const _ArticleBody({required this.article});

  final Newsletter article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final direction =
        article.isArabic ? TextDirection.rtl : Directionality.of(context);
    final meta = [
      if (article.publishedAt != null) Formatters.date(article.publishedAt),
      context.tr('readingMinutes', args: {'count': article.readingMinutes}),
    ].join(' · ');

    return Directionality(
      textDirection: direction,
      child: PublicScrollView(
        children: [
          if (article.coverImageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: article.coverImageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: theme.colorScheme.primaryContainer,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.newspaper_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            article.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            meta,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          if (article.body != null && article.body!.trim().isNotEmpty)
            SanitizedHtml(html: article.body!)
          else
            Text(
              article.excerpt,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.7,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 20),
          AppButton(
            label: context.tr('publicBlogBack'),
            icon: Icons.arrow_back,
            variant: AppButtonVariant.outlined,
            onPressed: () => context.go(RoutePaths.publicBlog),
          ),
          const PublicFooter(),
        ],
      ),
    );
  }
}

/* ---------------------------------------------------------------- contact */

class PublicContactScreen extends ConsumerStatefulWidget {
  const PublicContactScreen({super.key});

  @override
  ConsumerState<PublicContactScreen> createState() =>
      _PublicContactScreenState();
}

class _PublicContactScreenState extends ConsumerState<PublicContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _body = TextEditingController();
  final _website = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _body.dispose();
    _website.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PublicDetailScaffold(
      title: context.tr('publicNavContact'),
      child: PublicScrollView(
        children: [
          PublicHero(
            compact: true,
            badge: context.tr('publicNavContact'),
            title: context.tr('publicContactTitle'),
            subtitle: context.tr('publicContactSubtitle'),
          ),
          const SizedBox(height: 16),
          if (_sent)
            _SentCard(
              title: context.tr('publicContactSuccessTitle'),
              body: context.tr('publicContactSuccessBody'),
              actionLabel: context.tr('sendAnotherMessage'),
              onAction: () => setState(() {
                _sent = false;
                _subject.clear();
                _body.clear();
              }),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _name,
                      label: context.tr('name'),
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (value) => _required(context, value),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _email,
                      label: context.tr('email'),
                      hint: context.tr('emailHint'),
                      prefixIcon: Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) => _emailError(context, value),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _subject,
                      label: context.tr('subject'),
                      prefixIcon: Icons.subject,
                      textInputAction: TextInputAction.next,
                      validator: (value) => _required(context, value),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _body,
                      label: context.tr('message'),
                      maxLines: 6,
                      minLines: 4,
                      validator: (value) => _required(context, value),
                    ),
                    Offstage(
                      offstage: true,
                      child: AppTextField(
                        controller: _website,
                        label: context.tr('publicContactHoneypot'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 16,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.tr('publicContactResponse'),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
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
          const PublicFooter(),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_sending) return;
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _sending = true);
    try {
      await ref.read(marketingActionsProvider).contact(
            name: _name.text.trim(),
            email: _email.text.trim(),
            subject: _subject.text.trim(),
            message: _body.text.trim(),
            website: _website.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sent = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnack.show(context, publicErrorMessage(context, error),
          isError: true);
    }
  }
}

/* --------------------------------------------------------------- waitlist */

class PublicWaitlistScreen extends ConsumerStatefulWidget {
  const PublicWaitlistScreen({super.key});

  @override
  ConsumerState<PublicWaitlistScreen> createState() =>
      _PublicWaitlistScreenState();
}

class _PublicWaitlistScreenState extends ConsumerState<PublicWaitlistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _businessType = TextEditingController();
  final _website = TextEditingController();
  bool _sending = false;
  bool _joined = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _businessType.dispose();
    _website.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PublicDetailScaffold(
      title: context.tr('joinWaitlist'),
      child: PublicScrollView(
        children: [
          PublicHero(
            compact: true,
            badge: context.tr('joinWaitlist'),
            title: context.tr('publicWaitlistTitle'),
            subtitle: context.tr('publicWaitlistSubtitle'),
          ),
          const SizedBox(height: 16),
          if (_joined)
            _SentCard(
              icon: Icons.check_circle_outline,
              title: context.tr('waitlistJoined'),
              body: context.tr('waitlistJoinedHint'),
              actionLabel: context.tr('publicExplore'),
              onAction: () => context.go(RoutePaths.home),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      context.tr('publicWaitlistBody'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.55,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _email,
                      label: context.tr('email'),
                      hint: context.tr('emailHint'),
                      prefixIcon: Icons.alternate_email,
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
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _businessType,
                      label: context.tr('businessType'),
                      helper: context.tr('optional'),
                      prefixIcon: Icons.storefront_outlined,
                    ),
                    Offstage(
                      offstage: true,
                      child: AppTextField(
                        controller: _website,
                        label: context.tr('publicContactHoneypot'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 16,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.tr('publicWaitlistPrivacy'),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
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
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.push(RoutePaths.login),
                child: Text(context.tr('publicRegisterHaveAccount')),
              ),
            ),
          ],
          const PublicFooter(),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_sending) return;
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _sending = true);
    try {
      await ref.read(marketingActionsProvider).joinWaitlist(
            email: _email.text.trim(),
            name: _name.text.trim(),
            businessType: _businessType.text.trim(),
            website: _website.text.trim(),
            source: 'mobile_public',
          );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _joined = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnack.show(context, publicErrorMessage(context, error),
          isError: true);
    }
  }
}

/* ------------------------------------------------------------- content page */

class PublicContentPageScreen extends ConsumerWidget {
  const PublicContentPageScreen({super.key, required this.pageKey});

  final String pageKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(contentPageProvider(pageKey));

    return PublicDetailScaffold(
      title: context.tr('information'),
      child: page.when(
        loading: () => const LoadingView(),
        error: (error, stack) {
          final unavailable =
              error is ApiException && error.statusCode == 404;
          return PublicScrollView(
            children: [
              PublicHero(
                compact: true,
                badge: context.tr('information'),
                title: unavailable
                    ? context.tr('publicContentUnavailableTitle')
                    : context.tr('information'),
                subtitle: unavailable
                    ? context.tr('publicContentUnavailableBody')
                    : publicErrorMessage(context, error),
                primaryLabel: context.tr('publicContentBackHome'),
                primaryIcon: Icons.home_outlined,
                onPrimary: () => context.go(RoutePaths.home),
              ),
              const SizedBox(height: 16),
              PublicErrorCard(
                message: publicErrorMessage(context, error),
                onRetry: () =>
                    ref.invalidate(contentPageProvider(pageKey)),
              ),
              const PublicFooter(),
            ],
          );
        },
        data: (document) => PublicScrollView(
          onRefresh: () async =>
              ref.invalidate(contentPageProvider(pageKey)),
          children: [
            PublicHero(
              compact: true,
              badge: context.tr('information'),
              title: document.title,
              subtitle: document.intro,
            ),
            if (document.publishedAt != null) ...[
              const SizedBox(height: 10),
              Text(
                context.tr(
                  'lastUpdated',
                  args: {'date': Formatters.date(document.publishedAt)},
                ),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            _sectionGap,
            _ContentSections(sections: document.sections),
            AppButton(
              label: context.tr('publicContentBackHome'),
              icon: Icons.home_outlined,
              variant: AppButtonVariant.outlined,
              onPressed: () => context.go(RoutePaths.home),
            ),
            const PublicFooter(),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------------------------------------- shared bits */

class _SentCard extends StatelessWidget {
  const _SentCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.mark_email_read_outlined,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.tint(AppColors.success),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.success, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: actionLabel,
            variant: AppButtonVariant.outlined,
            expand: true,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

String? _required(BuildContext context, String? value) {
  if (value == null || value.trim().isEmpty) {
    return context.tr('requiredField');
  }
  return null;
}

String? _emailError(BuildContext context, String? value) {
  final required = _required(context, value);
  if (required != null) return required;
  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!pattern.hasMatch(value!.trim())) return context.tr('invalidEmail');
  return null;
}
