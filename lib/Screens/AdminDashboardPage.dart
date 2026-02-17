import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'AdminStatsView.dart';
import 'AdminRoomManagement.dart';
import 'AdminUserManagement.dart';
import '../Resources/AppColors.dart';

import '../Constants/layout_constants.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Rebuild when tab changes to update NavigationRail selection
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >= LayoutConstants.kMobileBreakpoint;

    return Scaffold(
      body: isDesktop
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Minimal Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Admin Dashboard",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(width: 48),
                      // Navigation Items
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AdminHeaderItem(
                            label: 'Users',
                            icon: Icons.people,
                            isSelected: _tabController.index == 0,
                            onTap: () {
                              if (_navigatorKey.currentState != null && _navigatorKey.currentState!.canPop()) {
                                _navigatorKey.currentState!.popUntil((route) => route.isFirst);
                              }
                              setState(() => _tabController.index = 0);
                            },
                          ),
                          const SizedBox(width: 8),
                          _AdminHeaderItem(
                            label: 'Buildings/Rooms',
                            icon: Icons.meeting_room,
                            isSelected: _tabController.index == 1,
                            onTap: () {
                               if (_navigatorKey.currentState != null && _navigatorKey.currentState!.canPop()) {
                                _navigatorKey.currentState!.popUntil((route) => route.isFirst);
                              }
                              setState(() => _tabController.index = 1);
                            },
                          ),
                          const SizedBox(width: 8),
                          _AdminHeaderItem(
                            label: 'Statistics',
                            icon: Icons.bar_chart,
                            isSelected: _tabController.index == 2,
                            onTap: () {
                               if (_navigatorKey.currentState != null && _navigatorKey.currentState!.canPop()) {
                                _navigatorKey.currentState!.popUntil((route) => route.isFirst);
                              }
                              setState(() => _tabController.index = 2);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content with Nested Navigator
                Expanded(
                  child: Navigator(
                    key: _navigatorKey,
                    onGenerateRoute: (settings) {
                      return MaterialPageRoute(
                        builder: (context) => TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            AdminUserManagement(),
                            AdminRoomManagement(),
                            AdminStatsView(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TabBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(icon: Icon(Icons.people), text: 'Users'),
                      Tab(icon: Icon(Icons.meeting_room), text: 'Buildings/Rooms'),
                      Tab(icon: Icon(Icons.bar_chart), text: 'Statistics'),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      AdminUserManagement(),
                      AdminRoomManagement(),
                      AdminStatsView()
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _AdminHeaderItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminHeaderItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: isSelected 
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: color, width: 2))
            )
          : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
