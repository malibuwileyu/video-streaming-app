import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/exceptions/auth_exception.dart';
import 'auth_service.dart';

/// A mock implementation of [AuthService] for testing.
class MockAuthService implements AuthService {
  User? _currentUser;
  final _authStateController = StreamController<User?>.broadcast();
  final _registeredUsers = <String, MockUser>{};

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<User?> signIn(AuthCredential credential) async {
    if (kDebugMode) print('🔑 Mock: Attempting sign in with credential');
    throw UnimplementedError();
  }

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    if (kDebugMode) print('🔑 Mock: Attempting email sign in for: $email');

    // Check if user exists
    final user = _registeredUsers[email];
    if (user == null) {
      if (kDebugMode) print('❌ Mock: No user found with email: $email');
      throw const AuthException(
        'user-not-found',
        'No user found with this email.',
      );
    }

    // Check password
    if (password != 'password123') {
      if (kDebugMode) print('❌ Mock: Wrong password for user: $email');
      throw const AuthException(
        'wrong-password',
        'Wrong password provided for this user.',
      );
    }

    if (kDebugMode) {
      print('✅ Mock: Login successful');
      print('👤 Mock user: ${user.email} (${user.displayName})');
    }

    _currentUser = user;
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<User?> signUp(String email, String password, String displayName) async {
    if (kDebugMode) print('📝 Mock: Attempting registration for: $email');

    // Validate password
    if (password.length < 6) {
      if (kDebugMode) print('❌ Mock: Password too weak');
      throw const AuthException(
        'weak-password',
        'The password is too weak. Please use a stronger password.',
      );
    }

    // Check for existing user
    if (_registeredUsers.containsKey(email)) {
      if (kDebugMode) print('❌ Mock: Email already in use');
      throw const AuthException(
        'email-already-in-use',
        'An account already exists with this email.',
      );
    }

    // Create mock user
    final user = MockUser(
      uid: 'mock-uid-${_registeredUsers.length + 1}',
      email: email,
      displayName: displayName,
    );
    
    if (kDebugMode) {
      print('✅ Mock: Registration successful');
      print('👤 Mock user: ${user.email} (${user.displayName})');
    }

    _registeredUsers[email] = user;
    _currentUser = user;
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> resetPassword(String email) async {
    if (kDebugMode) print('🔄 Mock: Attempting password reset for: $email');

    // Check if user exists
    if (!_registeredUsers.containsKey(email)) {
      if (kDebugMode) print('❌ Mock: No user found with email: $email');
      throw const AuthException(
        'user-not-found',
        'No user found with this email.',
      );
    }

    if (kDebugMode) {
      print('✅ Mock: Password reset email sent');
    }
  }

  @override
  Future<void> signOut() async {
    if (kDebugMode) print('🚪 Mock: Signing out user: ${_currentUser?.email}');
    _currentUser = null;
    _authStateController.add(null);
  }

  void dispose() {
    _authStateController.close();
  }
}

/// A mock implementation of [User] for testing.
class MockUser implements User {
  @override
  final String uid;
  
  @override
  final String? email;
  
  @override
  final String? displayName;

  MockUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  @override
  Future<void> delete() async {}

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    return 'mock-token';
  }

  @override
  Future<void> reload() async {}

  @override
  Future<void> updateDisplayName(String? displayName) async {}

  // ... other User methods that we don't use ...
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
} 