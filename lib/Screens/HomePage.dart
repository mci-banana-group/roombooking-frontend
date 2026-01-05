import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 80, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text(
            'Home',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('Welcome to the Room Booking App'),
        ],
      ),
    );
  }
}
