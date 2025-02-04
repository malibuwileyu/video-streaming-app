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

  group('Password Reset Flow Tests', () {
    testWidgets('Successfully sends password reset email', (tester) async {
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

      // Navigate to password reset
      await tester.tap(find.byKey(const Key('forgot_password_link')));
      await tester.pumpAndSettle();

      // Fill in email
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pumpAndSettle();

      // Verify success message
      expect(
        find.text('Password reset email sent. Please check your inbox.'),
        findsOneWidget,
      );
    });

    testWidgets('Shows error for non-existent email', (tester) async {
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

      // Navigate to password reset
      await tester.tap(find.byKey(const Key('forgot_password_link')));
      await tester.pumpAndSettle();

      // Fill in non-existent email
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'nonexistent@example.com',
      );
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pumpAndSettle();

      // Verify error message
      expect(
        find.text('No user found with this email.'),
        findsOneWidget,
      );
    });

    testWidgets('Shows error for invalid email format', (tester) async {
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

      // Navigate to password reset
      await tester.tap(find.byKey(const Key('forgot_password_link')));
      await tester.pumpAndSettle();

      // Fill in invalid email
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'invalid-email',
      );
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(
        find.text('Please enter a valid email'),
        findsOneWidget,
      );
    });
  });
} 