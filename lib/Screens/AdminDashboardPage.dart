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
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Material(
              child: const TabBar(
                labelColor: AppColors.mciOrange,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.mciOrange,
                tabs: [
                  Tab(icon: Icon(Icons.meeting_room), text: 'Buildings/Rooms'),
                  Tab(icon: Icon(Icons.bar_chart), text: 'Statistics')
                ],
              ),
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                AdminRoomManagement(),
                AdminStatsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}