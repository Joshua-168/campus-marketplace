import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main() via override');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authService: ref.watch(authServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

/// Auth UI State representation
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;
  final bool rememberMe;
  final bool isEmailSent;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.rememberMe = false,
    this.isEmailSent = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? errorMessage,
    bool? rememberMe,
    bool? isEmailSent,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
      rememberMe: rememberMe ?? this.rememberMe,
      isEmailSent: isEmailSent ?? this.isEmailSent,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier({required this.repository}) : super(const AuthState()) {
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    state = state.copyWith(isLoading: true);
    final remember = await repository.getRememberMe();
    final result = await repository.getCurrentUser();

    result.fold(
      onSuccess: (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          rememberMe: remember,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          user: null,
          rememberMe: remember,
        );
      },
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String campusName,
    required String department,
    required String year,
    required String phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await repository.registerWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      campusName: campusName,
      department: department,
      year: year,
      phoneNumber: phoneNumber,
    );

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> updateProfile(UserEntity updatedUser) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await repository.updateUserProfile(updatedUser);

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await repository.deleteAccount();

    return result.fold(
      onSuccess: (_) {
        state = const AuthState();
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> sendPasswordReset({required String email}) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isEmailSent: false);
    final result = await repository.sendPasswordResetEmail(email: email);

    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false, isEmailSent: true);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<void> toggleRememberMe(bool value) async {
    state = state.copyWith(rememberMe: value);
    await repository.saveRememberMe(value);
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await repository.signOut();
    state = const AuthState();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(repository: ref.watch(authRepositoryProvider));
});
