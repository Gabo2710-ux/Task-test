import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService(ImagePicker());
});

class ImagePickerService {
  final ImagePicker _picker;

  ImagePickerService(this._picker);

  Future<XFile?> pickImage({required ImageSource source}) async {
    return await _picker.pickImage(source: source);
  }
}
