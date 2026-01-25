import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mci_booking_app/Screens/SplashScreen.dart';
import 'package:mci_booking_app/Screens/LoginScreen.dart';
import 'package:mci_booking_app/Screens/HomeScreen.dart';

import 'Resources/AppColors.dart';
import 'Session.dart';

void main() {
  runApp(const MyApp());
}

final sessionProvider = ChangeNotifierProvider((ref) => Session());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Room Booking',
        theme: AppColors.lightTheme,
        darkTheme: AppColors.darkTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
