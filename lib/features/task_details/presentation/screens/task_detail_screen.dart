import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../tasks/presentation/widgets/status_badge.dart';
import '../providers/task_detail_provider.dart';
import '../widgets/update_status_bottom_sheet.dart';
import '../widgets/status_timeline.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              context.push('/task/$taskId/chat');
            },
          )
        ],
      ),
      body: taskState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (task) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.reference,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    StatusBadge(status: task.status),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  task.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(task.description),
                const Divider(height: 32),
                const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(task.location),

                const Divider(height: 32),
                const Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                StatusTimeline(history: task.statusHistory),
              ],
            ),
          );
        },
      ),
      floatingActionButton: taskState.hasValue ? FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: UpdateStatusBottomSheet(
                taskId: taskId,
                currentStatus: taskState.value!.status,
              ),
            ),
          );
        },
        label: const Text('Update Status'),
        icon: const Icon(Icons.update),
      ) : null,
    );
  }
}
