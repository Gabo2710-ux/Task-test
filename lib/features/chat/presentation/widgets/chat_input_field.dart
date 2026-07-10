import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';

class ChatInputField extends ConsumerStatefulWidget {
  final String taskId;

  const ChatInputField({super.key, required this.taskId});

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref.read(sendMessageProvider.notifier).sendMessage(widget.taskId, text).then((_) {
      if (mounted) {
        _controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSending = ref.watch(sendMessageProvider) is AsyncLoading;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: isSending ? null : _sendMessage,
            icon: isSending 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
