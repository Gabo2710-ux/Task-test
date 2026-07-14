import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../providers/task_list_provider.dart';
import '../widgets/task_list_item.dart';
import '../../../../core/widgets/empty_state_view.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/error_formatter.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(taskListProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final status = ref.watch(taskStatusFilterProvider);
              return PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  ref.read(taskStatusFilterProvider.notifier).updateStatus(value == '' ? null : value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: '',
                    child: Text('All'),
                  ),
                  const PopupMenuItem(
                    value: 'pending',
                    child: Text('Pending'),
                  ),
                  const PopupMenuItem(
                    value: 'in_progress',
                    child: Text('In Progress'),
                  ),
                  const PopupMenuItem(
                    value: 'completed',
                    child: Text('Completed'),
                  ),
                  const PopupMenuItem(
                    value: 'blocked',
                    child: Text('Blocked'),
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                filled: true,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).updateSearch(value);
              },
            ),
          ),
        ),
      ),
      body: tasksState.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          // Do not show error if it's just a debounce cancellation
          if (error.toString().contains('Cancelled')) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${formatError(error)}',
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => ref.refresh(taskListProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        data: (paginatedResponse) {
          final tasks = paginatedResponse.data;
          
          if (tasks.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                // Wait for the provider to complete the next fetch
                return ref.refresh(taskListProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  EmptyStateView(
                    title: 'No tasks found',
                    message: 'Create a new task to get started.',
                    icon: Icons.task_alt,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh and wait for future to complete
              return ref.refresh(taskListProvider.future);
            },
            child: ListView.builder(
              itemCount: tasks.length + 1,
              itemBuilder: (context, index) {
                if (index == tasks.length) {
                  final meta = paginatedResponse.meta;
                  if (meta.currentPage < meta.lastPage) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('Load more items (Pagination UI)')),
                    );
                  }
                  return const SizedBox.shrink();
                }
                
                final task = tasks[index];
                return TaskListItem(
                  task: task,
                  onTap: () {
                    context.push('/task/${task.id}');
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddTaskBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
