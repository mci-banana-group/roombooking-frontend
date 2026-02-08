import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mci_booking_app/Session.dart';
import 'package:mci_booking_app/Screens/HomePage.dart';
import 'package:mci_booking_app/Screens/BookingsPage.dart';
import 'package:mci_booking_app/Screens/ProfilePage.dart';
import 'package:mci_booking_app/Screens/AdminDashboardPage.dart';
import 'package:mci_booking_app/main.dart';
import 'package:mci_booking_app/Constants/layout_constants.dart';
import '../Widgets/navigation/MainNavigationRail.dart';

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

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // On desktop, handle navigation via nested Navigator
    final isDesktop = MediaQuery.of(context).size.width >= 640;
    if (isDesktop && _navigatorKey.currentState != null) {
      _navigatorKey.currentState!.popUntil((route) => route.isFirst);
      final List<Widget> pages = [
        const HomePage(),
        const BookingsPage(),
        const ProfilePage(),
        if (ref.read(sessionProvider).isAdmin) const AdminDashboardPage(),
      ];
      if (index < pages.length) {
         _navigatorKey.currentState!.pushReplacement(
           PageRouteBuilder(
             pageBuilder: (_, __, ___) => pages[index],
             transitionDuration: Duration.zero,
           ),
         );
      }
    }
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
          if (constraints.maxWidth < LayoutConstants.kMobileBreakpoint) {
            // Mobile View
            return Scaffold(
              body: pages[_selectedIndex],
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(LayoutConstants.kDesktopPageRadius),
                    topRight: Radius.circular(LayoutConstants.kDesktopPageRadius),
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent, // Use container color
                    elevation: 0,
                    items: bottomNavItems,
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: Theme.of(context).colorScheme.primary,
                    unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            );
          } else {
            // Desktop View
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface, // Rail background color
              body: Row(
                children: [
                   MainNavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onItemTapped,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background, // Page content color
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(LayoutConstants.kDesktopPageRadius),
                          bottomLeft: Radius.circular(LayoutConstants.kDesktopPageRadius),
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface, // Subtle border
                          width: LayoutConstants.kDesktopPageBorderWidth,
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: pages[_selectedIndex],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
