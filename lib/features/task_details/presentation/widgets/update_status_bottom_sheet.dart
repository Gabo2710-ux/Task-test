import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/task_detail_provider.dart';

class UpdateStatusBottomSheet extends ConsumerStatefulWidget {
  final String taskId;
  final String currentStatus;

  const UpdateStatusBottomSheet({super.key, required this.taskId, required this.currentStatus});

  @override
  ConsumerState<UpdateStatusBottomSheet> createState() => _UpdateStatusBottomSheetState();
}

class _UpdateStatusBottomSheetState extends ConsumerState<UpdateStatusBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStatus;
  final _noteController = TextEditingController();
  XFile? _imageFile;
  final _picker = ImagePicker();

  final List<String> _statuses = ['pending', 'in_progress', 'blocked', 'completed'];

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStatus == null) return;
    
    if (_selectedStatus == widget.currentStatus) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El estatus debe ser diferente al actual')));
      return;
    }
    
    final note = _noteController.text.trim();

    ref.read(updateTaskStatusProvider.notifier).updateStatus(
      widget.taskId, 
      _selectedStatus!, 
      note, 
      hasImage: _imageFile != null,
    ).then((_) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                SizedBox(height: 16),
                Text('¡Estatus actualizado!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = ref.watch(updateTaskStatusProvider) is AsyncLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update Task Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              hint: const Text('Select new status'),
              items: _statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedStatus = value),
              validator: (value) => value == null ? 'Please select a status' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Required)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            if (_imageFile != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(
                        _imageFile!.path,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_imageFile!.path),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text('Image attached successfully', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUpdating ? null : _submit,
                child: isUpdating 
                  ? const CircularProgressIndicator()
                  : const Text('Submit Update'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
