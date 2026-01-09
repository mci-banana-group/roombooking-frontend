import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/Enums/booking_status.dart';
import '../widgets/mybookings/BookingCard.dart';
import '../widgets/mybookings/BookingStats.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  // Mock data - replace with real data from backend
  late List<Booking> _mockBookings;
  BookingFilterTab _selectedTab = BookingFilterTab.upcoming;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();

    _mockBookings = [
      // Upcoming booking
      Booking(
        id: '8K1679567773769',
        roomId: 'room_001',
        userId: 'user_123',
        startTime: now.add(const Duration(days: 2)),
        endTime: now.add(const Duration(days: 2, hours: 2)),
        status: BookingStatus.confirmed,
        createdAt: now.subtract(const Duration(days: 1)),
        confirmedAt: now,
      ),
      // Another upcoming
      Booking(
        id: '8K1679567773770',
        roomId: 'room_002',
        userId: 'user_123',
        startTime: now.add(const Duration(days: 7)),
        endTime: now.add(const Duration(days: 7, hours: 1, minutes: 30)),
        status: BookingStatus.pending,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      // Past booking
      Booking(
        id: '8K1679567773771',
        roomId: 'room_001',
        userId: 'user_123',
        startTime: now.subtract(const Duration(days: 5)),
        endTime: now.subtract(const Duration(days: 5, hours: -2)),
        status: BookingStatus.confirmed,
        createdAt: now.subtract(const Duration(days: 6)),
        confirmedAt: now.subtract(const Duration(days: 5, hours: 1)),
      ),
      // Another past booking
      Booking(
        id: '8K1679567773772',
        roomId: 'room_003',
        userId: 'user_123',
        startTime: now.subtract(const Duration(days: 10)),
        endTime: now.subtract(const Duration(days: 10, hours: -1, minutes: -30)),
        status: BookingStatus.confirmed,
        createdAt: now.subtract(const Duration(days: 11)),
        confirmedAt: now.subtract(const Duration(days: 10, hours: 1)),
      ),
    ];
  }

  List<Booking> _getFilteredBookings() {
    final now = DateTime.now();

    switch (_selectedTab) {
      case BookingFilterTab.upcoming:
        return _mockBookings
            .where((booking) => booking.startTime.isAfter(now))
            .toList();
      case BookingFilterTab.past:
        return _mockBookings
            .where((booking) => booking.startTime.isBefore(now))
            .toList();
      case BookingFilterTab.all:
        return _mockBookings;
    }
  }

  String _getRoomName(String roomId) {
    // Mock room names - replace with real data
    final roomNames = {
      'room_001': 'Innovation Hub',
      'room_002': 'Conference Room A',
      'room_003': 'Meeting Space B',
    };
    return roomNames[roomId] ?? 'Unknown Room';
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _getFilteredBookings();
    final totalBookings = _mockBookings.length;
    final upcomingBookings =
        _mockBookings.where((b) => b.startTime.isAfter(DateTime.now())).length;
    final pastBookings =
        _mockBookings.where((b) => b.startTime.isBefore(DateTime.now())).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  'My Bookings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Manage your meeting room reservations',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Statistics cards with max width
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BookingStats(
                    totalBookings: totalBookings,
                    upcomingBookings: upcomingBookings,
                    pastBookings: pastBookings,
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Tab filter with max width
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildTabBar(context),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Bookings list with max width
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: filteredBookings.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return BookingCard(
                          booking: booking,
                          roomName: _getRoomName(booking.roomId),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              context,
              label: 'Upcoming Bookings',
              tab: BookingFilterTab.upcoming,
              isFirst: true,
              isLast: false,
            ),
          ),
          Expanded(
            child: _buildTab(
              context,
              label: 'Past Bookings',
              tab: BookingFilterTab.past,
              isFirst: false,
              isLast: false,
            ),
          ),
          Expanded(
            child: _buildTab(
              context,
              label: 'All Bookings',
              tab: BookingFilterTab.all,
              isFirst: false,
              isLast: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
      BuildContext context, {
        required String label,
        required BookingFilterTab tab,
        required bool isFirst,
        required bool isLast,
      }) {
    final isSelected = _selectedTab == tab;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = tab;
          });
        },
        borderRadius: BorderRadius.horizontal(
          left: isFirst ? const Radius.circular(12) : Radius.zero,
          right: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            border: isSelected
                ? Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              ),
            )
                : null,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(12) : Radius.zero,
              right: isLast ? const Radius.circular(12) : Radius.zero,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    String message;

    switch (_selectedTab) {
      case BookingFilterTab.upcoming:
        message = 'No upcoming bookings';
      case BookingFilterTab.past:
        message = 'No past bookings';
      case BookingFilterTab.all:
        message = 'No bookings found';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

enum BookingFilterTab { upcoming, past, all }
