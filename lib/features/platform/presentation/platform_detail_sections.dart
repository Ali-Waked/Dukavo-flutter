import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../../../core/resources/json_resource.dart';
import '../../../core/widgets/app_widgets.dart';

final tenantMembersProvider =
    FutureProvider.autoDispose.family<List<JsonResource>, int>((ref, id) async {
  final data = await ref.read(apiClientProvider).get<List<dynamic>>(
        ApiPaths.platformTenantMembers(id),
        decode: (value) => value is List ? value : const <dynamic>[],
      );
  return data
      .whereType<Map>()
      .map((entry) => JsonResource(Map<String, dynamic>.from(entry)))
      .toList();
});

/// The people who belong to a tenant, loaded separately from the tenant row so
/// the detail page paints immediately and the member list can fail on its own.
class PlatformTenantMembersSection extends ConsumerWidget {
  const PlatformTenantMembersSection({super.key, required this.tenantId});

  final int tenantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(tenantMembersProvider(tenantId));
    return SectionCard(
      title: context.tr('members'),
      child: members.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: LinearProgressIndicator(),
        ),
        error: (error, stack) => Text(
          error is Exception ? context.tr('errorGeneric') : '$error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Text(
              context.tr('noMembers'),
              style: Theme.of(context).textTheme.bodySmall,
            );
          }
          return Column(
            children: [
              for (final member in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: AppAvatar(
                    name: member.text('name', fallback: '?'),
                    url: member.optionalText('avatar_url'),
                    size: 40,
                  ),
                  title: Text(member.text('name', fallback: '—')),
                  subtitle: Text(member.text('email')),
                  trailing: member.text('status').isEmpty
                      ? null
                      : StatusChip(
                          status: member.text('status'),
                          compact: true,
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Roles attached to a platform user. The detail payload already includes them;
/// this only presents the list.
class PlatformUserRolesSection extends StatelessWidget {
  const PlatformUserRolesSection({super.key, required this.resource});

  final JsonResource resource;

  @override
  Widget build(BuildContext context) {
    final roles = resource.maps('roles');
    final tenants = resource.maps('tenants');
    if (roles.isEmpty && tenants.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: context.tr('rolesAndWorkspaces'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (roles.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final role in roles)
                  Chip(
                    avatar: const Icon(Icons.verified_user_outlined, size: 16),
                    label: Text('${role['name'] ?? role['slug'] ?? '—'}'),
                  ),
              ],
            ),
          if (tenants.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              context.tr('workspaces'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            for (final tenant in tenants)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.business_outlined),
                title: Text('${tenant['name'] ?? '—'}'),
                subtitle: Text('${tenant['slug'] ?? ''}'),
              ),
          ],
        ],
      ),
    );
  }
}
