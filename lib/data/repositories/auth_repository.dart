import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Custom exception types for auth errors
class AuthException implements Exception {
  final String message;
  final String code;
  const AuthException(this.message, this.code);

  @override
  String toString() => 'AuthException($code): $message';
}

/// Authentication state
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error;
}

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    googleSignIn: GoogleSignIn(),
  );
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final auth = FirebaseAuth.instance;
  return auth.currentUser;
});

/// Authentication repository handling all auth operations
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  // ============================================================================
  // Stream: Current Firebase Auth User
  // ============================================================================

  /// Stream of the current Firebase user
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get the currently signed-in user
  User? get currentUser => _auth.currentUser;

  /// Check if a user is currently authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // ============================================================================
  // Email/Password Authentication
  // ============================================================================

  /// Register a new user with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
    String? phoneNumber,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException(
          'User creation failed',
          'user_creation_failed',
        );
      }

      // Update display name
      await user.updateDisplayName(displayName);

      // Create user profile in Firestore
      final userModel = UserModel(
        uid: user.uid,
        username: username,
        email: email,
        displayName: displayName,
        phoneNumber: phoneNumber,
        profilePicUrl: AppConstants.defaultProfilePicture,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        accountStatus: 'active',
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toJson());

      // Save user ID to shared preferences
      await _saveUserId(user.uid);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _mapAuthError(e.code),
        e.code,
      );
    } catch (e) {
      throw AuthException(
        AppConstants.genericError,
        'unknown_error',
      );
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await _saveUserId(user.uid);
        await _updateLastActive(user.uid);
        await _updateOnlineStatus(user.uid, true);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _mapAuthError(e.code),
        e.code,
      );
    } catch (e) {
      throw AuthException(
        AppConstants.genericError,
        'unknown_error',
      );
    }
  }

  // ============================================================================
  // Phone Authentication (OTP)
  // ============================================================================

  /// Verify a phone number and trigger SMS verification
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException error) onVerificationFailed,
    required Function(String verificationId, bool forceResendingToken)
        onResendCode,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? forceResendingToken) {
        onCodeSent(verificationId);
        onResendCode(
          verificationId,
          forceResendingToken != null,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: timeout,
    );
  }

  /// Sign in with phone OTP credential
  Future<UserCredential> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        await _saveUserId(user.uid);
        await _updateLastActive(user.uid);
        await _updateOnlineStatus(user.uid, true);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _mapAuthError(e.code),
        e.code,
      );
    } catch (e) {
      throw AuthException(
        AppConstants.genericError,
        'unknown_error',
      );
    }
  }

  // ============================================================================
  // Google Sign-In
  // ============================================================================

  /// Sign in with Google account
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException(
          'Google sign-in was cancelled',
          'google_sign_in_cancelled',
        );
      }

      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        await _saveUserId(user.uid);
        await _updateLastActive(user.uid);
        await _updateOnlineStatus(user.uid, true);

        // Check if user profile exists, create if not
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          final userModel = UserModel(
            uid: user.uid,
            username: _generateUsernameFromEmail(user.email ?? ''),
            email: user.email,
            displayName: user.displayName,
            profilePicUrl: user.photoURL ?? AppConstants.defaultProfilePicture,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            accountStatus: 'active',
          );

          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .set(userModel.toJson());
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _mapAuthError(e.code),
        e.code,
      );
    } catch (e) {
      throw AuthException(
        AppConstants.genericError,
        'unknown_error',
      );
    }
  }

  // ============================================================================
  // Password Management
  // ============================================================================

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _mapAuthError(e.code),
        e.code,
      );
    } catch (e) {
      throw AuthException(
        AppConstants.genericError,
        'unknown_error',
      );
    }
  }

  /// Change the current user's password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException(
          'No authenticated user',
          'not_authenticated',
        );
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _mapAuthError(e.code),
        e.code,
      );
    } catch (e) {
      throw AuthException(
        AppConstants.genericError,
        'unknown_error',
      );
    }
  }

  // ============================================================================
  // Session Management
  // ============================================================================

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      final userId = _auth.currentUser?.uid;

      // Update online status before signing out
      if (userId != null) {
        await _updateOnlineStatus(userId, false);
        await _updateLastActive(userId);
      }

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _clearUserId(),
      ]);
    } catch (e) {
      throw AuthException(
        AppConstants.genericError,
        'sign_out_error',
      );
    }
  }

  /// Delete the current user's account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException(
          'No authenticated user',
          'not_authenticated',
        );
      }

      // Delete user document from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();

      // Delete user account
      await user.delete();
      await _clearUserId();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _mapAuthError(e.code),
        e.code,
      );
    } catch (e) {
      throw AuthException(
        AppConstants.genericError,
        'unknown_error',
      );
    }
  }

  /// Re-authenticate the user
  Future<void> reauthenticate({required String password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw const AuthException(
          'No authenticated user',
          'not_authenticated',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _mapAuthError(e.code),
        e.code,
      );
    }
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Update the user's last active timestamp
  Future<void> _updateLastActive(String uid) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'lastActive': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Update the user's online status
  Future<void> _updateOnlineStatus(String uid, bool isOnline) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'isOnline': isOnline,
    });
  }

  /// Save the user ID to shared preferences
  Future<void> _saveUserId(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userIdKey, uid);
  }

  /// Clear the user ID from shared preferences
  Future<void> _clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.authTokenKey);
  }

  /// Get the saved user ID
  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userIdKey);
  }

  /// Map Firebase Auth error codes to user-friendly messages
  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return AppConstants.accountDisabled;
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return AppConstants.rateLimited;
      case 'invalid-phone-number':
        return 'The phone number format is invalid.';
      case 'quota-exceeded':
        return AppConstants.rateLimited;
      case 'session-expired':
        return AppConstants.sessionExpired;
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      case 'network-request-failed':
        return AppConstants.networkError;
      case 'invalid-credential':
        return 'The credentials are invalid.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email.';
      case 'requires-recent-login':
        return AppConstants.sessionExpired;
      default:
        return AppConstants.genericError;
    }
  }

  /// Generate a username from email address
  String _generateUsernameFromEmail(String email) {
    final username =
        email.split('@')[0].replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    return username.isEmpty
        ? 'user_${DateTime.now().millisecondsSinceEpoch}'
        : username;
  }
}
