import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mci_booking_app/Resources/AppColors.dart';
import 'package:mci_booking_app/Resources/Dimen.dart';
import 'package:mci_booking_app/main.dart';
import 'package:mci_booking_app/Models/user.dart';
import 'package:mci_booking_app/Models/Enums/user_role.dart';

import '../Screens/HomeScreen.dart';

class SignInCard extends ConsumerStatefulWidget {
  const SignInCard({super.key});

  @override
  ConsumerState<SignInCard> createState() => _SignInCardState();
}

class _SignInCardState extends ConsumerState<SignInCard> {
  bool _passwordVisible = false;
  bool _asAdmin = false;

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primaryAccent;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: Dimen.cardBorderRadius),
        child: Padding(
          padding: Dimen.cardInnerPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: primaryColor),
                child: const Center(
                  child: Text(
                    'MCI',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'MCI Meeting Rooms',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in with your university credentials',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: Dimen.inputElementRadius),
                  hintText: 'Enter your username',
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock, color: primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: primaryColor),
                    onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                  ),
                  border: OutlineInputBorder(borderRadius: Dimen.inputElementRadius),
                  hintText: 'Enter your password',
                ),
              ),

              const SizedBox(height: 12),

              //Admin-Schalter
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Als Admin anmelden'),
                value: _asAdmin,
                onChanged: (v) => setState(() => _asAdmin = v),
              ),

              const SizedBox(height: 4),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot password?', style: TextStyle(color: primaryColor)),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  //Rolle setzen
                  final session = ref.read(sessionProvider);

                  final user = User(
                    id: 'local-1',
                    name: _asAdmin ? 'Admin Demo' : 'User Demo',
                    role: _asAdmin ? UserRole.admin : UserRole.user,
                  );

                  session.setCurrentUser(user);

                  // Navigation wie bisher
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: Dimen.inputElementRadius),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text('Sign In', style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 32),

              const Text('Having issues?', textAlign: TextAlign.center),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Contact Support', style: TextStyle(color: primaryColor)),
                  ),
                  const Text('•', style: TextStyle(color: primaryColor)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Privacy Policy', style: TextStyle(color: primaryColor)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
