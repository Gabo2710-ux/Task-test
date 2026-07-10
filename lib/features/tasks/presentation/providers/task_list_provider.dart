import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final taskListProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  
  final allTasks = await repository.getTasks();
  
  if (searchQuery.isEmpty) return allTasks;
  
  return allTasks.where((task) {
    return task.title.toLowerCase().contains(searchQuery) ||
           task.description.toLowerCase().contains(searchQuery) ||
           task.location.toLowerCase().contains(searchQuery) ||
           task.reference.toLowerCase().contains(searchQuery);
  }).toList();
});

