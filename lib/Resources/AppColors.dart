import 'package:flutter/material.dart';
import '../Models/Enums/booking_status.dart';

class RoomStatusColors {
  static const Color free = Color(0xFF2E7D32);
  static const Color onFree = Color(0xFFFFFFFF);

  static const Color reserved = Color(0xFFF9A825);
  static const Color onReserved = Color(0xFF1F1400);

  static const Color occupied = Color(0xFFC62828);
  static const Color onOccupied = Color(0xFFFFFFFF);
}

class AppColors {
  // --- Brand colors from MCI CI ---
  static const Color mciBlue = Color(0xFF004983);
  static const Color mciOrange = Color(0xFFFF9900);
  static const Color mciRed = Color(0xFF821131);

  // --- Chart Colors (Legacy support) ---
  static Color chartTotal(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return colorScheme.brightness == Brightness.dark
        ? colorScheme.secondary
        : colorScheme.primary;
  }
  static const Color chartReserved = RoomStatusColors.reserved;
  static const Color chartCompleted = Color(0xFF43A047);
  static const Color chartCheckedIn = Color(0xFF00ACC1);
  static const Color chartUserCancelled = Color(0xFF8E24AA);
  static const Color chartAdminCancelled = Color(0xFF607D8B);
  static const Color chartCancelled = Color(0xFF6D4C41);
  static const Color chartNoShowRed = Color(0xFFE53935);

  // --- Helper ---
  static Color getBookingStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return chartReserved;
      case BookingStatus.completed:
        return chartCompleted;
      case BookingStatus.checkedIn:
        return chartCheckedIn;
      case BookingStatus.cancelled:
        return chartNoShowRed; // Using the red for cancelled

      case BookingStatus.expired:
        return Colors.grey;
    }
  }

  // --- Light Scheme ---
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: mciBlue,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD5E3FF),
    onPrimaryContainer: Color(0xFF001B33),
    inversePrimary: Color(0xFF9BCBFF),

    secondary: mciOrange,
    onSecondary: Color(0xFF2B1A00),
    secondaryContainer: Color(0xFFFFE2B8),
    onSecondaryContainer: Color(0xFF2B1A00),

    tertiary: mciRed,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFD9DF),
    onTertiaryContainer: Color(0xFF33000F),

    surface: Color(0xFFF8FAFF),
    onSurface: Color(0xFF111827),
    surfaceVariant: Color(0xFFDEE3F1),
    onSurfaceVariant: Color(0xFF424A5A),

    surfaceTint: mciBlue,
    inverseSurface: Color(0xFF2C313A),
    onInverseSurface: Color(0xFFEEF1F7),

    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),

    outline: Color(0xFF727A8B),
    outlineVariant: Color(0xFFC2C8D6),
    scrim: Color(0xFF000000),

    surfaceBright: Color(0xFFF8FAFF),
    surfaceDim: Color(0xFFE0E4EB),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF2F5FC),
    surfaceContainer: Color(0xFFECEFF7),
    surfaceContainerHigh: Color(0xFFE6E9F1),
    surfaceContainerHighest: Color(0xFFE0E4EB),
  );

  // --- Dark Scheme ---
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    // SWAPPED: Primary is now Orange (MciOrange)
    primary: mciOrange,
    onPrimary: Color(0xFF2B1A00), // Dark brown (from Light OnSecondary)
    primaryContainer: Color(0xFF633F00), // Darker orange container (from Dark SecondaryContainer)
    onPrimaryContainer: Color(0xFFFFE2B8), // Light orange text (from Dark OnSecondaryContainer)

    // SWAPPED: Secondary is now Blue (from Snippet's Primary)
    secondary: Color(0xFF9BCBFF),
    onSecondary: Color(0xFF003256),
    secondaryContainer: Color(0xFF003A65),
    onSecondaryContainer: Color(0xFFCFE5FF),

    inversePrimary: mciBlue,

    tertiary: Color(0xFFFFB2C0),
    onTertiary: Color(0xFF4E001A),
    tertiaryContainer: Color(0xFF651027),
    onTertiaryContainer: Color(0xFFFFD9DF),

    surface: Color(0xFF0F141A),
    onSurface: Color(0xFFE6E9EF),
    surfaceVariant: Color(0xFF414754),
    onSurfaceVariant: Color(0xFFC1C7D5),

    surfaceTint: mciOrange,
    inverseSurface: Color(0xFFE6E9EF),
    onInverseSurface: Color(0xFF1B2027),

    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),

    outline: Color(0xFF8B919F),
    outlineVariant: Color(0xFF5A6170),
    scrim: Color(0xFF000000),

    surfaceBright: Color(0xFF353B45),
    surfaceDim: Color(0xFF0F141A),
    surfaceContainerLowest: Color(0xFF0A0F14),
    surfaceContainerLow: Color(0xFF161B22),
    surfaceContainer: Color(0xFF1B2027),
    surfaceContainerHigh: Color(0xFF262B34),
    surfaceContainerHighest: Color(0xFF303642),
  );

  // --- Typography ---
  static const TextTheme mciTextTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.normal, fontSize: 57, height: 64/57),
    displayMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.normal, fontSize: 45, height: 52/45),
    displaySmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.normal, fontSize: 36, height: 44/36),

    headlineLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.normal, fontSize: 32, height: 40/32),
    headlineMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.normal, fontSize: 28, height: 36/28),
    headlineSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.normal, fontSize: 24, height: 32/24),

    titleLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 22, height: 28/22),
    titleMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 16, height: 24/16, letterSpacing: 0.15),
    titleSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 14, height: 20/14, letterSpacing: 0.1),

    bodyLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.normal, fontSize: 16, height: 24/16, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.normal, fontSize: 14, height: 20/14, letterSpacing: 0.25),
    bodySmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.normal, fontSize: 12, height: 16/12, letterSpacing: 0.4),

    labelLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 14, height: 20/14, letterSpacing: 0.1),
    labelMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 12, height: 16/12, letterSpacing: 0.5),
    labelSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 11, height: 16/11, letterSpacing: 0.5),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    textTheme: mciTextTheme,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: lightColorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
      elevation: 0,
      titleTextStyle: mciTextTheme.titleLarge?.copyWith(
        color: lightColorScheme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: lightColorScheme.onPrimary),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    textTheme: mciTextTheme.apply(
      bodyColor: darkColorScheme.onSurface,
      displayColor: darkColorScheme.onSurface,
    ),
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: darkColorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.surface,
      foregroundColor: darkColorScheme.onSurface,
      elevation: 0,
      titleTextStyle: mciTextTheme.titleLarge?.copyWith(
        color: darkColorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: darkColorScheme.onSurface),
    ),
  );
}
