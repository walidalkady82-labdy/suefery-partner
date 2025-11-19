import 'package:flutter/material.dart';
import 'package:suefery_partner/core/utils/app_typography.dart';

// The single light theme for the entire application, now based on the "Sunset Orange" design.
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFFF7043), // Deep Orange
  scaffoldBackgroundColor: const Color(0xFFFFF3E0), // A very light orange
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.orange,
    brightness: Brightness.light,
  ).copyWith(
    secondary: const Color(0xFF81D4FA), // Light Blue accent
    background: const Color(0xFFFFF3E0),
    surface: Colors.white,
    error: Colors.red.shade700,
  ),
  useMaterial3: true,
  textTheme: AppTypography.textTheme,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFF7043),
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF7043),
      foregroundColor: Colors.white,
      textStyle: AppTypography.textTheme.labelLarge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFFF7043),
      side: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
      textStyle: AppTypography.textTheme.labelLarge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFFF7043),
      textStyle: AppTypography.textTheme.labelLarge,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade200,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  ),
);