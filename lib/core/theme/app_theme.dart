import 'package:flutter/material.dart';

class JapaniRacerTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF00FF66), // Verde Neón
        onPrimary: const Color(0xFF121212), // Fondo profundo para alto contraste
        secondary: const Color(0xFF00E5FF), // Cian Cyberpunk
        onSecondary: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E), // Superficies y Tarjetas
        onSurface: Colors.white,
        error: const Color(0xFFFF3D00), // Rojo Neón para advertencias
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFF2C2C2C),
            width: 1,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00FF66),
          foregroundColor: const Color(0xFF121212),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF00FF66),
          side: const BorderSide(color: Color(0xFF00FF66), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        bodyLarge: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
        labelMedium: TextStyle(
          color: Color(0xFF00FF66),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
