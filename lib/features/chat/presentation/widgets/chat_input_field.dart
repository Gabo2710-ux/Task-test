import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/error_formatter.dart';
import '../providers/chat_provider.dart';

class ChatInputField extends ConsumerStatefulWidget {
  final String taskId;

  const ChatInputField({super.key, required this.taskId});

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref.read(sendMessageProvider.notifier).sendMessage(widget.taskId, text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(sendMessageProvider, (previous, next) {
      if (next is AsyncData && previous is AsyncLoading) {
        _controller.clear();
      } else if (next is AsyncError) {
        final errorStr = formatError(next.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorStr),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

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
