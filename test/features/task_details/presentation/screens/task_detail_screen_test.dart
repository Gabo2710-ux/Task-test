import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba/features/tasks/models/task_model.dart';
import 'package:prueba/features/task_details/presentation/screens/task_detail_screen.dart';
import 'package:prueba/features/task_details/presentation/providers/task_detail_provider.dart';

void main() {
  Widget createWidgetUnderTest(AsyncValue<TaskModel> mockState) {
    return ProviderScope(
      overrides: [
        taskDetailProvider('task_1').overrideWith((ref) => mockState.when(
          data: (d) => d,
          error: (e, st) => throw e,
          loading: () async {
            return Future.delayed(const Duration(days: 1), () => throw Exception());
          },
        )),
      ],
      child: const MaterialApp(
        home: TaskDetailScreen(taskId: 'task_1'),
      ),
    );
  }

  testWidgets('TaskDetailScreen displays loading state', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const AsyncLoading()));
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('TaskDetailScreen displays error state gracefully', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(AsyncError('Network Error', StackTrace.empty)));
    
    expect(find.textContaining('Error:'), findsOneWidget);
  });

  testWidgets('TaskDetailScreen displays task details', (WidgetTester tester) async {
    final task = TaskModel(
      id: 'task_1',
      reference: 'REF-1',
      title: 'Detailed Task',
      description: 'Full Description Here',
      status: 'pending',
      priority: 'high',
      location: 'Warehouse A',
    );

    await tester.pumpWidget(createWidgetUnderTest(AsyncData(task)));
    await tester.pumpAndSettle();
    
    expect(find.text('Detailed Task'), findsOneWidget);
    expect(find.text('Full Description Here'), findsOneWidget);
    expect(find.text('Warehouse A'), findsOneWidget);
  });
}
