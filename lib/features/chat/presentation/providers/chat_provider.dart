import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_message_model.dart';
import '../../repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

// Provider para la lista de mensajes de una tarea
final chatMessagesProvider = FutureProvider.family<List<ChatMessageModel>, String>((ref, taskId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMessages(taskId);
});

// Provider para el envío de un nuevo mensaje
class SendMessageNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> sendMessage(String taskId, String content) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(chatRepositoryProvider);
      // You send the message
      await repository.sendMessage(taskId, content);
      ref.invalidate(chatMessagesProvider(taskId));
      state = const AsyncData(null);
      
      // Simulate a bot reply after 2 seconds
      Future.delayed(const Duration(seconds: 2), () async {
        final mockReplies = [
          "Got it! I'll keep an eye on it.",
          "Perfect, thanks for letting me know.",
          "I'm heading there right now.",
          "Do you need any help with that?",
          "Awesome, let me check that for you.",
          "Sounds like a plan!",
          "I'll notify the rest of the team."
        ];
        mockReplies.shuffle();
        final mockReply = mockReplies.first;
        
        final mockSenders = [
          { 'id': 'user_002', 'name': 'Malquitos', 'avatar': 'https://example.test/images/users/user_002.jpg' },
          { 'id': 'user_003', 'name': 'Taylor Smith', 'avatar': 'https://example.test/images/users/user_003.jpg' },
          { 'id': 'user_004', 'name': 'Sam Wilson', 'avatar': 'https://example.test/images/users/user_004.jpg' }
        ];
        mockSenders.shuffle();
        final sender = mockSenders.first;
        
        await repository.sendMessage(
          taskId, 
          mockReply,
          senderId: sender['id']!,
          senderName: sender['name']!,
          avatarUrl: sender['avatar']!,
        );
        
        // Refresh messages
        ref.invalidate(chatMessagesProvider(taskId));
      });
      
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final sendMessageProvider = NotifierProvider<SendMessageNotifier, AsyncValue<void>>(() {
  return SendMessageNotifier();
});
