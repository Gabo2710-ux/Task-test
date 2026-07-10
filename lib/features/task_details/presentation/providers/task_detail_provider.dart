import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_detail_model.dart';
import '../../repositories/task_detail_repository.dart';
import '../../../tasks/presentation/providers/task_list_provider.dart';

final taskDetailRepositoryProvider = Provider<TaskDetailRepository>((ref) {
  return TaskDetailRepository();
});

// FutureProvider para obtener el detalle de una tarea según su ID
final taskDetailProvider = FutureProvider.family<TaskDetailModel, String>((ref, taskId) async {
  final repository = ref.watch(taskDetailRepositoryProvider);
  return repository.getTaskDetail(taskId);
});

// Notifier para manejar el proceso de actualización del estado de una tarea
class UpdateTaskStatusNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> updateStatus(String taskId, String newStatus, String note, {bool hasImage = false}) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(taskDetailRepositoryProvider);
      await repository.updateTaskStatus(taskId, newStatus, note, hasImage: hasImage);
      
      // Invalidar el proveedor para que se recargue la pantalla de detalle
      ref.invalidate(taskDetailProvider(taskId));
      
      // Invalidar el proveedor de la lista de tareas
      ref.invalidate(taskListProvider);
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final updateTaskStatusProvider = NotifierProvider<UpdateTaskStatusNotifier, AsyncValue<void>>(() {
  return UpdateTaskStatusNotifier();
});
