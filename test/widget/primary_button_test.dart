import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_ai/shared/widgets/primary_button.dart';
import '../helpers/fixture_reader.dart';
import '../test_config.dart';

void main() {
  late Map<String, dynamic> widgetConfig;

  setUpAll(() {
    initializeTestConfig();
  });

  setUp(() {
    final configJson = fixture('mock_responses/widget_config.json');
    widgetConfig = json.decode(configJson)['button']['primary'];
  });

  tearDownAll(() {
    resetTestConfig();
  });

  group('PrimaryButton Widget', () {
    testWidgets('renders correctly with default props', (tester) async {
      const buttonText = 'Click Me';
      
      await tester.pumpWidget(
        testableWidget(
          child: PrimaryButton(text: buttonText),
        ),
      );

      // Verify button exists and shows correct text
      expect(find.text(buttonText), findsOneWidget);
      
      // Verify default dimensions from fixture
      final buttonFinder = find.byType(SizedBox);
      final SizedBox buttonWidget = tester.widget(buttonFinder);
      expect(buttonWidget.height, widgetConfig['height']);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          child: const PrimaryButton(
            text: 'Loading Button',
            isLoading: true,
          ),
        ),
      );

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Verify text is hidden
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        testableWidget(
          child: PrimaryButton(
            text: 'Tap Me',
            onPressed: () => wasPressed = true,
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(wasPressed, true);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          child: const PrimaryButton(text: 'Disabled'),
        ),
      );

      // Verify button is disabled
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, null);
    });

    testWidgets('applies custom dimensions correctly', (tester) async {
      const customWidth = 200.0;
      const customHeight = 60.0;
      
      await tester.pumpWidget(
        testableWidget(
          child: const PrimaryButton(
            text: 'Custom Size',
            width: customWidth,
            height: customHeight,
          ),
        ),
      );

      final buttonFinder = find.byType(SizedBox);
      final SizedBox buttonWidget = tester.widget(buttonFinder);
      expect(buttonWidget.width, customWidth);
      expect(buttonWidget.height, customHeight);
    });
  });
} 