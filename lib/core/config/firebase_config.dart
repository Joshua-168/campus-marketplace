import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase Initialization helper with safe platform configuration.
class FirebaseConfig {
  FirebaseConfig._();

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (e) {
      debugPrint('Firebase initialization warning: $e');
    }
  }
}
