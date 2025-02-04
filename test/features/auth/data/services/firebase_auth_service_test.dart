import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reel_ai/features/auth/data/services/firebase_auth_service.dart';
import 'package:reel_ai/features/auth/domain/exceptions/auth_exception.dart';

import 'firebase_auth_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  UserCredential,
  User,
  FlutterSecureStorage,
])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockFlutterSecureStorage mockStorage;
  late FirebaseAuthService authService;
  late MockUserCredential mockCredential;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockStorage = MockFlutterSecureStorage();
    mockCredential = MockUserCredential();
    mockUser = MockUser();
    
    authService = FirebaseAuthService(
      auth: mockAuth,
      storage: mockStorage,
    );

    // Default mock behavior
    when(mockCredential.user).thenReturn(mockUser);
    when(mockUser.getIdToken()).thenAnswer((_) async => 'test_token');
    when(mockStorage.write(
      key: anyNamed('key'),
      value: anyNamed('value'),
      aOptions: anyNamed('aOptions'),
    )).thenAnswer((_) async {});
    when(mockAuth.authStateChanges())
        .thenAnswer((_) => Stream.value(mockUser));
  });

  group('signInWithEmail', () {
    test('successful sign in should return user', () async {
      final email = 'test@example.com';
      final password = 'password123';
      
      when(mockAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockCredential);

      final result = await authService.signInWithEmail(email, password);

      expect(result, equals(mockUser));
      verify(mockStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
        aOptions: anyNamed('aOptions'),
      )).called(1);
    });

    test('should throw AuthException on FirebaseAuthException', () async {
      final email = 'test@example.com';
      final password = 'wrong';
      
      when(mockAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      expect(
        () => authService.signInWithEmail(email, password),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signUp', () {
    test('successful sign up should return user', () async {
      final email = 'test@example.com';
      final password = 'password123';
      final displayName = 'Test User';
      
      when(mockAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockCredential);
      
      when(mockUser.updateDisplayName(displayName))
          .thenAnswer((_) async {});

      final result = await authService.signUp(email, password, displayName);

      expect(result, equals(mockUser));
      verify(mockUser.updateDisplayName(displayName)).called(1);
      verify(mockStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
        aOptions: anyNamed('aOptions'),
      )).called(1);
    });

    test('should throw AuthException on FirebaseAuthException', () async {
      final email = 'test@example.com';
      final password = 'password123';
      final displayName = 'Test User';
      
      when(mockAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        () => authService.signUp(email, password, displayName),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signOut', () {
    test('should sign out and clear token', () async {
      when(mockAuth.signOut()).thenAnswer((_) async {});
      when(mockStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async {});

      await authService.signOut();

      verify(mockAuth.signOut()).called(1);
      verify(mockStorage.delete(key: anyNamed('key'))).called(1);
    });
  });

  group('resetPassword', () {
    test('should send reset email', () async {
      final email = 'test@example.com';
      
      when(mockAuth.sendPasswordResetEmail(email: email))
          .thenAnswer((_) async {});

      await authService.resetPassword(email);

      verify(mockAuth.sendPasswordResetEmail(email: email)).called(1);
    });

    test('should throw AuthException on FirebaseAuthException', () async {
      final email = 'test@example.com';
      
      when(mockAuth.sendPasswordResetEmail(email: email))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      expect(
        () => authService.resetPassword(email),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('authStateChanges', () {
    test('should return auth state stream', () async {
      final stream = authService.authStateChanges;
      await expectLater(stream, emits(mockUser));
    });
  });

  group('currentUser', () {
    test('should return current user', () {
      when(mockAuth.currentUser).thenReturn(mockUser);
      expect(authService.currentUser, equals(mockUser));
    });

    test('should return null when no user is signed in', () {
      when(mockAuth.currentUser).thenReturn(null);
      expect(authService.currentUser, isNull);
    });
  });
} 