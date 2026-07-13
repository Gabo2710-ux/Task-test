import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:prueba/features/chat/presentation/providers/chat_provider.dart';
import 'package:prueba/features/chat/repositories/chat_repository.dart';
import 'package:prueba/features/chat/models/chat_message_model.dart';
import 'package:prueba/features/tasks/models/user_model.dart';

class FakeChatRepository extends Fake implements ChatRepository {
  bool shouldFail = false;

  @override
  Future<ChatMessageModel> sendMessage(String taskId, String content) async {
    if (shouldFail) {
      throw Exception('Network connection lost');
    }
    return ChatMessageModel(
      id: '1',
      taskId: taskId,
      type: 'text',
      content: content,
      sender: UserModel(id: 'u1', name: 'Alex'),
    );
  }
}

void main() {
  testWidgets('Input field preserves text on failure, clears on success', (WidgetTester tester) async {
    final fakeRepo = FakeChatRepository();
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ChatInputField(taskId: 'task1'),
          ),
        ),
      ),
    );

    // Fail case
    fakeRepo.shouldFail = true;
    final textField = find.byType(TextField);
    
    await tester.enterText(textField, 'Hello World');
    await tester.tap(find.byType(IconButton));
    
    await tester.pump(); // Start loading
    await tester.pump(); // End loading, show error

    // Verify text is preserved
    expect(find.text('Hello World'), findsOneWidget);
    // Verify SnackBar shown
    expect(find.textContaining('Network connection lost'), findsOneWidget);

    // Success case
    fakeRepo.shouldFail = false;
    await tester.tap(find.byType(IconButton));
    
    await tester.pump(); // Start loading
    await tester.pump(); // End loading, clear text
    
    // Verify text is cleared
    expect(find.text('Hello World'), findsNothing);
  });
  
  testWidgets('Input field rejects empty spaces', (WidgetTester tester) async {
    final fakeRepo = FakeChatRepository();
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ChatInputField(taskId: 'task1'),
          ),
        ),
      ),
    );

    final textField = find.byType(TextField);
    
    await tester.enterText(textField, '    ');
    await tester.tap(find.byType(IconButton));
    
    // It should just return, no loading state, no text clear, no fakeRepo call
    await tester.pump();
    expect(find.text('    '), findsOneWidget);
  });

  testWidgets('Input field disables button while sending to prevent duplicates', (WidgetTester tester) async {
    final fakeRepo = FakeChatRepository();
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ChatInputField(taskId: 'task1'),
          ),
        ),
      ),
    );

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Hello World');
    
    // Tap the button
    final button = find.byType(IconButton);
    await tester.tap(button);
    await tester.pump(); // trigger loading state

    // The icon should change to CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // The button should be disabled, meaning onPressed is null.
    final iconButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(iconButton.onPressed, isNull);

    await tester.pump(); // End loading
  });
}
