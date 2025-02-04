import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
        _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<User?> signIn(AuthCredential credential) async {
    try {
      final result = await _auth.signInWithCredential(credential);
      await _saveToken(result.user);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseException(e);
    }
  }

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveToken(result.user);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseException(e);
    }
  }

  @override
  Future<User?> signUp(String email, String password, String displayName) async {
    try {
      // Create user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user == null) throw const AuthException('unknown', 'Failed to create account');

      // Update display name
      await user.updateDisplayName(displayName);
      
      // Save token
      await _saveToken(user);
      
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseException(e);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseException(e);
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _storage.delete(key: 'auth_token'),
    ]);
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  /// Saves the user's ID token to secure storage.
  Future<void> _saveToken(User? user) async {
    if (user == null) return;
    
    final token = await user.getIdToken();
    await _storage.write(
      key: 'auth_token',
      value: token,
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
  }
} 