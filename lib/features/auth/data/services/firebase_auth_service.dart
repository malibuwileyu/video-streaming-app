import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../../domain/exceptions/auth_exception.dart';
import 'auth_service.dart';

/// Firebase implementation of [AuthService].
/// 
/// This implementation uses Firebase Authentication for all auth operations
/// and securely stores tokens using [FlutterSecureStorage].
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;
  final FlutterSecureStorage _storage;

  /// Creates a new Firebase auth service instance.
  /// 
  /// If not provided, uses the default [FirebaseAuth] instance
  /// and a new [FlutterSecureStorage] instance.
  FirebaseAuthService({
    FirebaseAuth? auth,
    FlutterSecureStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? const FlutterSecureStorage() {
    if (kDebugMode) {
      final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
      print('🔐 Configuring Firebase Auth with emulator at $host:9099');
      _auth.useAuthEmulator(host, 9099);
      
      // Log current auth state
      _auth.authStateChanges().listen((user) {
        print('👤 Auth State Changed: ${user?.email ?? 'No user'}');
      });
    }
  }

  @override
  Future<User?> signIn(AuthCredential credential) async {
    try {
      print('🔑 Attempting sign in with credential type: ${credential.providerId}');
      final result = await _auth.signInWithCredential(credential);
      print('✅ Sign in successful for user: ${result.user?.email}');
      await _saveToken(result.user);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      print('Stack trace: ${e.stackTrace}');
      throw AuthException.fromFirebaseException(e);
    } catch (e, stackTrace) {
      print('❌ Unexpected Auth Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      print('🔑 Attempting email sign in for: $email');
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Email sign in successful for: ${result.user?.email}');
      await _saveToken(result.user);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      print('Stack trace: ${e.stackTrace}');
      throw AuthException.fromFirebaseException(e);
    } catch (e, stackTrace) {
      print('❌ Unexpected Auth Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<User?> signUp(String email, String password, String displayName) async {
    try {
      print('📝 Attempting registration for: $email');
      
      // Create user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user == null) {
        print('❌ Registration failed: User is null after creation');
        throw const AuthException('unknown', 'Failed to create account');
      }

      // Update display name
      print('👤 Updating display name for: ${user.email} to: $displayName');
      await user.updateDisplayName(displayName);
      
      // Reload user to get updated profile
      print('🔄 Reloading user profile...');
      await user.reload();
      final updatedUser = _auth.currentUser;
      print('👤 Updated display name: ${updatedUser?.displayName}');
      
      // Save token
      print('💾 Saving auth token for: ${user.email}');
      await _saveToken(user);
      
      print('✅ Registration successful for: ${user.email}');
      return updatedUser;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error during registration: ${e.code} - ${e.message}');
      print('Stack trace: ${e.stackTrace}');
      throw AuthException.fromFirebaseException(e);
    } catch (e, stackTrace) {
      print('❌ Unexpected Error during registration: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      print('🔄 Attempting password reset for: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error during password reset: ${e.code} - ${e.message}');
      print('Stack trace: ${e.stackTrace}');
      throw AuthException.fromFirebaseException(e);
    } catch (e, stackTrace) {
      print('❌ Unexpected Error during password reset: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      print('🚪 Attempting sign out for user: ${_auth.currentUser?.email}');
      await Future.wait([
        _auth.signOut(),
        _storage.delete(key: 'auth_token'),
      ]);
      print('✅ Sign out successful');
    } catch (e, stackTrace) {
      print('❌ Error during sign out: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  /// Saves the user's ID token to secure storage.
  Future<void> _saveToken(User? user) async {
    if (user == null) {
      print('⚠️ Cannot save token: User is null');
      return;
    }
    
    try {
      print('🔒 Getting ID token for user: ${user.email}');
      final token = await user.getIdToken();
      print('💾 Saving token to secure storage');
      await _storage.write(
        key: 'auth_token',
        value: token,
        aOptions: const AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );
      print('✅ Token saved successfully');
    } catch (e, stackTrace) {
      print('❌ Error saving token: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
} 