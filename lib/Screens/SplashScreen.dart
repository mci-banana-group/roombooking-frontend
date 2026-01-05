import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mci_booking_app/Session.dart';
import 'package:mci_booking_app/Widgets/SignInCard.dart';
import 'package:mci_booking_app/main.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _loading = false;

  @override
  void initState() {
    _performLogin();

    super.initState();
  }

  Future<void> _performLogin() async {
    setState(() {
      _loading = true;
    });
    Session session = ref.watch(sessionProvider);
    bool loggedIn = await session.performCachedLogin();
    setState(() {
      _loading = false;
    });

    if (loggedIn) {
      // Navigate to HomeScreen
    } else {
      // Navigate to LoginScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    Session session = ref.watch(sessionProvider);

    // Simple loading screen in app design with loading indicator
    return SafeArea(child: Center());
  }
}
