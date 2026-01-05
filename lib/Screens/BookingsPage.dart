import 'package:flutter/material.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book, size: 80, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text(
            'Bookings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('Your room bookings will appear here'),
        ],
      ),
    );
  }
}
