import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Initialize common test configuration
void initializeTestConfig() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Set up default test window size
  const testViewport = Size(375, 667); // iPhone SE size
  final dpi = 1.0;
  
  final binding = TestWidgetsFlutterBinding.instance;
  binding.window.physicalSizeTestValue = testViewport * dpi;
  binding.window.devicePixelRatioTestValue = dpi;
}

/// Reset test configuration
void resetTestConfig() {
  final binding = TestWidgetsFlutterBinding.instance;
  binding.window.clearPhysicalSizeTestValue();
  binding.window.clearDevicePixelRatioTestValue();
}

/// Wrapper for widget tests that provides common dependencies
Widget testableWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
} 