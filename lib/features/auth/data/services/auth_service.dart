import 'package:firebase_auth/firebase_auth.dart';

/// Abstract class defining the authentication service interface.
abstract class AuthService {
  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges;

  /// The currently signed-in user.
  User? get currentUser;

  /// Signs in a user with the provided email and password.
  Future<User?> signInWithEmail(String email, String password);

  /// Signs in a user with the provided credential.
  Future<User?> signIn(AuthCredential credential);

  /// Creates a new user account with the provided email and password.
  Future<User?> signUp(String email, String password, String displayName);

  /// Sends a password reset email to the provided email address.
  Future<void> resetPassword(String email);

  /// Signs out the current user.
  Future<void> signOut();
} 