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

  group('Login Flow Tests', () {
    testWidgets('Successfully logs in a user', (tester) async {
      // Pre-register a user
      await authService.signUp('test@example.com', 'password123', 'Test User');
      await authService.signOut();

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

      // Fill in login form
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify successful login
      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser?.email, equals('test@example.com'));
      expect(authService.currentUser?.displayName, equals('Test User'));
    });

    testWidgets('Shows error for invalid credentials', (tester) async {
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

      // Fill in form with invalid credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'wrong@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrongpass',
      );
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify error message
      expect(
        find.text('No user found with this email.'),
        findsOneWidget,
      );
    });

    testWidgets('Shows error for wrong password', (tester) async {
      // Pre-register a user
      await authService.signUp('test@example.com', 'password123', 'Test User');
      await authService.signOut();

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

      // Fill in form with wrong password
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrongpass',
      );
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify error message
      expect(
        find.text('Wrong password provided for this user.'),
        findsOneWidget,
      );
    });
  });
} 