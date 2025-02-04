import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_ai/shared/models/app_theme.dart';
import '../../helpers/fixture_reader.dart';

void main() {
  group('AppTheme', () {
    test('parses from JSON correctly', () {
      // Load fixture
      final jsonString = fixture('mock_responses/app_theme.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString)['theme'];
      
      // Parse theme
      final theme = AppTheme.fromJson(jsonMap);
      
      // Verify values
      expect(theme.primaryColor, '#FF2196F3');
      expect(theme.backgroundColor, '#FFFAFAFA');
      expect(theme.spacing.small, 8);
      expect(theme.typography.headingSize, 24);
    });

    test('serializes to JSON correctly', () {
      // Create theme instance
      final theme = AppTheme(
        primaryColor: '#FF2196F3',
        secondaryColor: '#FF1976D2',
        backgroundColor: '#FFFAFAFA',
        textColor: '#DD000000',
        errorColor: '#FFD32F2F',
        spacing: const ThemeSpacing(
          small: 8,
          medium: 16,
          large: 24,
        ),
        typography: const ThemeTypography(
          headingSize: 24,
          bodySize: 16,
          captionSize: 12,
        ),
      );

      // Convert to JSON
      final Map<String, dynamic> json = theme.toJson();
      final Map<String, dynamic> spacingJson = json['spacing'] as Map<String, dynamic>;
      final Map<String, dynamic> typographyJson = json['typography'] as Map<String, dynamic>;

      // Verify values
      expect(json['primaryColor'], '#FF2196F3');
      expect(json['backgroundColor'], '#FFFAFAFA');
      expect(spacingJson['small'], 8);
      expect(typographyJson['headingSize'], 24);
    });

    test('creates valid theme data', () {
      final jsonString = fixture('mock_responses/app_theme.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString)['theme'];
      final theme = AppTheme.fromJson(jsonMap);

      // Verify all required fields are present
      expect(theme.primaryColor, isNotNull);
      expect(theme.secondaryColor, isNotNull);
      expect(theme.backgroundColor, isNotNull);
      expect(theme.textColor, isNotNull);
      expect(theme.errorColor, isNotNull);
      expect(theme.spacing, isNotNull);
      expect(theme.typography, isNotNull);
    });
  });

  group('ThemeSpacing', () {
    test('creates with correct values', () {
      const spacing = ThemeSpacing(
        small: 8,
        medium: 16,
        large: 24,
      );

      expect(spacing.small, 8);
      expect(spacing.medium, 16);
      expect(spacing.large, 24);
    });
  });

  group('ThemeTypography', () {
    test('creates with correct values', () {
      const typography = ThemeTypography(
        headingSize: 24,
        bodySize: 16,
        captionSize: 12,
      );

      expect(typography.headingSize, 24);
      expect(typography.bodySize, 16);
      expect(typography.captionSize, 12);
    });
  });
} 