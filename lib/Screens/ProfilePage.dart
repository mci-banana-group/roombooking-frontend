import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mci_booking_app/main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Your profile information'),
          const SizedBox(height: 32),

          //  Admin-Button per Consumer
          Consumer(
            builder: (context, ref, _) {
              final session = ref.watch(sessionProvider);

              return Column(
                children: [
                  if (session.isAdmin) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Admin Panel'),
                      onPressed: () => Navigator.pushNamed(context, '/admin'),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: () {
                      ref.read(sessionProvider).logout();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
