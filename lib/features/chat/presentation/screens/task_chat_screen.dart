import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_field.dart';

class TaskChatScreen extends ConsumerWidget {
  final String taskId;

  const TaskChatScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesState = ref.watch(chatMessagesProvider(taskId));

    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5), // WhatsApp-like background
      appBar: AppBar(
        title: const Text('Task Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }
                
                // Reversed so ListView can build from bottom up
                final reversedMessages = messages.reversed.toList();
                
                return ListView.builder(
                  reverse: true, // This makes the list start from the bottom
                  itemCount: reversedMessages.length,
                  itemBuilder: (context, index) {
                    final message = reversedMessages[index];
                    // Simulamos que el usuario actual es user_001
                    final isMe = message.sender.id == 'user_001';
                    return ChatBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            child: ChatInputField(taskId: taskId),
          ),
        ],
      ),
    );
  }
}
