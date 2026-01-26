import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mci_booking_app/Session.dart';
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

  static const List<Widget> _pages = [
    HomePage(),
    BookingsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final isAdmin = session.isAdmin;

    // Pages dynamisch (Admin nur wenn Admin)
    final pages = <Widget>[
      const HomePage(),
      const BookingsPage(),
      if (isAdmin) const AdminDashboardPage(),
      const ProfilePage(),
    ];

    // Items dynamisch (Admin-Tab nur wenn Admin)
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: 'Bookings',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    // Schutz: Index kann "zu groß" sein, wenn Admin-Role wegfällt
    if (_selectedIndex >= pages.length) {
      _selectedIndex = pages.length - 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Session session = ref.read(sessionProvider);
              session.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // wichtig bei 4 Tabs
      ),
    );
  }
}