import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../domain/store_domain.dart';

/// The store picker shared by every store-scoped settings screen.
///
/// Picking a store is local screen state; the API still authorises the store
/// id against the active tenant on every request.
class StoreSelectorField extends StatelessWidget {
  const StoreSelectorField({
    super.key,
    required this.stores,
    required this.selectedId,
    required this.onChanged,
    this.enabled = true,
  });

  final List<Store> stores;
  final int? selectedId;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      // ignore: deprecated_member_use
      value: selectedId,
      decoration: InputDecoration(labelText: context.tr('selectStore')),
      items: [
        for (final store in stores)
          DropdownMenuItem(value: store.id, child: Text(store.name)),
      ],
      onChanged: enabled
          ? (value) {
              if (value != null) onChanged(value);
            }
          : null,
    );
  }
}
