import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/image_compressor.dart';

/// Low-level Image Picker service handling Camera & Gallery selection.
class ImagePickerService {
  final ImagePicker _picker;

  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Pick Image from Gallery
  Future<File?> pickFromGallery({double? maxWidth, double? maxHeight, int quality = 85}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth ?? 1200,
        maxHeight: maxHeight ?? 1200,
        imageQuality: quality,
      );

      if (pickedFile != null) {
        return await ImageCompressor.processImage(pickedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick Image from Camera
  Future<File?> pickFromCamera({double? maxWidth, double? maxHeight, int quality = 85}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth ?? 1200,
        maxHeight: maxHeight ?? 1200,
        imageQuality: quality,
      );

      if (pickedFile != null) {
        return await ImageCompressor.processImage(pickedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
