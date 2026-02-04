import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mci_booking_app/Screens/HomeScreen.dart';
import '../../Constants/layout_constants.dart';
import '../../Utils/navigation_helper.dart';
import '../navigation/MainNavigationRail.dart';

class DesktopLayoutWrapper extends ConsumerWidget {
  final Widget child;
  final int selectedIndex;

  const DesktopLayoutWrapper({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    // Navigate to HomeScreen with the selected index
    Navigator.of(context).pushAndRemoveUntil(
      NavigationHelper.getRoute(
        context,
        HomeScreen(initialIndex: index),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < LayoutConstants.kMobileBreakpoint) { 
          return child;
        } else {
          return Scaffold(
             backgroundColor: Theme.of(context).colorScheme.surface,
             body: Row(
              children: [
                MainNavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => _onItemTapped(context, index),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(LayoutConstants.kDesktopPageRadius),
                        bottomLeft: Radius.circular(LayoutConstants.kDesktopPageRadius),
                      ),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: LayoutConstants.kDesktopPageBorderWidth,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: child,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
