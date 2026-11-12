import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
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
  final _shortDescription = TextEditingController();
  final _highlights = TextEditingController();
  final _features = TextEditingController();
  final _specifications = TextEditingController();
  final _tags = TextEditingController();
  final _seoTitle = TextEditingController();
  final _seoDescription = TextEditingController();
  final _seoKeywords = TextEditingController();

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
        _shortDescription.text = product.shortDescription ?? '';
        _highlights.text = product.highlights.join('\n');
        _features.text = product.features.join('\n');
        _specifications.text = product.specifications
            .map((row) => '${row.label}: ${row.value}')
            .join('\n');
        _tags.text = product.tags.join(', ');
        _seoTitle.text = product.seoTitle ?? '';
        _seoDescription.text = product.seoDescription ?? '';
        _seoKeywords.text = product.seoKeywords ?? '';
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
    _shortDescription.dispose();
    _highlights.dispose();
    _features.dispose();
    _specifications.dispose();
    _tags.dispose();
    _seoTitle.dispose();
    _seoDescription.dispose();
    _seoKeywords.dispose();
    super.dispose();
  }

  List<String> _lines(String value) => value
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);

  List<String> _tagList(String value) => value
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList(growable: false);

  List<ProductSpecification> _specificationList(String value) {
    return _lines(value)
        .map((line) {
          final separator = line.indexOf(':');
          if (separator == -1) {
            return ProductSpecification(label: line, value: '');
          }
          return ProductSpecification(
            label: line.substring(0, separator).trim(),
            value: line.substring(separator + 1).trim(),
          );
        })
        .where((row) => row.label.isNotEmpty)
        .toList(growable: false);
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
      shortDescription: _shortDescription.text.trim().isEmpty
          ? null
          : _shortDescription.text.trim(),
      highlights: _lines(_highlights.text),
      features: _lines(_features.text),
      specifications: _specificationList(_specifications.text),
      tags: _tagList(_tags.text),
      seoTitle: _seoTitle.text.trim().isEmpty ? null : _seoTitle.text.trim(),
      seoDescription: _seoDescription.text.trim().isEmpty
          ? null
          : _seoDescription.text.trim(),
      seoKeywords:
          _seoKeywords.text.trim().isEmpty ? null : _seoKeywords.text.trim(),
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
                      padding: AppSpacing.page,
                      children: [
                        SectionCard(
                          title: context.tr('details'),
                          child: Column(
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
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                controller: _sku,
                                label: context.tr('sku'),
                                helper: context.tr('optional'),
                                prefixIcon: Icons.qr_code_2,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              DropdownButtonFormField<int?>(
                                // ignore: deprecated_member_use
                                value: _categoryId,
                                decoration: InputDecoration(
                                  labelText: context.tr('category'),
                                  prefixIcon: const Icon(
                                    Icons.category_outlined,
                                    size: 20,
                                  ),
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
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SectionCard(
                          title: context.tr('price'),
                          child: Row(
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
                              const SizedBox(width: AppSpacing.sm),
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
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SectionCard(
                          title: context.tr('productStatus'),
                          child: Column(
                            children: [
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
                                onChanged: (value) => setState(
                                  () => _status = value ?? 'active',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                controller: _description,
                                label: context.tr('description'),
                                helper: context.tr('optional'),
                                maxLines: 4,
                                minLines: 3,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                controller: _shortDescription,
                                label: context.tr('shortDescription'),
                                helper: context.tr('optional'),
                                maxLines: 2,
                                minLines: 2,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                controller: _highlights,
                                label: context.tr('highlights'),
                                helper: context.tr('linesHint'),
                                maxLines: 4,
                                minLines: 3,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                controller: _features,
                                label: context.tr('features'),
                                helper: context.tr('linesHint'),
                                maxLines: 4,
                                minLines: 3,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                controller: _specifications,
                                label: context.tr('specifications'),
                                helper: context.tr('specificationsHint'),
                                maxLines: 5,
                                minLines: 3,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                controller: _tags,
                                label: context.tr('tags'),
                                helper: context.tr('tagsHint'),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                context.tr('seoTitle'),
                                style: context.texts.titleSmall,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                controller: _seoTitle,
                                label: context.tr('seoTitle'),
                                helper: context.tr('optional'),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                controller: _seoDescription,
                                label: context.tr('seoDescription'),
                                helper: context.tr('optional'),
                                maxLines: 2,
                                minLines: 2,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                controller: _seoKeywords,
                                label: context.tr('seoKeywords'),
                                helper: context.tr('tagsHint'),
                              ),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(context.tr('tax')),
                                subtitle: Text(
                                  context.tr('isTaxableHint'),
                                  style: context.texts.bodySmall?.copyWith(
                                    color: context.dukavo.textMuted,
                                  ),
                                ),
                                value: _isTaxable,
                                onChanged: (value) =>
                                    setState(() => _isTaxable = value),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
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
