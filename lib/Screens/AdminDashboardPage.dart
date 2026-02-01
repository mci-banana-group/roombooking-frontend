import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'AdminStatsView.dart';
import 'AdminRoomManagement.dart';
import '../Resources/AppColors.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TabBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: Theme.of(context).colorScheme.primary,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(icon: Icon(Icons.meeting_room), text: 'Buildings/Rooms'),
                  Tab(icon: Icon(Icons.bar_chart), text: 'Statistics'),
                ],
              ),
            ),

            // Tab Content
            const Expanded(child: TabBarView(children: [AdminRoomManagement(), AdminStatsView()])),
          ],
        ),
      ),
    );
  }
}
