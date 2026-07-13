import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba/core/models/paginated_response.dart';
import 'package:prueba/core/models/pagination_meta.dart';
import 'package:prueba/features/tasks/models/task_model.dart';
import 'package:prueba/features/tasks/presentation/screens/task_list_screen.dart';
import 'package:prueba/features/tasks/presentation/providers/task_list_provider.dart';

void main() {
  Widget createWidgetUnderTest(AsyncValue<PaginatedResponse<TaskModel>> mockState) {
    return ProviderScope(
      overrides: [
        taskListProvider.overrideWith((ref) => mockState.when(
          data: (d) => d,
          error: (e, st) => throw e,
          loading: () async {
            // Keep loading forever to test loading state
            return Future.delayed(const Duration(days: 1), () => throw Exception());
          },
        )),
      ],
      child: const MaterialApp(
        home: TaskListScreen(),
      ),
    );
  }

  testWidgets('TaskListScreen displays loading state', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const AsyncLoading()));
    
    // Expect CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('TaskListScreen displays error state gracefully', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(AsyncError('Network Error', StackTrace.empty)));
    
    // Expect error text
    expect(find.textContaining('Error:'), findsOneWidget);
  });

  testWidgets('TaskListScreen displays empty state', (WidgetTester tester) async {
    final response = PaginatedResponse<TaskModel>(
      data: [],
      meta: PaginationMeta(currentPage: 1, perPage: 20, total: 0, lastPage: 1),
    );

    await tester.pumpWidget(createWidgetUnderTest(AsyncData(response)));
    await tester.pumpAndSettle();
    
    // Expect empty list text
    expect(find.text('No tasks found.'), findsOneWidget);
  });

  testWidgets('TaskListScreen displays list of tasks', (WidgetTester tester) async {
    final response = PaginatedResponse<TaskModel>(
      data: [
        TaskModel(
          id: '1',
          reference: 'REF-1',
          title: 'Test Task 1',
          description: 'Desc 1',
          status: 'pending',
          priority: 'low',
          location: 'Loc 1',
        ),
      ],
      meta: PaginationMeta(currentPage: 1, perPage: 20, total: 1, lastPage: 1),
    );

    await tester.pumpWidget(createWidgetUnderTest(AsyncData(response)));
    await tester.pumpAndSettle();
    
    expect(find.text('Test Task 1'), findsOneWidget);
    expect(find.text('REF-1'), findsOneWidget);
  });
}
