import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/exceptions.dart';

/// Low-level Firebase Authentication Service wrapper.
class FirebaseAuthService {
  final FirebaseAuth? firebaseAuth;

  FirebaseAuthService({this.firebaseAuth});

  /// Current authenticated Firebase User
  User? get currentUser {
    try {
      return firebaseAuth?.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Auth State Changes Stream
  Stream<User?> get authStateChanges {
    try {
      return firebaseAuth?.authStateChanges() ?? const Stream.empty();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Register with Email and Password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (firebaseAuth == null) {
      throw const AuthException('Firebase Auth is unavailable.');
    }
    try {
      final credential = await firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Sign In with Email and Password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (firebaseAuth == null) {
      throw const AuthException('Firebase Auth is unavailable.');
    }
    try {
      final credential = await firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail({required String email}) async {
    if (firebaseAuth == null) return;
    try {
      await firebaseAuth!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Send Email Verification to Current User
  Future<void> sendEmailVerification() async {
    if (firebaseAuth == null) return;
    try {
      final user = firebaseAuth!.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Reload User Profile Data
  Future<void> reloadUser() async {
    if (firebaseAuth == null) return;
    try {
      await firebaseAuth!.currentUser?.reload();
    } catch (_) {}
  }

  /// Delete Current Auth User Account
  Future<void> deleteAccount() async {
    if (firebaseAuth == null) return;
    try {
      await firebaseAuth!.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    if (firebaseAuth == null) return;
    try {
      await firebaseAuth!.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
