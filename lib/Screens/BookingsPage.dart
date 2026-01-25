import 'package:flutter/material.dart';
import '../Models/booking.dart';
import '../Models/room.dart';
import '../Widgets/mybookings/BookingCard.dart';
import '../Widgets/mybookings/BookingStats.dart';
import '../Services/auth_service.dart';
import '../Services/room_service.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final AuthService _authService = AuthService();
  final RoomService _roomService = RoomService();

  List<Booking> _bookings = [];
  Map<String, Room> _roomsCache = {};
  BookingFilterTab _selectedTab = BookingFilterTab.upcoming;

  bool _isLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final bookingsData = await _authService.getMyBookings();
      final bookings = bookingsData.map((json) => Booking.fromJson(json as Map<String, dynamic>)).toList();

      // Fetch room details for all unique room IDs
      final uniqueRoomIds = bookings.map((b) => b.roomId).toSet();
      final roomsCache = <String, Room>{};

      for (final roomId in uniqueRoomIds) {
        final room = await _roomService.getRoomById(roomId);
        if (room != null) {
          roomsCache[roomId] = room;
        }
      }

      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _roomsCache = roomsCache;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _bookings = [];
        _roomsCache = {};
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Booking> _getFilteredBookings() {
    final now = DateTime.now();

    switch (_selectedTab) {
      case BookingFilterTab.upcoming:
        return _bookings.where((booking) => booking.startTime.isAfter(now)).toList();
      case BookingFilterTab.past:
        return _bookings.where((booking) => booking.startTime.isBefore(now)).toList();
      case BookingFilterTab.all:
        return _bookings;
    }
  }

  String _getRoomName(String roomId) {
    return _roomsCache[roomId]?.name ?? 'Room $roomId';
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _getFilteredBookings();
    final now = DateTime.now();
    final totalBookings = _bookings.length;
    final upcomingBookings = _bookings.where((b) => b.startTime.isAfter(now)).length;
    final pastBookings = _bookings.where((b) => b.startTime.isBefore(now)).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 0,
        actions: [
          IconButton(tooltip: 'Refresh', onPressed: _isLoading ? null : _loadBookings, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    const Text('Failed to load bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadBookings,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : CustomScrollView(
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
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildTabBar(context)),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Bookings list with max width
                if (filteredBookings.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState(context))
                else
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              final booking = filteredBookings[index];
                              return BookingCard(booking: booking, roomName: _getRoomName(booking.roomId));
                            },
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
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
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
            child: _buildTab(context, label: 'All Bookings', tab: BookingFilterTab.all, isFirst: false, isLast: true),
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
            color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
            border: isSelected
                ? Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 3))
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
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
          Icon(Icons.calendar_today, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

enum BookingFilterTab { upcoming, past, all }
