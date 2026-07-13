import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_response_model.dart';
import '../../repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

// Provider para la lista de mensajes y participantes de una tarea
final chatMessagesProvider = FutureProvider.family<ChatResponseModel, String>((ref, taskId) async {
  final repository = ref.watch(chatRepositoryProvider);
  final response = await repository.getMessages(taskId);
  
  // Sort messages chronologically by created_at
  response.messages.sort((a, b) => a.parsedDate.compareTo(b.parsedDate));
  
  return response;
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
      await repository.sendMessage(taskId, content);
      ref.invalidate(chatMessagesProvider(taskId));
      state = const AsyncData(null);

      // El servidor mock (Node.js) tarda 2 segundos en generar la respuesta automática.
      // Refrescamos la lista después de 2.5 segundos para mostrar ese nuevo mensaje.
      Future.delayed(const Duration(milliseconds: 2500), () {
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
