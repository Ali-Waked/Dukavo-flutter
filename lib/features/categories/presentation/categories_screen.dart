import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/category_controller.dart';
import '../domain/category_domain.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(categoryTreeProvider);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('categories')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () => ref.invalidate(categoryTreeProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: permissions.canManageCategories
          ? FloatingActionButton.extended(
              onPressed: () => _showEditor(context, ref),
              icon: const Icon(Icons.add),
              label: Text(context.tr('createCategory')),
            )
          : null,
      body: async.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(categoryTreeProvider),
        ),
        data: (roots) {
          if (roots.isEmpty) {
            return EmptyState(
              title: context.tr('noCategories'),
              icon: Icons.category_outlined,
              actionLabel: permissions.canManageCategories
                  ? context.tr('addFirstCategory')
                  : null,
              onAction: permissions.canManageCategories
                  ? () => _showEditor(context, ref)
                  : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(categoryTreeProvider);
              await ref.read(categoryTreeProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                for (final root in roots)
                  _CategoryNode(
                    category: root,
                    depth: 0,
                    canManage: permissions.canManageCategories,
                    onEdit: (category) =>
                        _showEditor(context, ref, category: category),
                    onDelete: (category) => _delete(context, ref, category),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('deleteConfirmTitle'),
      message: context.tr('deleteConfirmMessage'),
      confirmLabel: context.tr('confirmDelete'),
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(categoryActionsProvider).delete(category.id);
      if (context.mounted) {
        AppSnack.show(context, context.tr('categoryDeleted'));
      }
    } catch (error) {
      if (context.mounted) {
        AppSnack.show(context, error.toString(), isError: true);
      }
    }
  }

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final tree = ref.read(categoryTreeProvider).valueOrNull ?? const <Category>[];
    final flattened = Category.flatten(tree)
        .where((entry) => entry.id != category?.id)
        .toList();

    final result = await showModalBottomSheet<_CategoryFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _CategoryFormSheet(
          category: category,
          parents: flattened,
        ),
      ),
    );

    if (result == null) return;

    try {
      if (category == null) {
        await ref.read(categoryActionsProvider).create(result.draft);
      } else {
        await ref
            .read(categoryActionsProvider)
            .update(category.id, result.draft);
      }
      if (context.mounted) {
        AppSnack.show(
          context,
          context.tr(category == null ? 'categoryCreated' : 'categoryUpdated'),
        );
      }
    } catch (error) {
      if (context.mounted) {
        AppSnack.show(context, error.toString(), isError: true);
      }
    }
  }
}

class _CategoryNode extends StatelessWidget {
  const _CategoryNode({
    required this.category,
    required this.depth,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final int depth;
  final bool canManage;
  final void Function(Category category) onEdit;
  final void Function(Category category) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsetsDirectional.only(
            start: depth * 16.0,
            bottom: 8,
          ),
          child: ListTile(
            leading: Icon(
              depth == 0 ? Icons.folder_outlined : Icons.subdirectory_arrow_right,
              color: category.isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(
              category.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              [
                category.slug,
                if (category.productsCount != null)
                  '${category.productsCount} ${context.tr('productsCount')}',
              ].join(' · '),
              style: theme.textTheme.labelSmall,
            ),
            trailing: canManage
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit(category);
                      if (value == 'delete') onDelete(category);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(context.tr('edit')),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(context.tr('delete')),
                      ),
                    ],
                  )
                : null,
          ),
        ),
        for (final child in category.children)
          _CategoryNode(
            category: child,
            depth: depth + 1,
            canManage: canManage,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
      ],
    );
  }
}

class _CategoryFormResult {
  const _CategoryFormResult(this.draft);

  final CategoryDraft draft;
}

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({required this.category, required this.parents});

  final Category? category;
  final List<Category> parents;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _sortOrder;
  int? _parentId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _name = TextEditingController(text: category?.name ?? '');
    _description = TextEditingController(text: category?.description ?? '');
    _sortOrder = TextEditingController(text: '${category?.sortOrder ?? 0}');
    _parentId = category?.parentId;
    _isActive = category?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr(
                  widget.category == null ? 'createCategory' : 'editCategory',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _name,
                label: context.tr('categoryName'),
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.tr('requiredField')
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: _parentId,
                decoration: InputDecoration(
                  labelText: context.tr('parentCategory'),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(context.tr('none')),
                  ),
                  for (final parent in widget.parents)
                    DropdownMenuItem<int?>(
                      value: parent.id,
                      child: Text(parent.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) => setState(() => _parentId = value),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _sortOrder,
                label: context.tr('sortOrder'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _description,
                label: context.tr('description'),
                helper: context.tr('optional'),
                maxLines: 3,
                minLines: 2,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('active')),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 8),
              AppButton(
                label: context.tr('save'),
                expand: true,
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  Navigator.of(context).pop(
                    _CategoryFormResult(
                      CategoryDraft(
                        name: _name.text.trim(),
                        parentId: _parentId,
                        description: _description.text.trim().isEmpty
                            ? null
                            : _description.text.trim(),
                        isActive: _isActive,
                        sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
