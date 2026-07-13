import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba/features/task_details/presentation/widgets/update_status_bottom_sheet.dart';
import 'package:prueba/features/task_details/presentation/providers/task_detail_provider.dart';
import 'package:prueba/features/task_details/repositories/task_detail_repository.dart';
import 'package:prueba/core/services/image_picker_service.dart';
import 'package:prueba/features/tasks/presentation/providers/task_list_provider.dart';

class FakeTaskDetailRepository extends Fake implements TaskDetailRepository {
  bool shouldFail = false;
  bool wasCalled = false;

  @override
  Future<void> updateTaskStatus(String taskId, String newStatus, String note, {bool hasImage = false}) async {
    wasCalled = true;
    if (shouldFail) {
      throw Exception('Network Error');
    }
    return;
  }
}

class FakeImagePickerService extends Fake implements ImagePickerService {
  bool returnNull = false;
  bool throwPermissionError = false;

  @override
  Future<XFile?> pickImage({required ImageSource source}) async {
    if (throwPermissionError) {
      throw PlatformException(code: 'camera_access_denied', message: 'Permission denied');
    }
    if (returnNull) {
      return null;
    }
    return XFile('fake_image.jpg');
  }
}

void main() {
  late FakeTaskDetailRepository repository;
  late FakeImagePickerService imagePickerService;

  setUp(() {
    repository = FakeTaskDetailRepository();
    imagePickerService = FakeImagePickerService();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        taskDetailRepositoryProvider.overrideWithValue(repository),
        imagePickerServiceProvider.overrideWithValue(imagePickerService),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: UpdateStatusBottomSheet(
            taskId: 'task_1001',
            currentStatus: 'pending',
          ),
        ),
      ),
    );
  }

  testWidgets('BottomSheet maintains state and shows error on API failure, never showing success', (WidgetTester tester) async {
    repository.shouldFail = true;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Select status
    final dropdown = find.byType(DropdownButtonFormField<String>);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    
    final inProgressItem = find.text('IN_PROGRESS').last;
    await tester.tap(inProgressItem);
    await tester.pumpAndSettle();

    // Enter note
    final noteField = find.byType(TextFormField);
    await tester.enterText(noteField, 'Test Note');
    await tester.pumpAndSettle();

    // Submit
    final submitButton = find.text('Submit Update');
    await tester.tap(submitButton);
    await tester.pump(); // Start loading
    await tester.pump(); // Finish loading

    // Verify error text is shown
    expect(find.text('Network Error'), findsOneWidget);
    
    // Verify success dialog is NOT shown
    expect(find.text('Status updated!'), findsNothing);

    // Verify bottom sheet is STILL open
    expect(find.text('Update Task Status'), findsOneWidget);
    
    // Verify values are preserved
    expect(find.text('Test Note'), findsOneWidget);
  });

  testWidgets('Canceling the image picker does not show error or crash', (WidgetTester tester) async {
    imagePickerService.returnNull = true; // Simulate user canceling

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final galleryButton = find.text('Gallery');
    await tester.tap(galleryButton);
    await tester.pumpAndSettle();

    // Verify it didn't crash, still shows the sheet, and no image is attached
    expect(find.text('Update Task Status'), findsOneWidget);
    expect(find.text('Image attached successfully'), findsNothing);
  });

  testWidgets('Permission error on image picker shows readable feedback', (WidgetTester tester) async {
    imagePickerService.throwPermissionError = true;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final cameraButton = find.text('Camera');
    await tester.tap(cameraButton);
    await tester.pumpAndSettle();

    // Should show SnackBar with permission denied message
    expect(find.textContaining('Permission denied or feature unavailable'), findsOneWidget);
  });
  
  testWidgets('Successful update triggers provider invalidation', (WidgetTester tester) async {
    repository.shouldFail = false;

    final container = ProviderContainer(
      overrides: [
        taskDetailRepositoryProvider.overrideWithValue(repository),
      ]
    );

    // Initial state
    final asyncValue = container.read(updateTaskStatusProvider);
    expect(asyncValue, const AsyncData<void>(null));

    // Call update status
    final future = container.read(updateTaskStatusProvider.notifier).updateStatus('task_1001', 'in_progress', 'done');
    
    expect(container.read(updateTaskStatusProvider) is AsyncLoading, true);
    
    await future;
    
    expect(container.read(updateTaskStatusProvider) is AsyncData, true);
    expect(repository.wasCalled, true);
  });

  testWidgets('Missing evidence is rejected locally without hitting repository', (WidgetTester tester) async {
    repository.wasCalled = false;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Select status
    final dropdown = find.byType(DropdownButtonFormField<String>);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    
    final inProgressItem = find.text('IN_PROGRESS').last;
    await tester.tap(inProgressItem);
    await tester.pumpAndSettle();

    // Do NOT enter note, Do NOT attach image

    // Submit
    final submitButton = find.text('Submit Update');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Validation error should appear
    expect(find.text('Please provide a note or attach an image.'), findsOneWidget);
    
    // Repository must NOT have been called
    expect(repository.wasCalled, false);
  });

  testWidgets('Image-only evidence submits successfully', (WidgetTester tester) async {
    repository.shouldFail = false;
    repository.wasCalled = false;
    imagePickerService.returnNull = false; // Returns fake_image.jpg

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Select status
    final dropdown = find.byType(DropdownButtonFormField<String>);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    
    final inProgressItem = find.text('IN_PROGRESS').last;
    await tester.tap(inProgressItem);
    await tester.pumpAndSettle();

    // Attach image
    final galleryButton = find.text('Gallery');
    await tester.tap(galleryButton);
    await tester.pumpAndSettle();

    // Note is empty
    expect(find.text('Image attached successfully'), findsOneWidget);

    // Submit
    final submitButton = find.text('Submit Update');
    await tester.tap(submitButton);
    await tester.pump();
    await tester.pump();

    // Repository must have been called
    expect(repository.wasCalled, true);
  });
}
