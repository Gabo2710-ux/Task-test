import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../task_details/presentation/providers/task_detail_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_field.dart';

class TaskChatScreen extends ConsumerWidget {
  final String taskId;

  const TaskChatScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesState = ref.watch(chatMessagesProvider(taskId));
    final taskState = ref.watch(taskDetailProvider(taskId));

    final String titleText = taskState.maybeWhen(
      data: (task) => 'Chat: ${task.reference}',
      orElse: () => 'Chat',
    );

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFE5DDD5), // WhatsApp-like background
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titleText, style: const TextStyle(fontSize: 18)),
            if (messagesState is AsyncData)
              Text(
                messagesState.value!.participants.map((p) => p.name).join(', '),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (response) {
                final messages = response.messages;
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
            color: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
            child: ChatInputField(taskId: taskId),
          ),
        ],
      ),
    );
  }
}
