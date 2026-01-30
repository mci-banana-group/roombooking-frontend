import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mci_booking_app/Session.dart';
import 'package:mci_booking_app/Screens/HomePage.dart';
import 'package:mci_booking_app/Screens/BookingsPage.dart';
import 'package:mci_booking_app/Screens/ProfilePage.dart';
import 'package:mci_booking_app/Screens/AdminDashboardPage.dart';
import 'package:mci_booking_app/main.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

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
    final bool isAdmin = session.isAdmin;

    /// Seiten (Admin bekommt extra Tab)
    final List<Widget> pages = [
      const HomePage(),
      const BookingsPage(),
      const ProfilePage(),
      if (isAdmin) const AdminDashboardPage(),
    ];

    /// Bottom-Navigation Items
    final List<BottomNavigationBarItem> bottomNavItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];

    /// NavigationRail Destinations
    final List<NavigationRailDestination> railDestinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.home),
        label: Text('Home'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.book),
        label: Text('Bookings'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person),
        label: Text('Profile'),
      ),
      if (isAdmin)
        const NavigationRailDestination(
          icon: Icon(Icons.admin_panel_settings),
          label: Text('Admin'),
        ),
    ];

    /// Sicherheit: falls Admin → User wechselt
    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 640) {
            // Mobile View
            return Scaffold(
              body: pages[_selectedIndex],
              bottomNavigationBar: BottomNavigationBar(
                items: bottomNavItems,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
              ),
            );
          } else {
            // Desktop View
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.all,
                  destinations: railDestinations,
                ),
                Expanded(
                  child: pages[_selectedIndex],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
