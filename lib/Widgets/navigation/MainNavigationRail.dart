import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Session.dart';
import '../../main.dart';

class MainNavigationRail extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const MainNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final bool isAdmin = session.isAdmin;

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

    return NavigationRail(
      backgroundColor: Colors.transparent,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: railDestinations,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      indicatorColor: Theme.of(context).colorScheme.primaryContainer,
      selectedIconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      unselectedIconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
      selectedLabelTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }
}
