// lib/providers/conversation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation_summary.dart';
import '../repositories/conversation_repository.dart';

/// Repository provider (inject để dễ mock trong tests)
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepository();
});

/// Simple FutureProvider for one-off reads (autoDispose helps free resources)
final conversationsProvider = FutureProvider.autoDispose<List<ConversationSummary>>((ref) async {
  final repo = ref.read(conversationRepositoryProvider);
  // default page=0, size=50
  return await repo.fetchConversations(page: 0, size: 50);
});

/// StateNotifier for more control (loading state, manual refresh)
class ConversationListNotifier extends StateNotifier<AsyncValue<List<ConversationSummary>>> {
  final ConversationRepository _repo;
  final int page;
  final int size;

  ConversationListNotifier(this._repo, {this.page = 0, this.size = 50})
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repo.fetchConversations(page: page, size: size);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => load();

  /// mark conversation read locally (optional): you may want to update unreadCount locally
  void markReadLocal(int conversationId) {
    state.whenData((list) {
      final updated = list.map((c) {
        if (c.id == conversationId) {
          return ConversationSummary(
            id: c.id,
            title: c.title,
            lastMessage: c.lastMessage,
            lastUpdatedAt: c.lastUpdatedAt,
            avatarUrl: c.avatarUrl,
            unreadCount: 0,
          );
        }
        return c;
      }).toList();
      state = AsyncValue.data(updated);
    });
  }
}

/// Provider for the notifier
final conversationListStateProvider =
StateNotifierProvider.autoDispose<ConversationListNotifier, AsyncValue<List<ConversationSummary>>>(
        (ref) {
      final repo = ref.read(conversationRepositoryProvider);
      return ConversationListNotifier(repo);
    });
