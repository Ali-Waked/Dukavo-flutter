import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../products/application/product_controller.dart';
import '../../products/domain/product_domain.dart';

/// The product gallery: upload, reorder, retitle and delete images.
///
/// The file itself is immutable on the server, so replacing an image is an
/// upload plus a delete. Reordering sends the full id list in the desired order,
/// which is what the API accepts.
class ProductImagesScreen extends ConsumerStatefulWidget {
  const ProductImagesScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<ProductImagesScreen> createState() =>
      _ProductImagesScreenState();
}

class _ProductImagesScreenState extends ConsumerState<ProductImagesScreen> {
  bool _uploading = false;
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(productDetailProvider(widget.slug));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('productImages')),
        actions: [
          IconButton(
            tooltip: context.tr('uploadImages'),
            onPressed: _uploading ? null : _pickAndUpload,
            icon: _uploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_photo_alternate_outlined),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: _message(error),
          onRetry: () => ref.invalidate(productDetailProvider(widget.slug)),
        ),
        data: (product) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(productDetailProvider(widget.slug)),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              SectionCard(
                title: product.name,
                subtitle: context.tr('productImagesHint'),
                child: Text(
                  context.tr('productImagesLimits'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              if (product.images.isEmpty)
                EmptyState(
                  title: context.tr('noImages'),
                  icon: Icons.image_outlined,
                  actionLabel: context.tr('uploadImages'),
                  onAction: _uploading ? null : _pickAndUpload,
                )
              else
                for (var index = 0; index < product.images.length; index++)
                  _imageCard(
                    context,
                    product,
                    product.images[index],
                    index,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageCard(
    BuildContext context,
    Product product,
    ProductImage image,
    int index,
  ) {
    final theme = Theme.of(context);
    final canMoveUp = index > 0;
    final canMoveDown = index < product.images.length - 1;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Image.network(
              image.url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined, size: 36),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (image.isPrimary) ...[
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              image.altText?.isNotEmpty == true
                                  ? image.altText!
                                  : context.tr('noAltText'),
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${context.tr('position')} ${index + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.tr('moveUp'),
                  onPressed: canMoveUp && !_working
                      ? () => _reorder(product, index, index - 1)
                      : null,
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  tooltip: context.tr('moveDown'),
                  onPressed: canMoveDown && !_working
                      ? () => _reorder(product, index, index + 1)
                      : null,
                  icon: const Icon(Icons.arrow_downward),
                ),
                PopupMenuButton<String>(
                  enabled: !_working,
                  onSelected: (value) {
                    switch (value) {
                      case 'primary':
                        _updateImage(image, isPrimary: true);
                      case 'alt':
                        _editAltText(image);
                      case 'delete':
                        _deleteImage(image);
                    }
                  },
                  itemBuilder: (context) => [
                    if (!image.isPrimary)
                      PopupMenuItem(
                        value: 'primary',
                        child: Text(context.tr('setPrimary')),
                      ),
                    PopupMenuItem(
                      value: 'alt',
                      child: Text(context.tr('editAltText')),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        context.tr('delete'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    try {
      final files = await picker.pickMultiImage(
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 88,
      );
      if (files.isEmpty) return;
      if (files.length > 10) {
        if (!mounted) return;
        AppSnack.show(context, context.tr('tooManyImages'), isError: true);
        return;
      }
      setState(() => _uploading = true);
      final form = FormData();
      for (final file in files) {
        final bytes = await file.readAsBytes();
        if (bytes.lengthInBytes > 4096 * 1024) {
          if (!mounted) return;
          AppSnack.show(context, context.tr('imageTooLarge'), isError: true);
          return;
        }
        form.files.add(
          MapEntry(
            'images[]',
            MultipartFile.fromBytes(bytes, filename: file.name),
          ),
        );
      }
      await ref.read(apiClientProvider).post<dynamic>(
            ApiPaths.productImages(widget.slug),
            body: form,
          );
      ref.invalidate(productDetailProvider(widget.slug));
      if (!mounted) return;
      AppSnack.show(context, context.tr('imagesUploaded'));
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, _message(error), isError: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _reorder(Product product, int from, int to) async {
    final ids = product.images.map((image) => image.id).toList();
    final moved = ids.removeAt(from);
    ids.insert(to, moved);
    setState(() => _working = true);
    try {
      await ref.read(apiClientProvider).put<dynamic>(
        ApiPaths.productImagesReorder(widget.slug),
        body: {'images': ids},
      );
      ref.invalidate(productDetailProvider(widget.slug));
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, _message(error), isError: true);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _updateImage(
    ProductImage image, {
    String? altText,
    bool? isPrimary,
  }) async {
    setState(() => _working = true);
    try {
      await ref.read(apiClientProvider).patch<dynamic>(
        ApiPaths.productImage(widget.slug, image.id),
        body: {
          if (altText != null) 'alt_text': altText.isEmpty ? null : altText,
          if (isPrimary != null) 'is_primary': isPrimary,
        },
      );
      ref.invalidate(productDetailProvider(widget.slug));
      if (!mounted) return;
      AppSnack.show(context, context.tr('saved'));
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, _message(error), isError: true);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _editAltText(ProductImage image) async {
    final controller = TextEditingController(text: image.altText ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('editAltText')),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 255,
          decoration: InputDecoration(
            labelText: context.tr('altText'),
            helperText: context.tr('altTextHint'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    await _updateImage(image, altText: result);
  }

  Future<void> _deleteImage(ProductImage image) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('deleteImage'),
      message: context.tr('deleteImageMessage'),
      confirmLabel: context.tr('delete'),
      destructive: true,
    );
    if (confirmed != true) return;
    setState(() => _working = true);
    try {
      await ref.read(apiClientProvider).delete(
            ApiPaths.productImage(widget.slug, image.id),
          );
      ref.invalidate(productDetailProvider(widget.slug));
      if (!mounted) return;
      AppSnack.show(context, context.tr('deleted'));
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, _message(error), isError: true);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  String _message(Object error) =>
      error is ApiException ? error.message : context.tr('errorGeneric');
}
