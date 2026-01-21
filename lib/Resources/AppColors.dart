import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  /// Primary Dark - dark charcoal for headers/text
  static const Color primaryDark = Color(0xFF2D3436); // 0xFF004a83 -> mci blue

  /// Primary Accent - mint/teal green for highlights and interactive elements
  static const Color primaryAccent = Color(0xFF7DD3C0); // 0xFFF4991A -> mci orange

  /// Background - light gray for overall background
  static const Color backgroundLight = Color(0xFFF0F4F8);

  /// Accent Light - light mint for cards and info sections
  static const Color accentLight = Color(0xFFE8F8F5);

  /// Status Colors for room indicators
  static const Color statusBlue = Color(0xFF2196F3);
  static const Color statusYellow = Color(0xFFFFEB3B);
  static const Color statusRed = Color(0xFFF44336);

  /// Light colour scheme
  static ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryAccent,
    onPrimary: AppColors.primaryDark,
    secondary: AppColors.statusBlue,
    onSecondary: Colors.white,
    background: AppColors.backgroundLight,
    onBackground: AppColors.primaryDark,
    surface: AppColors.accentLight,
    onSurface: AppColors.primaryDark,
    error: AppColors.statusRed,
    onError: Colors.white,
  );

  /// Dark colour scheme
  static ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryAccent,
    onPrimary: Colors.white,
    secondary: AppColors.statusYellow,
    onSecondary: AppColors.primaryDark,
    background: AppColors.primaryDark,
    onBackground: AppColors.accentLight,
    surface: AppColors.primaryDark,
    onSurface: AppColors.accentLight,
    error: AppColors.statusRed,
    onError: Colors.white,
  );

  /// Light ThemeData
  ///

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
