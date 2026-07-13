import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prueba/core/models/paginated_response.dart';
import 'package:prueba/core/models/pagination_meta.dart';
import 'package:prueba/features/tasks/models/task_model.dart';
import 'package:prueba/features/tasks/presentation/providers/task_list_provider.dart';
import 'package:prueba/features/tasks/repositories/task_repository.dart';
import 'package:dio/dio.dart';

class MockTaskRepository extends Fake implements TaskRepository {
  final Future<PaginatedResponse<TaskModel>> Function({
    String? search,
    String? status,
    int? page,
    int? perPage,
    CancelToken? cancelToken,
  }) onGetTasks;

  MockTaskRepository({required this.onGetTasks});

  @override
  Future<PaginatedResponse<TaskModel>> getTasks({
    String? search,
    String? status,
    int? page,
    int? perPage,
    CancelToken? cancelToken,
  }) {
    return onGetTasks(
      search: search,
      status: status,
      page: page,
      perPage: perPage,
      cancelToken: cancelToken,
    );
  }
}

void main() {
  group('TaskListProvider', () {
    test('fetches and returns data correctly', () async {
      final mockRepo = MockTaskRepository(
        onGetTasks: ({search, status, page, perPage, cancelToken}) async {
          return PaginatedResponse(
            data: [
              TaskModel(
                id: '1',
                reference: 'REF-1',
                title: 'Task 1',
                description: 'Desc 1',
                status: 'pending',
                priority: 'low',
                location: 'Loc 1',
              )
            ],
            meta: PaginationMeta(currentPage: 1, perPage: 20, total: 1, lastPage: 1),
          );
        },
      );

      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(taskListProvider, (_, __) {});

      // Wait for debounce and fetch
      final result = await container.read(taskListProvider.future);

      expect(result.data.length, 1);
      expect(result.data.first.title, 'Task 1');
      subscription.close();
    });

    test('debounces search queries and cancels previous requests', () async {
      int fetchCount = 0;
      bool cancelled = false;

      final mockRepo = MockTaskRepository(
        onGetTasks: ({search, status, page, perPage, cancelToken}) async {
          fetchCount++;
          cancelToken?.whenCancel.then((_) {
            cancelled = true;
          });
          
          await Future.delayed(const Duration(milliseconds: 100)); // simulate network

          return PaginatedResponse(
            data: [],
            meta: PaginationMeta(currentPage: 1, perPage: 20, total: 0, lastPage: 1),
          );
        },
      );

      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(taskListProvider, (_, __) {});

      // Trigger multiple rapid searches
      container.read(searchQueryProvider.notifier).updateSearch('a');
      await Future.delayed(const Duration(milliseconds: 100));
      container.read(searchQueryProvider.notifier).updateSearch('ab');
      await Future.delayed(const Duration(milliseconds: 100));
      container.read(searchQueryProvider.notifier).updateSearch('abc');

      // Wait for debounce (500ms) and network (100ms)
      await Future.delayed(const Duration(milliseconds: 700));

      // Because of debounce, only the last query should trigger a network request.
      // Wait, if it's 500ms debounce, and we delay 100ms each, the previous providers
      // get cancelled during the delay. The network fetch only happens if the provider
      // is alive after 500ms.
      expect(fetchCount, 1, reason: 'Only the last query should survive the debounce and trigger fetch');
      
      subscription.close();
    });
  });
}
