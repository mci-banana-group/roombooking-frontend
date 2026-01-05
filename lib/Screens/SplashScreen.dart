import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mci_booking_app/Session.dart';
import 'package:mci_booking_app/Screens/HomeScreen.dart';
import 'package:mci_booking_app/Screens/LoginScreen.dart';
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
    super.initState();
    _performLogin();
  }

  Future<void> _performLogin() async {
    setState(() {
      _loading = true;
    });
    Session session = ref.read(sessionProvider);
    bool loggedIn = await session.performCachedLogin();
    
    if (!mounted) return;
    
    setState(() {
      _loading = false;
    });

    if (loggedIn) {
      // Navigate to HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Navigate to LoginScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple loading screen in app design with loading indicator
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.meeting_room,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Room Booking',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 48),
              if (_loading)
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
