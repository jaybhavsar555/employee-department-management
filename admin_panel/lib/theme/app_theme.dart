import 'package:flutter/material.dart';

/// Central Material 3 theme — one place to change colors and form styles
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const seed = Color(0xFF1565C0); // Blue primary color
    return ThemeData(
      useMaterial3: true, // Material Design 3 components
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
      // All text fields get outline border and padding
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      // Flat cards with rounded corners and light border
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      // Table header row background
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
      ),
    );
  }
}
