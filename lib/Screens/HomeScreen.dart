import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mci_booking_app/Screens/HomePage.dart';
import 'package:mci_booking_app/Screens/BookingsPage.dart';
import 'package:mci_booking_app/Screens/ProfilePage.dart';
import 'package:mci_booking_app/Screens/AdminDashboardPage.dart';
import 'package:mci_booking_app/main.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final bool isAdmin = session.isAdmin;

    /// Seiten (Admin bekommt extra Tab)
    final List<Widget> pages = [
      const HomePage(),
      const BookingsPage(),
      const ProfilePage(),
      if (isAdmin) const AdminDashboardPage(),
    ];

    /// Bottom-Navigation Items
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: 'Bookings',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];

    /// Sicherheit: falls Admin → User wechselt
    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Room Booking (Admin)' : 'Room Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(sessionProvider).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),

      body: pages[_selectedIndex],

      /// 🔧 FIX für unsichtbare BottomBar bei 4 Tabs
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.25),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // ✅ extrem wichtig
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          items: items,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
