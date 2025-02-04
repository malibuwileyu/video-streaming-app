import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:reel_ai/features/auth/data/services/auth_service.dart';
import 'package:reel_ai/features/auth/data/services/mock_auth_service.dart';
import 'package:reel_ai/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService authService;

  setUp(() {
    authService = MockAuthService();
  });

  tearDown(() {
    authService.dispose();
  });

  group('Registration Flow Tests', () {
    testWidgets('Successfully registers a new user', (tester) async {
      // Start app with mock auth service
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>(
              create: (_) => authService,
            ),
          ],
          child: const app.MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to registration
      await tester.tap(find.byKey(const Key('register_link')));
      await tester.pumpAndSettle();

      // Fill in registration form
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('display_name_field')),
        'Test User',
      );
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Verify successful registration
      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser?.email, equals('test@example.com'));
      expect(authService.currentUser?.displayName, equals('Test User'));
    });

    testWidgets('Shows error for weak password', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>(
              create: (_) => authService,
            ),
          ],
          child: const app.MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to registration
      await tester.tap(find.byKey(const Key('register_link')));
      await tester.pumpAndSettle();

      // Fill in form with weak password
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        '123',
      );
      await tester.enterText(
        find.byKey(const Key('display_name_field')),
        'Test User',
      );
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Verify error message
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('Shows error for duplicate email', (tester) async {
      // Pre-register a user
      await authService.signUp('test@example.com', 'password123', 'Test User');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>(
              create: (_) => authService,
            ),
          ],
          child: const app.MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to registration
      await tester.tap(find.byKey(const Key('register_link')));
      await tester.pumpAndSettle();

      // Try to register with same email
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('display_name_field')),
        'Another User',
      );
      await tester.pumpAndSettle();

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