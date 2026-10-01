import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/errors/exceptions.dart';

/// Low-level Firebase Storage Service wrapper for file uploads & downloads.
class FirebaseStorageService {
  final FirebaseStorage? storage;

  FirebaseStorageService({this.storage});

  /// Upload File and Return Download URL
  Future<String> uploadFile({
    required String path,
    required File file,
    Function(double progress)? onProgress,
  }) async {
    if (storage == null) throw const ServerException('Firebase Storage is unavailable.');
    try {
      final ref = storage!.ref().child(path);
      final uploadTask = ref.putFile(file);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Storage upload failed', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Delete File from Storage
  Future<void> deleteFile({required String url}) async {
    if (storage == null) return;
    try {
      final ref = storage!.refFromURL(url);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Storage delete failed', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
