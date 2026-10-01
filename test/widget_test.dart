import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_marketplace/main.dart';
import 'package:campus_marketplace/features/auth/providers/auth_provider.dart';
import 'package:campus_marketplace/core/providers/firebase_providers.dart';
import 'package:campus_marketplace/domain/repositories/auth_repository.dart';
import 'package:campus_marketplace/domain/entities/user_entity.dart';
import 'package:campus_marketplace/core/utils/result.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Result<UserEntity?>> getCurrentUser() async => const Result.success(null);

  @override
  Future<bool> getRememberMe() async => false;

  @override
  Future<Result<UserEntity>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String campusName,
    required String department,
    required String year,
    required String phoneNumber,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void>> sendEmailVerification() async => const Result.success(null);

  @override
  Future<Result<bool>> checkEmailVerified() async => const Result.success(true);

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async => const Result.success(null);

  @override
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Result<UserEntity>> updateUserProfile(UserEntity updatedUser) async => Result.success(updatedUser);

  @override
  Future<Result<void>> deleteAccount() async => const Result.success(null);

  @override
  Future<Result<void>> signOut() async => const Result.success(null);

  @override
  Future<void> saveRememberMe(bool remember) async {}
}

void main() {
  testWidgets('Campus Marketplace Navigation App Smoke Test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const CampusMarketplaceApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(CampusMarketplaceApp), findsOneWidget);
  });
}
