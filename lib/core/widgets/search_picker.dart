import 'package:flutter/material.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/design_tokens.dart';
import 'app_widgets.dart';

/// A form field that opens a searchable list of options.
///
/// Country and timezone lists are server-owned and long enough that a plain
/// dropdown becomes unusable on a phone. This keeps one interaction pattern for
/// both, with the same keyboard, empty and RTL behaviour.
class SearchPickerField<T> extends StatelessWidget {
  const SearchPickerField({
    super.key,
    required this.label,
    required this.options,
    required this.labelOf,
    required this.onSelected,
    this.value,
    this.hint,
    this.searchHint,
    this.emptyLabel,
    this.prefixIcon,
    this.subtitleOf,
    this.searchTermsOf,
    this.enabled = true,
  });

  final String label;
  final String? hint;
  final String? searchHint;
  final String? emptyLabel;
  final IconData? prefixIcon;
  final T? value;
  final List<T> options;
  final String Function(T option) labelOf;
  final String Function(T option)? subtitleOf;
  final String Function(T option)? searchTermsOf;
  final ValueChanged<T> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final selected = value;
    final text = selected == null ? null : labelOf(selected);
    final colors = context.dukavo;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: enabled ? () => _open(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? searchHint,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
          suffixIcon: const Icon(Icons.expand_more_rounded, size: 20),
          enabled: enabled,
        ),
        child: Text(
          text ?? '',
          style: (text == null || text.isEmpty)
              ? context.texts.bodyLarge?.copyWith(color: colors.textMuted)
              : context.texts.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _PickerSheet<T>(
        title: label,
        searchHint: searchHint ?? hint,
        emptyLabel: emptyLabel,
        options: options,
        selected: value,
        labelOf: labelOf,
        subtitleOf: subtitleOf,
        searchTermsOf: searchTermsOf,
      ),
    );

    if (result != null) onSelected(result);
  }
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.labelOf,
    this.subtitleOf,
    this.searchTermsOf,
    this.searchHint,
    this.emptyLabel,
    this.selected,
  });

  final String title;
  final String? searchHint;
  final String? emptyLabel;
  final List<T> options;
  final T? selected;
  final String Function(T option) labelOf;
  final String Function(T option)? subtitleOf;
  final String Function(T option)? searchTermsOf;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<T> get _filtered {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return widget.options;
    return widget.options.where((option) {
      final terms = widget.searchTermsOf?.call(option) ??
          '${widget.labelOf(option)} ${widget.subtitleOf?.call(option) ?? ''}';
      return terms.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.78;

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: AppTextField(
                controller: _search,
                hint: widget.searchHint,
                prefixIcon: Icons.search_rounded,
                autofocus: false,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        widget.emptyLabel ?? context.tr('noResults'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final option = _filtered[index];
                        final isSelected = option == widget.selected;
                        return ListTile(
                          title: Text(widget.labelOf(option)),
                          subtitle: widget.subtitleOf == null
                              ? null
                              : Text(widget.subtitleOf!(option)),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
