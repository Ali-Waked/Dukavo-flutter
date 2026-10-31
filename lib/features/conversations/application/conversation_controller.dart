import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/paginated.dart';
import '../../../core/pagination/paginated_notifier.dart';
import '../../../core/providers.dart';
import '../data/conversation_data.dart';
import '../domain/conversation_domain.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepositoryImpl(
    ConversationRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class ConversationListNotifier extends PaginatedNotifier<Conversation> {
  ConversationListNotifier(this._repository);

  final ConversationRepository _repository;

  String? search;
  String? status;
  String? channel;
  bool mine = false;
  bool unassigned = false;
  bool unread = false;

  @override
  Future<Paginated<Conversation>> fetchPage(int page) {
    return _repository.list(
      search: search,
      status: status,
      channel: channel,
      mine: mine,
      unassigned: unassigned,
      unread: unread,
      page: page,
    );
  }

  Future<void> setSearch(String value) async {
    final next = value.trim().isEmpty ? null : value.trim();
    if (next == search) return;
    search = next;
    await reload();
  }

  Future<void> setStatus(String? value) async {
    if (value == status) return;
    status = value;
    await reload();
  }

  Future<void> setChannel(String? value) async {
    if (value == channel) return;
    channel = value;
    await reload();
  }

  Future<void> setMine(bool value) async {
    if (value == mine) return;
    mine = value;
    await reload();
  }

  Future<void> setUnassigned(bool value) async {
    if (value == unassigned) return;
    unassigned = value;
    await reload();
  }

  Future<void> setUnread(bool value) async {
    if (value == unread) return;
    unread = value;
    await reload();
  }
}

final conversationListProvider = StateNotifierProvider<ConversationListNotifier,
    PaginatedState<Conversation>>((ref) {
  return ConversationListNotifier(ref.watch(conversationRepositoryProvider));
});

final conversationSummaryProvider = FutureProvider<ConversationSummary>((ref) {
  return ref.watch(conversationRepositoryProvider).summary();
});

final conversationDetailProvider =
    FutureProvider.family<Conversation, int>((ref, id) {
  return ref.watch(conversationRepositoryProvider).get(id);
});

final conversationAssigneesProvider =
    FutureProvider<List<ConversationAssignee>>((ref) {
  return ref.watch(conversationRepositoryProvider).assignees();
});

/// Messages arrive newest-first so an old thread can be paged backwards.
/// [items] keeps that server order; the UI reverses it for display.
class MessagesState {
  const MessagesState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  final List<ConversationMessage> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;

  MessagesState copyWith({
    List<ConversationMessage>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    int? currentPage,
    int? lastPage,
  }) {
    return MessagesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
    );
  }
}

class ConversationMessagesNotifier
    extends StateNotifier<MessagesState> {
  ConversationMessagesNotifier(this._repository, this.conversationId)
      : super(const MessagesState());

  final ConversationRepository _repository;
  final int conversationId;

  Future<void> loadInitial() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _repository.messages(conversationId);
      state = MessagesState(
        items: page.items,
        currentPage: page.meta.currentPage,
        lastPage: page.meta.lastPage,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> reload() async {
    state = const MessagesState();
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final page = await _repository.messages(
        conversationId,
        page: state.currentPage + 1,
      );
      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoadingMore: false,
        currentPage: page.meta.currentPage,
        lastPage: page.meta.lastPage,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false, error: error.toString());
    }
  }

  /// Put a just-sent message at the newest end without a refetch.
  void prepend(ConversationMessage message) {
    if (state.items.any((item) => item.id == message.id)) return;
    state = state.copyWith(items: [message, ...state.items]);
  }
}

final conversationMessagesProvider = StateNotifierProvider.autoDispose
    .family<ConversationMessagesNotifier, MessagesState, int>((ref, id) {
  return ConversationMessagesNotifier(
    ref.watch(conversationRepositoryProvider),
    id,
  );
});

class ConversationActions {
  ConversationActions(this._ref);

  final Ref _ref;

  Future<ConversationMessage> reply(int id, String body) async {
    final message = await _ref.read(conversationRepositoryProvider).reply(id, body);
    _afterSend(id, message);
    return message;
  }

  Future<ConversationMessage> note(int id, String body) async {
    final message = await _ref.read(conversationRepositoryProvider).note(id, body);
    _afterSend(id, message);
    return message;
  }

  Future<ConversationMessage> template(
    int id, {
    required String templateName,
    required String languageCode,
    List<String> parameters = const [],
  }) async {
    final message = await _ref.read(conversationRepositoryProvider).template(
          id,
          templateName: templateName,
          languageCode: languageCode,
          parameters: parameters,
        );
    _afterSend(id, message);
    return message;
  }

  Future<ConversationMessage> retry(int id, int messageId) async {
    final message =
        await _ref.read(conversationRepositoryProvider).retry(id, messageId);
    _afterSend(id, message);
    return message;
  }

  Future<Conversation> markRead(int id) async {
    final conversation =
        await _ref.read(conversationRepositoryProvider).markRead(id);
    _ref.invalidate(conversationDetailProvider(id));
    _ref.invalidate(conversationSummaryProvider);
    _ref.invalidate(conversationListProvider);
    return conversation;
  }

  Future<Conversation> assign(int id, int? userId) async {
    final conversation =
        await _ref.read(conversationRepositoryProvider).assign(id, userId);
    _refreshConversation(id);
    return conversation;
  }

  Future<Conversation> updateStatus(int id, String status) async {
    final conversation =
        await _ref.read(conversationRepositoryProvider).updateStatus(id, status);
    _refreshConversation(id);
    return conversation;
  }

  void _afterSend(int id, ConversationMessage message) {
    _ref.read(conversationMessagesProvider(id).notifier).prepend(message);
    _refreshConversation(id);
  }

  void _refreshConversation(int id) {
    _ref.invalidate(conversationDetailProvider(id));
    _ref.invalidate(conversationListProvider);
    _ref.invalidate(conversationSummaryProvider);
  }
}

final conversationActionsProvider =
    Provider<ConversationActions>(ConversationActions.new);
