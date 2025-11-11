import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Predefined countdown themes
class CountdownTheme {
  final String name;
  final Color primaryColor;
  final Color? secondaryColor;
  final bool isGradient;

  const CountdownTheme({
    required this.name,
    required this.primaryColor,
    this.secondaryColor,
    this.isGradient = false,
  });

  static const List<CountdownTheme> presets = [
    CountdownTheme(
      name: 'Purple Dream',
      primaryColor: Color(0xFF667eea),
      secondaryColor: Color(0xFF764ba2),
      isGradient: true,
    ),
    CountdownTheme(
      name: 'Ocean Blue',
      primaryColor: Color(0xFF2193b0),
      secondaryColor: Color(0xFF6dd5ed),
      isGradient: true,
    ),
    CountdownTheme(
      name: 'Sunset Orange',
      primaryColor: Color(0xFFf46b45),
      secondaryColor: Color(0xFFeea849),
      isGradient: true,
    ),
    CountdownTheme(
      name: 'Forest Green',
      primaryColor: Color(0xFF11998e),
      secondaryColor: Color(0xFF38ef7d),
      isGradient: true,
    ),
    CountdownTheme(
      name: 'Rose Pink',
      primaryColor: Color(0xFFe91e63),
      secondaryColor: Color(0xFFf48fb1),
      isGradient: true,
    ),
    CountdownTheme(
      name: 'Royal Purple',
      primaryColor: Color(0xFF673ab7),
      isGradient: false,
    ),
    CountdownTheme(
      name: 'Deep Blue',
      primaryColor: Color(0xFF1976d2),
      isGradient: false,
    ),
    CountdownTheme(
      name: 'Vibrant Red',
      primaryColor: Color(0xFFe53935),
      isGradient: false,
    ),
  ];

  Gradient? getGradient() {
    if (!isGradient || secondaryColor == null) return null;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryColor, secondaryColor!],
    );
  }

  static CountdownTheme fromName(String name) {
    return presets.firstWhere(
      (theme) => theme.name == name,
      orElse: () => presets[0],
    );
  }
}
