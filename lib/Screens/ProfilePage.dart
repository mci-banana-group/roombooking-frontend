import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mci_booking_app/main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Consumer(
                  builder: (context, ref, _) {
                    final session = ref.watch(sessionProvider);
                    final user = session.currentUser;

                    if (user == null) {
                      return const Center(child: Text('No user data available'));
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar Section
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // User Details List
                        Card(
                          elevation: 2,
                          shadowColor: Colors.black.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                _buildDetailItem(
                                  context,
                                  Icons.badge_outlined,
                                  'Full Name',
                                  '${user.firstName} ${user.lastName}',
                                ),
                                const Divider(indent: 70, endIndent: 20, height: 1),
                                _buildDetailItem(
                                  context,
                                  Icons.email_outlined,
                                  'Email Address',
                                  user.email,
                                ),
                                const Divider(indent: 70, endIndent: 20, height: 1),
                                _buildDetailItem(
                                  context,
                                  Icons.work_outline,
                                  'User Role',
                                  user.role,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Actions
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            onPressed: () {
                              ref.read(sessionProvider).logout();
                              Navigator.of(context).pushReplacementNamed('/login');
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).hintColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
