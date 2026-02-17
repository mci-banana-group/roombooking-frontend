import 'package:flutter/material.dart';

import '../Constants/layout_constants.dart';
import '../Models/Enums/booking_status.dart';
import '../Models/booking.dart';
import '../Resources/AppColors.dart';
import '../Services/auth_service.dart';
import '../Services/booking_service.dart';
import '../Widgets/BookingCard.dart';
import '../Widgets/mybookings/BookingStats.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final AuthService _authService = AuthService();

  final BookingService _bookingService = BookingService();

  List<Booking> _bookings = [];

  BookingFilterTab _selectedTab = BookingFilterTab.upcoming;

  bool _isLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  // âœ… Check-in function
  Future<void> _showCheckInDialog(Booking booking) async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check in to booking'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Enter check-in code'),
          obscureText: false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Check In'),
          ),
        ],
      ),
    );

    if (result == true) {
      final code = controller.text.trim();
      if (code.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a code'),
              backgroundColor: AppColors.mciOrange,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        print('âœ… Checking in with code: $code');

        // âœ… Use BookingService.checkInBooking instead of AuthService.checkIn
        final bookingIdInt = int.tryParse(booking.id) ?? 0;
        final success = await _bookingService.checkInBooking(
          bookingId: bookingIdInt,
          code: code,
        );

        if (mounted) Navigator.pop(context); // Close loading dialog

        if (success) {
          print('âœ… Check-in successful');
          await _loadBookings();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Checked in successfully'),
                backgroundColor: AppColors.chartCompleted,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          print('âŒ Check-in failed');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Invalid code or check-in failed'),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) Navigator.pop(context); // Close loading dialog
        print('âŒ Check-in error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }

    controller.dispose();
  }

  // âœ… Check if booking is within 15 minutes before start time
  bool _isCheckInAvailable(Booking booking) {
    final now = DateTime.now();
    final fifteenMinutesBefore = booking.startTime.subtract(
      const Duration(minutes: 15),
    );
    final fifteenMinutesAfter = booking.startTime.add(
      const Duration(minutes: 15),
    );

    return now.isAfter(fifteenMinutesBefore) &&
        now.isBefore(fifteenMinutesAfter);
  }

  // âœ… Check if booking is in the past (based on status)
  bool _isBookingPast(Booking booking) {
    // A booking is past if its status is CANCELLED, CHECKED_IN, COMPLETED, or NO_SHOW
    return booking.status == BookingStatus.cancelled ||
        booking.status == BookingStatus.checkedIn ||
        booking.status == BookingStatus.completed ||
        booking.status == BookingStatus.expired;
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final bookingsData = await _authService.getMyBookings();
      final bookings = bookingsData
          .map((json) => Booking.fromJson(json as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _bookings = bookings;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _bookings = [];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDelete(Booking booking) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (result == true) {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        final success = await _bookingService.cancelBooking(booking.id);

        if (mounted) Navigator.pop(context); // Close loading dialog

        if (success) {
          _loadBookings();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Booking cancelled successfully'),
                backgroundColor: AppColors.chartCompleted,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to cancel booking'),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) Navigator.pop(context); // Close loading dialog
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  List<Booking> _getFilteredBookings() {
    final now = DateTime.now();
    switch (_selectedTab) {
      case BookingFilterTab.upcoming:
        // Upcoming = booking that hasn't ended yet and isn't cancelled/no-show.
        final bookings = _bookings
            .where(
              (booking) =>
                  now.isBefore(booking.endTime) &&
                  booking.status != BookingStatus.cancelled &&
                  booking.status != BookingStatus.expired,
            )
            .toList();
        bookings.sort((a, b) => a.startTime.compareTo(b.startTime));
        return bookings;

      case BookingFilterTab.past:
        // Past = everything else (including cancelled/no-show).
        final bookings = _bookings
            .where(
              (booking) =>
                  !now.isBefore(booking.endTime) ||
                  booking.status == BookingStatus.cancelled ||
                  booking.status == BookingStatus.expired,
            )
            .toList();
        bookings.sort((a, b) => b.startTime.compareTo(a.startTime));
        return bookings;

      case BookingFilterTab.all:
        final bookings = List<Booking>.from(_bookings);
        // Closest to now first.
        bookings.sort((a, b) {
          final aDiff = a.startTime.difference(now).abs();
          final bDiff = b.startTime.difference(now).abs();
          final diffCompare = aDiff.compareTo(bDiff);
          if (diffCompare != 0) return diffCompare;
          return a.startTime.compareTo(b.startTime);
        });
        return bookings;
    }
  }

  String _getRoomName(Booking booking) {
    return booking.room?.name ?? 'Room ${booking.roomId}';
  }

  String _getBuildingName(Booking booking) {
    return booking.room?.building?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _getFilteredBookings();
    final now = DateTime.now();

    // Calculate stats based on status
    final totalBookings = _bookings.length;
    final upcomingBookings = _bookings
        .where(
          (b) =>
              now.isBefore(b.endTime) &&
              b.status != BookingStatus.cancelled &&
              b.status != BookingStatus.expired,
        )
        .length;
    final pastBookings = _bookings
        .where(
          (b) =>
              !now.isBefore(b.endTime) ||
              b.status == BookingStatus.cancelled ||
              b.status == BookingStatus.expired,
        )
        .length;

    // Return body directly to avoid nested Scaffold rounding issues
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Failed to load bookings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
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
      );
    }

    return CustomScrollView(
      slivers: [


        // Statistics cards with max width
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: LayoutConstants.kMaxContentWidth),
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
              constraints: const BoxConstraints(maxWidth: LayoutConstants.kMaxContentWidth),
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
                constraints: const BoxConstraints(maxWidth: LayoutConstants.kMaxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      final isCheckInAvailable = _isCheckInAvailable(booking);
                      final isPast = _isBookingPast(booking);

                      return BookingCard(
                        title: booking.description.isNotEmpty ? booking.description : 'No title',
                        subtitle: '${_getRoomName(booking)} • ${_getBuildingName(booking)}',
                        startTime: booking.startTime,
                        endTime: booking.endTime,
                        status: booking.status,
                        actions: [
                          if (isCheckInAvailable && !isPast)
                            ElevatedButton.icon(
                              onPressed: () => _showCheckInDialog(booking),
                              icon: const Icon(Icons.login),
                              label: const Text('Check In'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.chartCompleted,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          if (!isPast && !isCheckInAvailable)
                            TextButton.icon(
                              onPressed: () => _confirmDelete(booking),
                              icon: const Icon(Icons.close),
                              label: const Text('Cancel'),
                              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                            ),
                        ],

                      );
                    },
                  ),
                ),
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
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
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

enum BookingFilterTab { upcoming, past, all }
