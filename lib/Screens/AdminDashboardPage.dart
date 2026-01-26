import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mci_booking_app/main.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    // 🔒 Guard: Nur Admin darf rein
    if (!session.isAdmin) {
      return const Center(child: Text('Access denied'));
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: const [
          TabBar(
            tabs: [
              Tab(icon: Icon(Icons.view_list), text: 'Bookings'),
              Tab(icon: Icon(Icons.meeting_room), text: 'Rooms'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _AdminBookingsOverview(),
                _AdminRoomManagement(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBookingsOverview extends StatelessWidget {
  const _AdminBookingsOverview();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TODO: Bookings Overview (Admin)'),
    );
  }
}

class _AdminRoomManagement extends StatelessWidget {
  const _AdminRoomManagement();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TODO: Room Management (Create + List)'),
    );
  }
}
