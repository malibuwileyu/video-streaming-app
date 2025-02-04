import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:reel_ai/features/auth/data/services/auth_service.dart';
import 'package:reel_ai/features/auth/presentation/screens/login_screen.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(authService: mockAuthService),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('shows email and password fields', (tester) async {
      await pumpLoginScreen(tester);

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(
        find.byWidgetPredicate(
          (widget) => widget is TextFormField && widget.obscureText == false,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is TextFormField && widget.obscureText == true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows login and register buttons', (tester) async {
      await pumpLoginScreen(tester);

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('validates empty email', (tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('validates empty password', (tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('validates invalid email format', (tester) async {
      await pumpLoginScreen(tester);

      await tester.enterText(
        find.byWidgetPredicate(
          (widget) => widget is TextFormField && widget.obscureText == false,
        ),
        'invalid-email',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Invalid email format'), findsOneWidget);
    });

    testWidgets('calls login service on valid form submission', (tester) async {
      const email = 'test@example.com';
      const password = 'password123';

      when(mockAuthService.signInWithEmail(email, password))
          .thenAnswer((_) async => null);

      await pumpLoginScreen(tester);

      await tester.enterText(
        find.byWidgetPredicate(
          (widget) => widget is TextFormField && widget.obscureText == false,
        ),
        email,
      );
      await tester.enterText(
        find.byWidgetPredicate(
          (widget) => widget is TextFormField && widget.obscureText == true,
        ),
        password,
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(mockAuthService.signInWithEmail(email, password)).called(1);
    });

    testWidgets('shows error message on login failure', (tester) async {
      const email = 'test@example.com';
      const password = 'wrong-password';

      when(mockAuthService.signInWithEmail(email, password))
          .thenThrow(Exception('Login failed'));

      await pumpLoginScreen(tester);

      await tester.enterText(
        find.byWidgetPredicate(
          (widget) => widget is TextFormField && widget.obscureText == false,
        ),
        email,
      );
      await tester.enterText(
        find.byWidgetPredicate(
          (widget) => widget is TextFormField && widget.obscureText == true,
        ),
        password,
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Login failed'), findsOneWidget);
    });

    testWidgets('navigates to register screen on button tap', (tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      // We'll need to implement navigation and verify the new screen
    });
  });
} 