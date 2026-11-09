import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/app_widgets.dart';

/// The marketing administration hub: Dukavo's own content, leads and audience.
class PlatformMarketingScreen extends StatelessWidget {
  const PlatformMarketingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = <_MarketingGroup>[
      const _MarketingGroup(
        titleKey: 'content',
        entries: [
          _MarketingEntry(
            labelKey: 'pricingPlans',
            descriptionKey: 'pricingPlansHint',
            icon: Icons.sell_outlined,
            path: RoutePaths.platformPricing,
          ),
          _MarketingEntry(
            labelKey: 'faqEntries',
            descriptionKey: 'faqEntriesHint',
            icon: Icons.help_outline,
            path: RoutePaths.platformFaq,
          ),
          _MarketingEntry(
            labelKey: 'contentPages',
            descriptionKey: 'contentPagesHint',
            icon: Icons.article_outlined,
            path: RoutePaths.platformContentPages,
          ),
          _MarketingEntry(
            labelKey: 'newsletters',
            descriptionKey: 'newslettersHint',
            icon: Icons.newspaper_outlined,
            path: RoutePaths.platformNewsletters,
          ),
        ],
      ),
      const _MarketingGroup(
        titleKey: 'leadsAndAudience',
        entries: [
          _MarketingEntry(
            labelKey: 'waitlist',
            descriptionKey: 'waitlistHint',
            icon: Icons.hourglass_empty,
            path: RoutePaths.platformWaitlist,
          ),
          _MarketingEntry(
            labelKey: 'contactMessages',
            descriptionKey: 'contactMessagesHint',
            icon: Icons.mark_email_unread_outlined,
            path: RoutePaths.platformContact,
          ),
          _MarketingEntry(
            labelKey: 'subscribers',
            descriptionKey: 'subscribersHint',
            icon: Icons.mark_email_read_outlined,
            path: RoutePaths.platformSubscribers,
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('marketing'))),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          SectionCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.scheme.primary.withValues(
                      alpha: context.isDark ? 0.18 : 0.10,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.campaign_outlined,
                    color: context.scheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('marketingHub'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('marketingHubHint'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.dukavo.textMuted,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final group in groups) ...[
            const SizedBox(height: AppSpacing.lg),
            AppListGroup(
              title: context.tr(group.titleKey),
              children: [
                for (final entry in group.entries)
                  ListTile(
                    leading: Icon(entry.icon, size: 21),
                    title: Text(context.tr(entry.labelKey)),
                    subtitle: Text(
                      context.tr(entry.descriptionKey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: context.dukavo.textMuted,
                    ),
                    onTap: () => context.push(entry.path),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MarketingGroup {
  const _MarketingGroup({required this.titleKey, required this.entries});

  final String titleKey;
  final List<_MarketingEntry> entries;
}

class _MarketingEntry {
  const _MarketingEntry({
    required this.labelKey,
    required this.descriptionKey,
    required this.icon,
    required this.path,
  });

  final String labelKey;
  final String descriptionKey;
  final IconData icon;
  final String path;
}
