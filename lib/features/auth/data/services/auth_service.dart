import 'package:firebase_auth/firebase_auth.dart';

/// Abstract interface for authentication services.
/// 
/// This service handles all authentication-related operations including:
/// - Email/password authentication
/// - Password reset
/// - Session management
/// - Auth state changes
/// 
/// The interface is designed to be implementation-agnostic and support
/// future authentication methods (like OAuth2) through the credential system.
abstract class AuthService {
  /// Signs in a user with the provided credential.
  /// 
  /// This is the base authentication method that supports multiple auth types.
  /// For email auth, use [signInWithEmail] instead.
  Future<User?> signIn(AuthCredential credential);

  /// Signs in a user with email and password.
  /// 
  /// Throws [AuthException] if:
  /// - Email is invalid
  /// - Password is incorrect
  /// - User not found
  Future<User?> signInWithEmail(String email, String password);

  /// Creates a new user account with email and password.
  /// 
  /// Throws [AuthException] if:
  /// - Email is already in use
  /// - Password is too weak
  /// - Email is invalid
  Future<User?> signUp(String email, String password, String displayName);

  /// Sends a password reset email to the provided email address.
  /// 
  /// Throws [AuthException] if:
  /// - Email is invalid
  /// - No user found with this email
  Future<void> resetPassword(String email);

  /// Signs out the current user.
  /// 
  /// This will clear all auth tokens and update [currentUser] to null.
  Future<void> signOut();

  /// Stream of authentication state changes.
  /// 
  /// This stream will emit:
  /// - The current user when signed in
  /// - null when signed out
  /// - null when the token expires
  Stream<User?> get authStateChanges;

  /// The currently signed-in user, or null if not signed in.
  User? get currentUser;
} 