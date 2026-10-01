import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/firebase_auth_service.dart';
import '../../data/services/firebase_storage_service.dart';
import '../../data/services/firestore_service.dart';

/// Safe Firebase SDK Raw Instance Providers
final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  try {
    return FirebaseAuth.instance;
  } catch (e) {
    debugPrint('FirebaseAuth instance warning: $e');
    return null;
  }
});

final firestoreProvider = Provider<FirebaseFirestore?>((ref) {
  try {
    return FirebaseFirestore.instance;
  } catch (e) {
    debugPrint('FirebaseFirestore instance warning: $e');
    return null;
  }
});

final firebaseStorageProvider = Provider<FirebaseStorage?>((ref) {
  try {
    return FirebaseStorage.instance;
  } catch (e) {
    debugPrint('FirebaseStorage instance warning: $e');
    return null;
  }
});

/// Service Layer Providers
final authServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(firebaseAuth: ref.watch(firebaseAuthProvider));
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(firestore: ref.watch(firestoreProvider));
});

final storageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService(storage: ref.watch(firebaseStorageProvider));
});

/// Auth State Changes Provider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});
