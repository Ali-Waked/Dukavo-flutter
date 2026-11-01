import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../categories/application/category_controller.dart';
import '../../categories/domain/category_domain.dart';
import '../application/product_controller.dart';
import '../domain/product_domain.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.slug});

  /// Present when editing an existing product.
  final String? slug;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _price = TextEditingController();
  final _cost = TextEditingController();
  final _description = TextEditingController();

  String _status = 'active';
  int? _categoryId;
  bool _isTaxable = true;
  bool _submitting = false;
  bool _loading = false;
  String? _loadError;

  bool get _isEditing => widget.slug != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final product =
          await ref.read(productRepositoryProvider).get(widget.slug!);
      if (!mounted) return;
      setState(() {
        _name.text = product.name;
        _sku.text = product.sku ?? '';
        _price.text = product.price.toString();
        _cost.text = product.cost.toString();
        _description.text = product.description ?? '';
        _status = product.status;
        _categoryId = product.categoryId;
        _isTaxable = product.isTaxable;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _price.dispose();
    _cost.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final draft = ProductDraft(
      name: _name.text.trim(),
      sku: _sku.text.trim().isEmpty ? null : _sku.text.trim(),
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      status: _status,
      price: num.tryParse(_price.text.trim()) ?? 0,
      cost: num.tryParse(_cost.text.trim()) ?? 0,
      categoryId: _categoryId,
      isTaxable: _isTaxable,
    );

    try {
      if (_isEditing) {
        await ref.read(productActionsProvider).update(widget.slug!, draft);
      } else {
        await ref.read(productActionsProvider).create(draft);
      }
      if (!mounted) return;
      AppSnack.show(
        context,
        context.tr(_isEditing ? 'productUpdated' : 'productCreated'),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final categoryOptions = categories.maybeWhen(
        data: Category.flatten, orElse: () => const <Category>[]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(_isEditing ? 'editProduct' : 'createProduct'),
        ),
      ),
      body: _loading
          ? const LoadingView()
          : _loadError != null
              ? ErrorView(message: _loadError!, onRetry: _load)
              : SafeArea(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: [
                        AppTextField(
                          controller: _name,
                          label: context.tr('productName'),
                          prefixIcon: Icons.inventory_2_outlined,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? context.tr('requiredField')
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _sku,
                          label: context.tr('sku'),
                          helper: context.tr('optional'),
                          prefixIcon: Icons.qr_code_2,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _price,
                                label: context.tr('price'),
                                prefixIcon: Icons.sell_outlined,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                textInputAction: TextInputAction.next,
                                validator: Validators.positiveNumber,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                controller: _cost,
                                label: context.tr('cost'),
                                prefixIcon: Icons.payments_outlined,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                textInputAction: TextInputAction.next,
                                validator: Validators.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int?>(
                          // ignore: deprecated_member_use
                          value: _categoryId,
                          decoration: InputDecoration(
                            labelText: context.tr('category'),
                            prefixIcon:
                                const Icon(Icons.category_outlined, size: 20),
                          ),
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text(context.tr('none')),
                            ),
                            for (final category in categoryOptions)
                              DropdownMenuItem<int?>(
                                value: category.id,
                                child: Text(
                                  category.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _categoryId = value),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _status,
                          decoration: InputDecoration(
                            labelText: context.tr('productStatus'),
                            prefixIcon: const Icon(Icons.tune, size: 20),
                          ),
                          items: [
                            for (final status in const [
                              'active',
                              'draft',
                              'archived',
                            ])
                              DropdownMenuItem(
                                value: status,
                                child: Text(context.tr(status)),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _status = value ?? 'active'),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _description,
                          label: context.tr('description'),
                          helper: context.tr('optional'),
                          maxLines: 4,
                          minLines: 3,
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.tr('tax')),
                          subtitle: Text(
                            context.tr('isTaxableHint'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          value: _isTaxable,
                          onChanged: (value) =>
                              setState(() => _isTaxable = value),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: context.tr(
                            _isEditing ? 'saveChanges' : 'createProduct',
                          ),
                          loading: _submitting,
                          expand: true,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
