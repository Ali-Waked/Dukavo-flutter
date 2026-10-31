import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/conversation_controller.dart';
import '../domain/conversation_domain.dart';

const _conversationStatuses = <String>['open', 'pending', 'closed'];
const _conversationChannels = <String>['whatsapp', 'web', 'manual', 'other'];

String _channelLabel(BuildContext context, String channel) {
  switch (channel) {
    case 'whatsapp':
      return context.tr('whatsapp');
    case 'web':
      return context.tr('web');
    case 'manual':
      return context.tr('manual');
    default:
      return channel;
  }
}

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationListProvider.notifier).loadInitial();
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
    final state = ref.watch(conversationListProvider);
    final notifier = ref.read(conversationListProvider.notifier);
    final summary = ref.watch(conversationSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('conversations')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () {
              notifier.reload();
              ref.invalidate(conversationSummaryProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          summary.maybeWhen(
            data: (data) => _SummaryStrip(summary: data, notifier: notifier),
            orElse: () => const SizedBox(height: 8),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: SearchField(
              controller: _search,
              hint: context.tr('searchConversations'),
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
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FilterChip(
                    label: Text(context.tr('unreadOnly')),
                    selected: notifier.unread,
                    onSelected: notifier.setUnread,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FilterChip(
                    label: Text(context.tr('mine')),
                    selected: notifier.mine,
                    onSelected: notifier.setMine,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FilterChip(
                    label: Text(context.tr('unassigned')),
                    selected: notifier.unassigned,
                    onSelected: notifier.setUnassigned,
                  ),
                ),
                for (final status in _conversationStatuses)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(context.tr(status)),
                      selected: notifier.status == status,
                      onSelected: (_) => notifier.setStatus(
                        notifier.status == status ? null : status,
                      ),
                    ),
                  ),
                PopupMenuButton<String?>(
                  tooltip: context.tr('channelFilter'),
                  onSelected: notifier.setChannel,
                  itemBuilder: (context) => [
                    PopupMenuItem<String?>(
                      value: null,
                      child: Text(context.tr('all')),
                    ),
                    for (final channel in _conversationChannels)
                      PopupMenuItem<String?>(
                        value: channel,
                        child: Text(_channelLabel(context, channel)),
                      ),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.tune, size: 16),
                    label: Text(
                      notifier.channel == null
                          ? context.tr('channelFilter')
                          : _channelLabel(context, notifier.channel!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PagedListView<Conversation>(
              state: state,
              onRefresh: notifier.reload,
              onLoadMore: notifier.loadMore,
              empty: EmptyState(
                title: context.tr('noConversations'),
                icon: Icons.forum_outlined,
              ),
              itemBuilder: (context, conversation, index) =>
                  _ConversationTile(conversation: conversation),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.summary, required this.notifier});

  final ConversationSummary summary;
  final ConversationListNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        children: [
          _SummaryCard(
            label: context.tr('open'),
            value: summary.open,
            color: AppColors.primary,
            onTap: () => notifier.setStatus('open'),
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: context.tr('pending'),
            value: summary.pending,
            color: AppColors.warning,
            onTap: () => notifier.setStatus('pending'),
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: context.tr('unassigned'),
            value: summary.unassigned,
            color: AppColors.info,
            onTap: () => notifier.setUnassigned(true),
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: context.tr('unread'),
            value: summary.unread,
            color: AppColors.danger,
            onTap: () => notifier.setUnread(true),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 108,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: color),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = conversation.lastMessage;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push(RoutePaths.conversation(conversation.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Badge(
                isLabelVisible: conversation.unreadCount > 0,
                label: Text(
                  conversation.unreadCount > 99
                      ? '99+'
                      : '${conversation.unreadCount}',
                ),
                child: AppAvatar(name: conversation.title, size: 46),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.title,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          Formatters.relative(
                            conversation.lastMessageAt ?? conversation.createdAt,
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      last?.body?.trim().isNotEmpty == true
                          ? last!.body!
                          : context.tr('noMessages'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: last?.isInternal == true
                            ? FontStyle.italic
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          conversation.channel == 'whatsapp'
                              ? Icons.chat_outlined
                              : Icons.public,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _channelLabel(context, conversation.channel),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusChip(status: conversation.status, compact: true),
                        const Spacer(),
                        if (conversation.assignee != null)
                          Flexible(
                            child: Text(
                              conversation.assignee!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
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
        ),
      ),
    );
  }
}

class ConversationThreadScreen extends ConsumerStatefulWidget {
  const ConversationThreadScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<ConversationThreadScreen> createState() =>
      _ConversationThreadScreenState();
}

class _ConversationThreadScreenState
    extends ConsumerState<ConversationThreadScreen> {
  final _reply = TextEditingController();
  bool _sending = false;
  bool _noteMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationMessagesProvider(widget.id).notifier).loadInitial();
      _markRead();
    });
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _markRead() async {
    try {
      await ref.read(conversationActionsProvider).markRead(widget.id);
    } catch (_) {
      // Reading is a convenience; a failure must not block the thread.
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(conversationDetailProvider(widget.id));
    final messages = ref.watch(conversationMessagesProvider(widget.id));
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: detail.maybeWhen(
          data: (conversation) => Text(conversation.title),
          orElse: () => const Text(''),
        ),
        actions: [
          if (permissions.canAssignConversations)
            IconButton(
              tooltip: context.tr('assignTo'),
              onPressed: _assign,
              icon: const Icon(Icons.person_add_alt),
            ),
          if (permissions.canAssignConversations)
            PopupMenuButton<String>(
              tooltip: context.tr('changeStatus'),
              onSelected: _changeStatus,
              itemBuilder: (context) => [
                for (final status in _conversationStatuses)
                  PopupMenuItem(
                    value: status,
                    child: Text(context.tr(status)),
                  ),
              ],
            ),
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () {
              ref.invalidate(conversationDetailProvider(widget.id));
              ref
                  .read(conversationMessagesProvider(widget.id).notifier)
                  .reload();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          detail.maybeWhen(
            data: (conversation) => _ThreadHeader(conversation: conversation),
            orElse: () => const SizedBox.shrink(),
          ),
          Expanded(
            child: messages.isLoading
                ? const LoadingView()
                : messages.error != null && messages.items.isEmpty
                    ? ErrorView(
                        message: messages.error!,
                        onRetry: () => ref
                            .read(
                              conversationMessagesProvider(widget.id).notifier,
                            )
                            .reload(),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        itemCount: messages.items.length +
                            (messages.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= messages.items.length) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: messages.isLoadingMore
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: () => ref
                                            .read(
                                              conversationMessagesProvider(
                                                widget.id,
                                              ).notifier,
                                            )
                                            .loadMore(),
                                        child: Text(context.tr('loadMore')),
                                      ),
                              ),
                            );
                          }
                          final message = messages.items[index];
                          return _MessageBubble(
                            message: message,
                            onRetry: message.canRetry == true
                                ? () => _retry(message)
                                : null,
                          );
                        },
                      ),
          ),
          detail.maybeWhen(
            data: (conversation) => _Composer(
              conversation: conversation,
              controller: _reply,
              sending: _sending,
              noteMode: _noteMode,
              canReply: permissions.canReplyConversations,
              onNoteModeChanged: (value) => setState(() => _noteMode = value),
              onSend: _send,
              onTemplate: _sendTemplate,
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final body = _reply.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      if (_noteMode) {
        await ref.read(conversationActionsProvider).note(widget.id, body);
      } else {
        await ref.read(conversationActionsProvider).reply(widget.id, body);
      }
      if (!mounted) return;
      _reply.clear();
      setState(() => _sending = false);
      AppSnack.show(
        context,
        context.tr(_noteMode ? 'noteSent' : 'messageSent'),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _retry(ConversationMessage message) async {
    try {
      await ref
          .read(conversationActionsProvider)
          .retry(widget.id, message.id);
      if (!mounted) return;
      AppSnack.show(context, context.tr('messageSent'));
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _assign() async {
    final assignees = await ref.read(conversationAssigneesProvider.future);
    if (!mounted) return;
    // `-1` is the explicit "unassign" choice; a null result means the sheet
    // was dismissed and nothing should change.
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.person_off_outlined),
              title: Text(context.tr('unassigned')),
              onTap: () => Navigator.of(sheetContext).pop(-1),
            ),
            for (final assignee in assignees)
              ListTile(
                leading: AppAvatar(name: assignee.name, size: 36),
                title: Text(assignee.name),
                onTap: () => Navigator.of(sheetContext).pop(assignee.id),
              ),
          ],
        ),
      ),
    );
    if (!mounted || picked == null) return;
    try {
      await ref
          .read(conversationActionsProvider)
          .assign(widget.id, picked == -1 ? null : picked);
      if (!mounted) return;
      AppSnack.show(context, context.tr('preferencesUpdated'));
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _changeStatus(String status) async {
    try {
      await ref.read(conversationActionsProvider).updateStatus(widget.id, status);
      if (!mounted) return;
      AppSnack.show(context, context.tr('statusUpdated'));
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _sendTemplate() async {
    final draft = await showModalBottomSheet<_TemplateDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => const _TemplateSheet(),
    );
    if (draft == null || !mounted) return;
    setState(() => _sending = true);
    try {
      await ref.read(conversationActionsProvider).template(
            widget.id,
            templateName: draft.name,
            languageCode: draft.language,
            parameters: draft.parameters,
          );
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnack.show(context, context.tr('messageSent'));
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnack.show(context, error.toString(), isError: true);
    }
  }
}

class _ThreadHeader extends StatelessWidget {
  const _ThreadHeader({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  [
                    _channelLabel(context, conversation.channel),
                    if (conversation.phone != null) conversation.phone!,
                  ].join(' · '),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              StatusChip(status: conversation.status, compact: true),
            ],
          ),
          if (conversation.assignee != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${context.tr('assignedTo')}: ${conversation.assignee!.name}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (conversation.channel == 'whatsapp' &&
              conversation.replyWindow.requiresTemplate)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(Icons.lock_clock, size: 14, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      context.tr('replyWindowClosed'),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.onRetry});

  final ConversationMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (message.isNote) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sticky_note_2_outlined,
                    size: 14, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  context.tr('internalNote'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(message.body ?? ''),
            _MessageMeta(message: message),
          ],
        ),
      );
    }

    final inbound = message.isInbound;
    final bubbleColor = inbound ? scheme.surface : scheme.primary;
    final textColor = inbound ? scheme.onSurface : scheme.onPrimary;

    return Align(
      alignment: inbound ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(inbound ? 4 : 16),
            bottomRight: Radius.circular(inbound ? 16 : 4),
          ),
          border: inbound ? Border.all(color: scheme.outline) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.hasMedia)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, size: 14, color: textColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        message.mediaFilename ?? context.tr('attachment'),
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: textColor),
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              message.body ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Formatters.time(message.timestamp),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                if (message.authorName != null) ...[
                  Text(
                    ' · ${message.authorName}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                if (!inbound && message.deliveryStatusLabel != null) ...[
                  Text(
                    ' · ${message.deliveryStatusLabel}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
            if (message.isFailed) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      message.failureReason ?? context.tr('deliveryFailed'),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: scheme.onError),
                    ),
                  ),
                  if (onRetry != null)
                    TextButton(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                      ),
                      child: Text(context.tr('retry')),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageMeta extends StatelessWidget {
  const _MessageMeta({required this.message});

  final ConversationMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        [
          Formatters.time(message.timestamp),
          if (message.authorName != null) message.authorName!,
        ].join(' · '),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.conversation,
    required this.controller,
    required this.sending,
    required this.noteMode,
    required this.canReply,
    required this.onNoteModeChanged,
    required this.onSend,
    required this.onTemplate,
  });

  final Conversation conversation;
  final TextEditingController controller;
  final bool sending;
  final bool noteMode;
  final bool canReply;
  final ValueChanged<bool> onNoteModeChanged;
  final VoidCallback onSend;
  final VoidCallback onTemplate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requiresTemplate = conversation.channel == 'whatsapp' &&
        conversation.replyWindow.requiresTemplate;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ChoiceChip(
                  label: Text(context.tr('reply')),
                  selected: !noteMode,
                  onSelected: canReply ? (_) => onNoteModeChanged(false) : null,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(context.tr('internalNote')),
                  selected: noteMode,
                  onSelected: canReply ? (_) => onNoteModeChanged(true) : null,
                ),
                const Spacer(),
                if (conversation.channel == 'whatsapp')
                  TextButton.icon(
                    onPressed: canReply && !sending ? onTemplate : null,
                    icon: const Icon(Icons.article_outlined, size: 16),
                    label: Text(context.tr('templateName')),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: controller,
                    hint: noteMode
                        ? context.tr('noteHint')
                        : requiresTemplate
                            ? context.tr('templateRequired')
                            : context.tr('messageHint'),
                    maxLines: 4,
                    minLines: 1,
                    enabled: canReply && !requiresTemplate,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: context.tr('sendMessage'),
                  onPressed: canReply && !requiresTemplate && !sending
                      ? onSend
                      : null,
                  icon: sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateDraft {
  const _TemplateDraft({
    required this.name,
    required this.language,
    this.parameters = const [],
  });

  final String name;
  final String language;
  final List<String> parameters;
}

class _TemplateSheet extends StatefulWidget {
  const _TemplateSheet();

  @override
  State<_TemplateSheet> createState() => _TemplateSheetState();
}

class _TemplateSheetState extends State<_TemplateSheet> {
  final _name = TextEditingController();
  final _language = TextEditingController(text: 'en');
  final _parameters = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _language.dispose();
    _parameters.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('templateName'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _name,
                label: context.tr('templateName'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (!RegExp(r'^[a-z0-9_]+$').hasMatch(text)) {
                    return context.tr('requiredField');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _language,
                label: context.tr('languageCode'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (!RegExp(r'^[a-z]{2,3}(_[A-Z]{2})?$').hasMatch(text)) {
                    return context.tr('requiredField');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _parameters,
                label: context.tr('parameters'),
                helper: context.tr('requiredParameters'),
              ),
              const SizedBox(height: 14),
              AppButton(
                label: context.tr('sendTemplate'),
                expand: true,
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  Navigator.of(context).pop(
                    _TemplateDraft(
                      name: _name.text.trim(),
                      language: _language.text.trim(),
                      parameters: _parameters.text
                          .split(',')
                          .map((value) => value.trim())
                          .where((value) => value.isNotEmpty)
                          .toList(),
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
