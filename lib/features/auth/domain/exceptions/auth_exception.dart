import 'package:firebase_auth/firebase_auth.dart';

/// Custom exception class for authentication errors.
/// 
/// This class wraps Firebase auth errors and provides a consistent
/// error handling interface that's independent of the auth provider.
class AuthException implements Exception {
  /// Error code for identifying the type of error
  final String code;

  /// Human-readable error message
  final String message;

  /// Creates a new auth exception with the specified code and message
  const AuthException(this.code, this.message);

  /// Creates an auth exception from a Firebase auth exception
  factory AuthException.fromFirebaseException(FirebaseAuthException e) {
    final code = _mapFirebaseErrorCode(e.code);
    final message = _getReadableMessage(code);
    return AuthException(code, message);
  }

  /// Maps Firebase error codes to our internal error codes
  static String _mapFirebaseErrorCode(String firebaseCode) {
    switch (firebaseCode) {
      case 'invalid-email':
        return AuthErrorCode.invalidEmail;
      case 'user-disabled':
        return AuthErrorCode.userDisabled;
      case 'user-not-found':
        return AuthErrorCode.userNotFound;
      case 'wrong-password':
        return AuthErrorCode.wrongPassword;
      case 'email-already-in-use':
        return AuthErrorCode.emailInUse;
      case 'weak-password':
        return AuthErrorCode.weakPassword;
      case 'operation-not-allowed':
        return AuthErrorCode.operationNotAllowed;
      case 'too-many-requests':
        return AuthErrorCode.tooManyRequests;
      default:
        return AuthErrorCode.unknown;
    }
  }

  /// Converts error codes to human-readable messages
  static String _getReadableMessage(String code) {
    switch (code) {
      case AuthErrorCode.invalidEmail:
        return 'The email address is invalid.';
      case AuthErrorCode.userDisabled:
        return 'This account has been disabled.';
      case AuthErrorCode.userNotFound:
        return 'No account found with this email.';
      case AuthErrorCode.wrongPassword:
        return 'Incorrect password.';
      case AuthErrorCode.emailInUse:
        return 'An account already exists with this email.';
      case AuthErrorCode.weakPassword:
        return 'The password is too weak. Please use a stronger password.';
      case AuthErrorCode.operationNotAllowed:
        return 'This operation is not allowed.';
      case AuthErrorCode.tooManyRequests:
        return 'Too many attempts. Please try again later.';
      default:
        return 'An authentication error occurred.';
    }
  }

  @override
  String toString() => 'AuthException: [$code] $message';
}

/// Constants for authentication error codes
class AuthErrorCode {
  static const String invalidEmail = 'invalid-email';
  static const String userDisabled = 'user-disabled';
  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String emailInUse = 'email-already-in-use';
  static const String weakPassword = 'weak-password';
  static const String operationNotAllowed = 'operation-not-allowed';
  static const String tooManyRequests = 'too-many-requests';
  static const String unknown = 'unknown';

  // Prevent instantiation
  const AuthErrorCode._();
} 