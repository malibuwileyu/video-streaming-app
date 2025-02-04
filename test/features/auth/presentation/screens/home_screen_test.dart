import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:reel_ai/features/auth/data/services/auth_service.dart';
import 'package:reel_ai/features/auth/presentation/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([AuthService, User])
void main() {
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();
    
    // Setup default mock behavior
    when(mockUser.email).thenReturn('test@example.com');
    when(mockAuthService.currentUser).thenReturn(mockUser);
  });

  Future<void> pumpHomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(authService: mockAuthService),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
        },
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('shows user email', (tester) async {
      await pumpHomeScreen(tester);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('shows welcome message', (tester) async {
      await pumpHomeScreen(tester);
      expect(find.text('Welcome to ReelAI'), findsOneWidget);
    });

    testWidgets('shows logout button', (tester) async {
      await pumpHomeScreen(tester);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('handles logout', (tester) async {
      when(mockAuthService.signOut()).thenAnswer((_) async {});
      
      await pumpHomeScreen(tester);
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      verify(mockAuthService.signOut()).called(1);
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('shows loading during logout', (tester) async {
      // Setup a Completer that we won't complete during this test
      when(mockAuthService.signOut()).thenAnswer((_) => Completer<void>().future);
      
      await pumpHomeScreen(tester);
      
      // Start logout
      await tester.tap(find.text('Logout'));
      await tester.pump(); // Rebuild once to show loading state

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Logout'), findsNothing);
    });
  });
} 