import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  /// MCI Brand Colors
  static const Color mciBlue = Color(0xFF004a83);
  static const Color mciOrange = Color(0xFFF4991A);

  /// Text / Foundation Colors
  static const Color primaryDark = Color(0xFF2D3436); // Dark charcoal for text
  static const Color backgroundLight = Color(0xFFF0F4F8);
  static const Color accentLight = Color(0xFFE8F8F5);
  static const Color darkBackground = Color(0xFF121212); // Deep dark for dark mode

  /// Status Colors for room indicators
  static const Color statusBlue = Color(0xFF2196F3);
  static const Color statusYellow = Color(0xFFFFEB3B);
  static const Color statusRed = Color(0xFFF44336);

  /// Light colour scheme
  static ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: mciBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD6E4FF), // Very light blue
    onPrimaryContainer: mciBlue,
    secondary: mciOrange,
    onSecondary: primaryDark,
    secondaryContainer: Color(0xFFFFDBAA), // Light orange
    onSecondaryContainer: Color(0xFF5D4000), // Dark brown/orange
    background: backgroundLight,
    onBackground: primaryDark,
    surface: Colors.white,
    onSurface: primaryDark,
    error: statusRed,
    onError: Colors.white,
  );

  /// Dark colour scheme
  static ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF90CAF9), // Lighter Blue for Dark Mode accessibility
    onPrimary: mciBlue,         // Dark Blue text on Light Blue
    primaryContainer: mciBlue,  // Dark Blue container
    onPrimaryContainer: Colors.white,
    secondary: mciOrange,
    onSecondary: Colors.black,
    secondaryContainer: Color(0xFF5D4000), // Dark brown/orange
    onSecondaryContainer: Color(0xFFFFDBAA), // Light orange
    background: darkBackground,
    onBackground: Color(0xFFE0E0E0),
    surface: Color(0xFF1E1E1E),
    onSurface: Color(0xFFE0E0E0),
    error: statusRed,
    onError: Colors.white,
  );

  /// Light ThemeData
  static final ThemeData lightTheme = ThemeData.from(
    colorScheme: lightColorScheme,
    textTheme: Typography.blackMountainView.apply(fontFamily: 'PPFormula'),
  ).copyWith(
    scaffoldBackgroundColor: lightColorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'PPFormula',
        color: lightColorScheme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: lightColorScheme.onPrimary),
    ),
  );

  /// Dark ThemeData
  static final ThemeData darkTheme = ThemeData.from(
    colorScheme: darkColorScheme,
    textTheme: Typography.whiteMountainView.apply(fontFamily: 'PPFormula'),
  ).copyWith(
    scaffoldBackgroundColor: darkColorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.primary,
      foregroundColor: darkColorScheme.onPrimary,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'PPFormula',
        color: darkColorScheme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: darkColorScheme.onPrimary),
    ),
  );
}
