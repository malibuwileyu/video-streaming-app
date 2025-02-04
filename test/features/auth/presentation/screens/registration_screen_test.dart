import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:reel_ai/features/auth/data/services/auth_service.dart';
import 'package:reel_ai/features/auth/presentation/screens/registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reel_ai/features/auth/domain/exceptions/auth_exception.dart';

import 'registration_screen_test.mocks.dart';

@GenerateMocks([AuthService, User])
void main() {
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();
    
    // Setup default mock behavior
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');
  });

  Future<void> pumpRegistrationScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegistrationScreen(authService: mockAuthService),
        routes: {
          '/home': (context) => const Scaffold(body: Text('Home Screen')),
        },
      ),
    );
  }

  group('RegistrationScreen', () {
    testWidgets('shows all required fields', (tester) async {
      await pumpRegistrationScreen(tester);

      // Verify all form fields are present
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('display_name_field')), findsOneWidget);
      expect(find.byKey(const Key('register_button')), findsOneWidget);
    });

    testWidgets('validates empty fields', (tester) async {
      await pumpRegistrationScreen(tester);

      // Try to register without filling fields
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pump();

      // Verify validation messages
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Display name is required'), findsOneWidget);
    });

    testWidgets('validates email format', (tester) async {
      await pumpRegistrationScreen(tester);

      // Enter invalid email
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'invalid-email',
      );
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pump();

      expect(find.text('Invalid email format'), findsOneWidget);
    });

    testWidgets('validates password strength', (tester) async {
      await pumpRegistrationScreen(tester);

      // Enter weak password
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'weak',
      );
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pump();

      expect(
        find.text('Password must be at least 8 characters long'),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator during registration', (tester) async {
      // Setup mock to never complete
      when(mockAuthService.signUp(any, any, any))
          .thenAnswer((_) => Completer<User>().future);

      await pumpRegistrationScreen(tester);

      // Fill form
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'StrongPass123!',
      );
      await tester.enterText(
        find.byKey(const Key('display_name_field')),
        'Test User',
      );

      // Start registration
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pump(); // Rebuild after tap

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('navigates to home on successful registration', (tester) async {
      when(mockAuthService.signUp(any, any, any))
          .thenAnswer((_) async => mockUser);

      await pumpRegistrationScreen(tester);

      // Fill form
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'StrongPass123!',
      );
      await tester.enterText(
        find.byKey(const Key('display_name_field')),
        'Test User',
      );

      // Submit form
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Verify navigation
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('shows error message on registration failure', (tester) async {
      when(mockAuthService.signUp(any, any, any))
          .thenThrow(const AuthException('email-already-in-use', 'An account already exists with this email.'));

      await pumpRegistrationScreen(tester);

      // Fill form
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'StrongPass123!',
      );
      await tester.enterText(
        find.byKey(const Key('display_name_field')),
        'Test User',
      );

      // Submit form
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Verify error message
      expect(
        find.text('An account already exists with this email.'),
        findsOneWidget,
      );
    });
  });
} 