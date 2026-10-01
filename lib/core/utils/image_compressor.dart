import 'dart:io';

/// Utility class for image file verification & optimization.
class ImageCompressor {
  ImageCompressor._();

  /// Validates file existence and returns the File object.
  static Future<File?> processImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return file;
    }
    return null;
  }
}
