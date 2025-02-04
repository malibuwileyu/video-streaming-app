import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_theme.g.dart';

@JsonSerializable(explicitToJson: true)
class AppTheme {
  final String primaryColor;
  final String secondaryColor;
  final String backgroundColor;
  final String textColor;
  final String errorColor;
  final ThemeSpacing spacing;
  final ThemeTypography typography;

  const AppTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.errorColor,
    required this.spacing,
    required this.typography,
  });

  factory AppTheme.fromJson(Map<String, dynamic> json) => _$AppThemeFromJson(json);
  Map<String, dynamic> toJson() => _$AppThemeToJson(this);
}

@JsonSerializable()
class ThemeSpacing {
  final double small;
  final double medium;
  final double large;

  const ThemeSpacing({
    required this.small,
    required this.medium,
    required this.large,
  });

  factory ThemeSpacing.fromJson(Map<String, dynamic> json) => _$ThemeSpacingFromJson(json);
  Map<String, dynamic> toJson() => _$ThemeSpacingToJson(this);
}

@JsonSerializable()
class ThemeTypography {
  final double headingSize;
  final double bodySize;
  final double captionSize;

  const ThemeTypography({
    required this.headingSize,
    required this.bodySize,
    required this.captionSize,
  });

  factory ThemeTypography.fromJson(Map<String, dynamic> json) => _$ThemeTypographyFromJson(json);
  Map<String, dynamic> toJson() => _$ThemeTypographyToJson(this);
} 