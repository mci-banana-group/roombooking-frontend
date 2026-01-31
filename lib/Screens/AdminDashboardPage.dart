import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/room.dart';
import '../Models/Enums/room_status.dart';
import '../Services/admin_repository.dart';
import '../Session.dart'; 
import '../main.dart';
import 'AdminStatsView.dart';
import 'AdminRoomManagement.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.meeting_room), text: 'Buildings/Rooms'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Statistics')
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminRoomManagement(),
            AdminStatsView(),
          ],
        ),
      ),
    );
  }
}