import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService authService;
  final FirestoreService firestoreService;
  final SharedPreferences prefs;

  static const String _usersCollection = 'users';
  static const String _rememberMeKey = 'remember_me_preference';

  // Local fallback session keys
  static const String _localUserIdKey = 'local_user_id';
  static const String _localUserNameKey = 'local_user_name';
  static const String _localUserEmailKey = 'local_user_email';
  static const String _localUserCampusKey = 'local_user_campus';
  static const String _localUserDeptKey = 'local_user_dept';
  static const String _localUserYearKey = 'local_user_year';
  static const String _localUserPhoneKey = 'local_user_phone';

  AuthRepositoryImpl({
    required this.authService,
    required this.firestoreService,
    required this.prefs,
  });

  @override
  Future<Result<UserEntity>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String campusName,
    required String department,
    required String year,
    required String phoneNumber,
  }) async {
    try {
      if (authService.firebaseAuth != null) {
        final credential = await authService.registerWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;
        if (user == null) {
          return const Result.failure(AuthFailure('User creation failed'));
        }

        final userModel = UserModel(
          id: user.uid,
          email: email.trim(),
          name: name.trim(),
          campusName: campusName.trim(),
          department: department.trim(),
          year: year.trim(),
          phoneNumber: phoneNumber.trim(),
          joinedAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isEmailVerified: user.emailVerified,
        );

        if (firestoreService.firestore != null) {
          await firestoreService.setDocument(
            collection: _usersCollection,
            docId: user.uid,
            data: userModel.toFirestore(),
          );
        }

        await authService.sendEmailVerification();
        return Result.success(userModel.toEntity());
      } else {
        // Local Session Fallback for Offline / Web Testing
        final uid = const Uuid().v4();
        final userEntity = UserEntity(
          id: uid,
          email: email.trim(),
          name: name.trim(),
          campusName: campusName.trim(),
          department: department.trim(),
          year: year.trim(),
          phoneNumber: phoneNumber.trim(),
          joinedAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isEmailVerified: true,
        );

        await prefs.setString(_localUserIdKey, uid);
        await prefs.setString(_localUserNameKey, name.trim());
        await prefs.setString(_localUserEmailKey, email.trim());
        await prefs.setString(_localUserCampusKey, campusName.trim());
        await prefs.setString(_localUserDeptKey, department.trim());
        await prefs.setString(_localUserYearKey, year.trim());
        await prefs.setString(_localUserPhoneKey, phoneNumber.trim());

        return Result.success(userEntity);
      }
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message, code: e.code));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (authService.firebaseAuth != null) {
        final credential = await authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;
        if (user == null) {
          return const Result.failure(AuthFailure('Sign in failed'));
        }

        if (firestoreService.firestore != null) {
          final doc = await firestoreService.getDocument(
            collection: _usersCollection,
            docId: user.uid,
          );

          if (doc.exists) {
            final userModel = UserModel.fromFirestore(doc);
            // Update last login timestamp in Firestore
            await firestoreService.updateDocument(
              collection: _usersCollection,
              docId: user.uid,
              data: {'lastLogin': DateTime.now()},
            );
            return Result.success(userModel.toEntity().copyWith(lastLogin: DateTime.now()));
          }
        }

        return Result.success(UserEntity(
          id: user.uid,
          email: email,
          name: user.displayName ?? email.split('@').first,
          campusName: 'Campus Peer',
          joinedAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isEmailVerified: user.emailVerified,
        ));
      } else {
        // Local Session Fallback
        final savedName = prefs.getString(_localUserNameKey) ?? email.split('@').first;
        final savedCampus = prefs.getString(_localUserCampusKey) ?? 'Campus Peer';
        final savedDept = prefs.getString(_localUserDeptKey) ?? 'Computer Science';
        final savedYear = prefs.getString(_localUserYearKey) ?? '3rd Year';
        final savedPhone = prefs.getString(_localUserPhoneKey) ?? '+91 98765 43210';
        final savedUid = prefs.getString(_localUserIdKey) ?? const Uuid().v4();

        final userEntity = UserEntity(
          id: savedUid,
          email: email.trim(),
          name: savedName,
          campusName: savedCampus,
          department: savedDept,
          year: savedYear,
          phoneNumber: savedPhone,
          joinedAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isEmailVerified: true,
        );

        await prefs.setString(_localUserIdKey, savedUid);
        await prefs.setString(_localUserEmailKey, email.trim());
        await prefs.setString(_localUserNameKey, savedName);
        await prefs.setString(_localUserCampusKey, savedCampus);

        return Result.success(userEntity);
      }
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message, code: e.code));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> checkEmailVerified() async {
    try {
      if (authService.firebaseAuth != null) {
        await authService.reloadUser();
        final user = authService.currentUser;
        return Result.success(user?.emailVerified ?? false);
      }
      return const Result.success(true);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateUserProfile(UserEntity updatedUser) async {
    try {
      final model = UserModel.fromEntity(updatedUser);
      if (firestoreService.firestore != null) {
        await firestoreService.updateDocument(
          collection: _usersCollection,
          docId: updatedUser.id,
          data: model.toFirestore(),
        );
      }
      await prefs.setString(_localUserNameKey, updatedUser.name);
      await prefs.setString(_localUserDeptKey, updatedUser.department);
      await prefs.setString(_localUserYearKey, updatedUser.year);
      await prefs.setString(_localUserPhoneKey, updatedUser.phoneNumber);

      return Result.success(updatedUser);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      if (authService.firebaseAuth != null) {
        final uid = authService.currentUser?.uid;
        if (uid != null && firestoreService.firestore != null) {
          await firestoreService.deleteDocument(collection: _usersCollection, docId: uid);
        }
        await authService.deleteAccount();
      }
      await signOut();
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      if (authService.firebaseAuth != null) {
        await authService.signOut();
      }
      await prefs.remove(_localUserIdKey);
      await prefs.remove(_localUserNameKey);
      await prefs.remove(_localUserEmailKey);
      await prefs.remove(_localUserCampusKey);
      await prefs.remove(_localUserDeptKey);
      await prefs.remove(_localUserYearKey);
      await prefs.remove(_localUserPhoneKey);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      if (authService.firebaseAuth != null) {
        await authService.sendPasswordResetEmail(email: email);
      }
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      if (authService.firebaseAuth != null) {
        await authService.sendEmailVerification();
      }
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      if (authService.firebaseAuth != null) {
        final firebaseUser = authService.currentUser;
        if (firebaseUser == null) {
          return const Result.success(null);
        }

        if (firestoreService.firestore != null) {
          final doc = await firestoreService.getDocument(
            collection: _usersCollection,
            docId: firebaseUser.uid,
          );

          if (doc.exists) {
            final userModel = UserModel.fromFirestore(doc);
            return Result.success(userModel.toEntity());
          }
        }

        return Result.success(UserEntity(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'Student',
          campusName: 'Chennai Institute of Technology',
          joinedAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isEmailVerified: firebaseUser.emailVerified,
        ));
      } else {
        // Local Session Check
        final savedUid = prefs.getString(_localUserIdKey);
        final savedEmail = prefs.getString(_localUserEmailKey);
        final savedName = prefs.getString(_localUserNameKey);
        final savedCampus = prefs.getString(_localUserCampusKey);
        final savedDept = prefs.getString(_localUserDeptKey);
        final savedYear = prefs.getString(_localUserYearKey);
        final savedPhone = prefs.getString(_localUserPhoneKey);

        if (savedUid != null && savedEmail != null) {
          return Result.success(UserEntity(
            id: savedUid,
            email: savedEmail,
            name: savedName ?? 'Student',
            campusName: savedCampus ?? 'Chennai Institute of Technology',
            department: savedDept ?? 'Computer Science & Engineering',
            year: savedYear ?? '3rd Year',
            phoneNumber: savedPhone ?? '+91 98765 43210',
            joinedAt: DateTime.now(),
            lastLogin: DateTime.now(),
            isEmailVerified: true,
          ));
        }

        return const Result.success(null);
      }
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> saveRememberMe(bool remember) async {
    await prefs.setBool(_rememberMeKey, remember);
  }

  @override
  Future<bool> getRememberMe() async {
    return prefs.getBool(_rememberMeKey) ?? false;
  }
}
