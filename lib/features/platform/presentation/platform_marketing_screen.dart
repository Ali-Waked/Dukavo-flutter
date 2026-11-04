import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SectionCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.campaign_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('marketingHub'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('marketingHubHint'),
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
          for (final group in groups) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
              child: Text(
                context.tr(group.titleKey),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final entry in group.entries)
                    ListTile(
                      leading: Icon(entry.icon),
                      title: Text(context.tr(entry.labelKey)),
                      subtitle: Text(context.tr(entry.descriptionKey)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(entry.path),
                    ),
                ],
              ),
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
