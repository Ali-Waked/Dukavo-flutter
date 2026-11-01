import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/customer_controller.dart';
import '../domain/customer_domain.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerListProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListProvider);
    final notifier = ref.read(customerListProvider.notifier);
    final permissions = ref.watch(permissionsProvider);
    final currency = ref.watch(currentSessionProvider)?.currency ?? 'USD';

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('customers'))),
      floatingActionButton: permissions.canCreateCustomers
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RoutePaths.createCustomer),
              icon: const Icon(Icons.person_add_alt),
              label: Text(context.tr('createCustomer')),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SearchField(
              controller: _search,
              hint: context.tr('searchCustomers'),
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 350),
                  () => notifier.setSearch(value),
                );
              },
              onSubmitted: notifier.setSearch,
            ),
          ),
          Expanded(
            child: PagedListView<Customer>(
              state: state,
              onRefresh: notifier.reload,
              onLoadMore: notifier.loadMore,
              empty: EmptyState(
                title: context.tr('noCustomers'),
                icon: Icons.people_outline,
                actionLabel: permissions.canCreateCustomers
                    ? context.tr('addFirstCustomer')
                    : null,
                onAction: permissions.canCreateCustomers
                    ? () => context.push(RoutePaths.createCustomer)
                    : null,
              ),
              itemBuilder: (context, customer, index) {
                return Card(
                  child: ListTile(
                    leading: AppAvatar(name: customer.name, size: 44),
                    title: Text(
                      customer.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      customer.phone ?? customer.email ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (customer.totalSpent != null)
                          Text(
                            Formatters.currency(customer.totalSpent!, currency,
                                compact: true),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        StatusChip(status: customer.status, compact: true),
                      ],
                    ),
                    onTap: () => context.push(RoutePaths.customer(customer.id)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(customerDetailProvider(id));
    final permissions = ref.watch(permissionsProvider);
    final currency = ref.watch(currentSessionProvider)?.currency ?? 'USD';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('customerDetails')),
        actions: [
          if (permissions.canUpdateCustomers)
            IconButton(
              tooltip: context.tr('edit'),
              onPressed: () => context.push(RoutePaths.customerEdit(id)),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(customerDetailProvider(id)),
        ),
        data: (customer) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Center(
              child: Column(
                children: [
                  AppAvatar(name: customer.name, size: 76),
                  const SizedBox(height: 12),
                  Text(
                    customer.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  StatusChip(status: customer.status),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SectionCard(
                    title: context.tr('totalSpent'),
                    child: Text(
                      customer.totalSpent == null
                          ? '—'
                          : Formatters.currency(customer.totalSpent!, currency),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SectionCard(
                    title: context.tr('ordersCount'),
                    child: Text(
                      '${customer.ordersCount ?? 0}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: context.tr('details'),
              child: Column(
                children: [
                  KeyValueRow(
                    label: context.tr('email'),
                    value: customer.email ?? '—',
                  ),
                  KeyValueRow(
                    label: context.tr('phone'),
                    value: customer.phone ?? '—',
                  ),
                  KeyValueRow(
                    label: context.tr('lastOrder'),
                    value: Formatters.date(customer.lastOrderAt),
                  ),
                  KeyValueRow(
                    label: context.tr('createdAt'),
                    value: Formatters.date(customer.createdAt),
                  ),
                ],
              ),
            ),
            if (customer.addresses.isNotEmpty) ...[
              const SizedBox(height: 12),
              SectionCard(
                title: context.tr('addresses'),
                child: Column(
                  children: [
                    for (final address in customer.addresses)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(address.label ?? address.oneLine),
                        subtitle: Text(address.oneLine),
                      ),
                  ],
                ),
              ),
            ],
            if (customer.notes != null &&
                customer.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              SectionCard(
                title: context.tr('notes'),
                child: Text(customer.notes!),
              ),
            ],
            const SizedBox(height: 16),
            AppButton(
              label: context.tr('orders'),
              variant: AppButtonVariant.outlined,
              expand: true,
              icon: Icons.receipt_long_outlined,
              onPressed: () => context.go(RoutePaths.orders),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.id});

  final int? id;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();

  String _status = 'active';
  bool _loading = false;
  bool _submitting = false;
  String? _error;

  bool get _isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final customer =
          await ref.read(customerRepositoryProvider).get(widget.id!);
      if (!mounted) return;
      setState(() {
        _name.text = customer.name;
        _email.text = customer.email ?? '';
        _phone.text = customer.phone ?? '';
        _notes.text = customer.notes ?? '';
        _status = customer.status;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final draft = CustomerDraft(
      name: _name.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      status: _status,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );

    try {
      if (_isEditing) {
        await ref.read(customerActionsProvider).update(widget.id!, draft);
      } else {
        await ref.read(customerActionsProvider).create(draft);
      }
      if (!mounted) return;
      AppSnack.show(
        context,
        context.tr(_isEditing ? 'customerUpdated' : 'customerCreated'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(_isEditing ? 'editCustomer' : 'createCustomer')),
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : SafeArea(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: [
                        AppTextField(
                          controller: _name,
                          label: context.tr('customerName'),
                          prefixIcon: Icons.person_outline,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? context.tr('requiredField')
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _email,
                          label: context.tr('email'),
                          helper: context.tr('optional'),
                          prefixIcon: Icons.alternate_email,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.optionalEmail,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _phone,
                          label: context.tr('phone'),
                          helper: context.tr('optional'),
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _status,
                          decoration: InputDecoration(
                            labelText: context.tr('customerStatus'),
                          ),
                          items: [
                            for (final status in const [
                              'active',
                              'inactive',
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
                          controller: _notes,
                          label: context.tr('notes'),
                          helper: context.tr('optional'),
                          maxLines: 4,
                          minLines: 3,
                        ),
                        const SizedBox(height: 18),
                        AppButton(
                          label: context.tr(
                            _isEditing ? 'saveChanges' : 'createCustomer',
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
