import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/paginated_response.dart';
import '../../models/task_model.dart';
import '../../repositories/task_repository.dart';
// Proveedor del repositorio
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

// Proveedor de la búsqueda actual usando Notifier (Riverpod 3.x)
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateSearch(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

class TaskStatusFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void updateStatus(String? value) {
    state = value;
  }
}

final taskStatusFilterProvider = NotifierProvider<TaskStatusFilterNotifier, String?>(() {
  return TaskStatusFilterNotifier();
});

final taskListProvider = FutureProvider<PaginatedResponse<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final statusFilter = ref.watch(taskStatusFilterProvider);
  
  // Debounce logic: Delay request to avoid firing on every keystroke
  var didDispose = false;
  ref.onDispose(() => didDispose = true);
  await Future.delayed(const Duration(milliseconds: 500));
  if (didDispose) {
    throw Exception('Cancelled due to debounce');
  }
  
  // Stale response protection
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel('Cancelled by new search query'));

  return repository.getTasks(
    search: searchQuery,
    status: statusFilter,
    page: 1, // Currently loading first page
    perPage: 20,
    cancelToken: cancelToken,
  );
});
