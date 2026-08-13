import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/auth_repository.dart';

/// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

/// Load theme mode from shared preferences
final savedThemeModeProvider = FutureProvider<ThemeMode>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final themeIndex = prefs.getInt(AppConstants.themeModeKey);

  switch (themeIndex) {
    case 0:
      return ThemeMode.system;
    case 1:
      return ThemeMode.light;
    case 2:
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});

/// Save theme mode to shared preferences
Future<void> saveThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(AppConstants.themeModeKey, mode.index);
}

/// Toggle theme mode
void toggleThemeMode(WidgetRef ref) {
  final current = ref.read(themeModeProvider);
  ThemeMode newMode;

  switch (current) {
    case ThemeMode.system:
      newMode = ThemeMode.light;
      break;
    case ThemeMode.light:
      newMode = ThemeMode.dark;
      break;
    case ThemeMode.dark:
      newMode = ThemeMode.system;
      break;
  }

  ref.read(themeModeProvider.notifier).state = newMode;
  saveThemeMode(newMode);
}

/// Authentication state model
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isError => status == AuthStatus.error;
  bool get isInitial => status == AuthStatus.initial;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

/// Auth state provider
final authStateProvider = StateProvider<AuthState>((ref) {
  return const AuthState();
});

/// Current Firebase user provider
final firebaseUserProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

/// Registration notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  /// Register with email and password
  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String displayName,
    String? phoneNumber,
  }) async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      final credential = await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
        phoneNumber: phoneNumber,
      );

      state = AuthState(
        status: AuthStatus.authenticated,
        user: credential.user,
      );
    } on AuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: AppConstants.genericError,
      );
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      final credential = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = AuthState(
        status: AuthStatus.authenticated,
        user: credential.user,
      );
    } on AuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: AppConstants.genericError,
      );
    }
  }

  /// Verify phone number (send OTP)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException error) onVerificationFailed,
  }) async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      await _authRepository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onVerificationCompleted: onVerificationCompleted,
        onCodeSent: (verificationId, forceResendingToken) {
          onCodeSent(verificationId);
        },
        onVerificationFailed: onVerificationFailed,
        onResendCode: (verificationId, forceResendingToken) {},
      );
    } on AuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: AppConstants.genericError,
      );
    }
  }

  /// Sign in with phone OTP
  Future<void> signInWithPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      final credential = await _authRepository.signInWithPhoneCredential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      state = AuthState(
        status: AuthStatus.authenticated,
        user: credential.user,
      );
    } on AuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: AppConstants.genericError,
      );
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      final credential = await _authRepository.signInWithGoogle();

      state = AuthState(
        status: AuthStatus.authenticated,
        user: credential.user,
      );
    } on AuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: AppConstants.genericError,
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      // Don't change auth state, just show success
    } on AuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: AppConstants.genericError,
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      await _authRepository.signOut();

      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: AppConstants.genericError,
      );
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      await _authRepository.deleteAccount();

      state = const AuthState(status: AuthStatus.unauthenticated);
    } on AuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: AppConstants.genericError,
      );
    }
  }

  /// Re-authenticate user
  Future<void> reauthenticate({required String password}) async {
    try {
      await _authRepository.reauthenticate(password: password);
    } on AuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    }
  }

  /// Check if user is authenticated (from saved session)
  Future<void> checkAuthStatus() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Clear error state
  void clearError() {
    state = AuthState(
      status: _authRepository.isAuthenticated
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
      user: _authRepository.currentUser,
    );
  }
}

/// Auth notifier provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepo);
});
