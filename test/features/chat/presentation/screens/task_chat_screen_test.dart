import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba/features/chat/presentation/screens/task_chat_screen.dart';
import 'package:prueba/features/chat/presentation/providers/chat_provider.dart';
import 'package:prueba/features/chat/models/chat_response_model.dart';
import 'package:prueba/features/chat/models/chat_message_model.dart';
import 'package:prueba/features/tasks/models/user_model.dart';

void main() {
  Widget createWidgetUnderTest(AsyncValue<ChatResponseModel> mockState) {
    return ProviderScope(
      overrides: [
        chatMessagesProvider('task_1001').overrideWith((ref) => mockState.when(
          data: (d) => d,
          error: (e, st) => throw e,
          loading: () async {
            // Keep it loading forever
            return Future.delayed(const Duration(days: 1), () => throw Exception());
          },
        )),
      ],
      child: const MaterialApp(
        home: TaskChatScreen(taskId: 'task_1001'),
      ),
    );
  }

  testWidgets('TaskChatScreen displays loading state', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const AsyncLoading()));
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('TaskChatScreen displays initial error state', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(AsyncError('Network failed', StackTrace.empty)));
    
    expect(find.text('Error: Network failed'), findsOneWidget);
  });

  testWidgets('TaskChatScreen displays empty state', (WidgetTester tester) async {
    final response = ChatResponseModel(messages: [], participants: []);
    await tester.pumpWidget(createWidgetUnderTest(AsyncData(response)));
    
    expect(find.text('No messages yet.'), findsOneWidget);
  });

  testWidgets('TaskChatScreen displays messages, task ID, and participants in header', (WidgetTester tester) async {
    final participant = UserModel(id: 'u2', name: 'Jamie Lee');
    final response = ChatResponseModel(
      messages: [
        ChatMessageModel(
          id: '1',
          taskId: 'task_1001',
          type: 'text',
          content: 'Hello World',
          sender: participant,
          createdAt: '2026-07-10T09:15:00Z',
        ),
      ],
      participants: [participant],
    );

    await tester.pumpWidget(createWidgetUnderTest(AsyncData(response)));
    await tester.pumpAndSettle();

    // Verify header
    expect(find.text('Chat: task_1001'), findsOneWidget);
    expect(find.text('Jamie Lee'), findsOneWidget); // Subtitle

    // Verify message
    expect(find.text('Hello World'), findsOneWidget);
    
    // Verify sender displayed belongs to participants
    expect(find.text('Jamie Lee'), findsWidgets); // One in appbar, one in chat bubble
  });
}
