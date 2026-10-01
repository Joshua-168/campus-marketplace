import '../../core/utils/result.dart';
import '../entities/user_entity.dart';

/// Abstract Domain Contract for Authentication & User Profile operations.
abstract class AuthRepository {
  Future<Result<UserEntity>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String campusName,
    required String department,
    required String year,
    required String phoneNumber,
  });

  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> sendPasswordResetEmail({required String email});

  Future<Result<void>> sendEmailVerification();

  Future<Result<bool>> checkEmailVerified();

  Future<Result<UserEntity?>> getCurrentUser();

  Future<Result<UserEntity>> updateUserProfile(UserEntity updatedUser);

  Future<Result<void>> deleteAccount();

  Future<void> saveRememberMe(bool remember);

  Future<bool> getRememberMe();
}
