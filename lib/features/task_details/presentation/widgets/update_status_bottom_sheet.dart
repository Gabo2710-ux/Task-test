import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/task_detail_provider.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/utils/error_formatter.dart';

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
  String? _validationError;

  final List<String> _statuses = ['pending', 'in_progress', 'blocked', 'completed'];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ref.read(imagePickerServiceProvider);
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _validationError = null; // Clear error on picking image
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied or feature unavailable: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image.')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  void _submit() {
    setState(() {
      _validationError = null;
    });

    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedStatus == null) return;
    
    if (_selectedStatus == widget.currentStatus) {
      setState(() {
        _validationError = 'The new status must be different from the current status.';
      });
      return;
    }
    
    final note = _noteController.text.trim();
    if (note.isEmpty && _imageFile == null) {
      setState(() {
        _validationError = 'A note or an image is required.';
      });
      return;
    }

    ref.read(updateTaskStatusProvider.notifier).updateStatus(
      widget.taskId, 
      _selectedStatus!, 
      note, 
      hasImage: _imageFile != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar el proveedor para determinar si fue exitoso o hubo error
    ref.listen<AsyncValue<void>>(
      updateTaskStatusProvider,
      (previous, next) {
        if (next is AsyncError) {
          // ScaffoldMessenger is often hidden behind the bottom sheet,
          // so we also update the local validation error state to show it inside the modal.
          if (mounted) {
            setState(() {
              _validationError = formatError(next.error);
            });
          }
        } else if (next is AsyncData && previous is AsyncLoading) {
          // Solamente si venimos de un Loading a un Data exitoso
          if (mounted) {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                    SizedBox(height: 16),
                    Text('Status updated!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
        }
      },
    );

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
              onChanged: isUpdating ? null : (value) => setState(() => _selectedStatus = value),
              validator: (value) => value == null ? 'Please select a status' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              enabled: !isUpdating,
              decoration: const InputDecoration(
                labelText: 'Note (Optional if image is attached)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (_validationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _validationError!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: isUpdating ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: isUpdating ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            if (_imageFile != null) ...[
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.topRight,
                children: [
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
                  if (!isUpdating)
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.white, size: 30),
                      onPressed: _removeImage,
                    ),
                ],
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
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Submit Update'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
