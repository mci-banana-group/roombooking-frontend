import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mci_booking_app/Screens/SplashScreen.dart';

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
    return Phoenix(
      child: MaterialApp(
        title: 'Room Booking',
        theme: AppColors.lightTheme,
        darkTheme: AppColors.darkTheme,
        home: SplashScreen(),
      ),
    );
  }
}
