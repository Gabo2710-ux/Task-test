import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/task_list_provider.dart';
import '../../../../core/utils/validators.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(taskRepositoryProvider);
      await repository.addTask(
        title: _titleController.text,
        description: _descController.text,
        location: _locationController.text,
      );
      
      // Refresh task list
      ref.invalidate(taskListProvider);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Task',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              maxLength: 50,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final requiredError = Validators.requiredField(v, message: 'Please enter a title');
                if (requiredError != null) return requiredError;
                return Validators.maxLength(v, 50, message: 'Title must be 50 characters or less');
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              maxLength: 200,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final requiredError = Validators.requiredField(v, message: 'Please enter a description');
                if (requiredError != null) return requiredError;
                return Validators.maxLength(v, 200, message: 'Description must be 200 characters or less');
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              maxLength: 100,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (v) {
                final requiredError = Validators.requiredField(v, message: 'Please enter a location');
                if (requiredError != null) return requiredError;
                return Validators.maxLength(v, 100, message: 'Location must be 100 characters or less');
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Create Task',
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
