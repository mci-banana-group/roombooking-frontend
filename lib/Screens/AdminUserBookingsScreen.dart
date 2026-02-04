import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../Models/auth_models.dart';
import '../Models/admin_user_booking_response.dart';
import '../Models/Enums/booking_status.dart';
import '../Services/admin_repository.dart';
import '../Widgets/BookingCard.dart';
import '../Constants/layout_constants.dart';
import 'AdminRoomDetailScreen.dart';

class AdminUserBookingsScreen extends ConsumerStatefulWidget {
  final UserResponse user;
  const AdminUserBookingsScreen({super.key, required this.user});

  @override
  ConsumerState<AdminUserBookingsScreen> createState() => _AdminUserBookingsScreenState();
}

class _AdminUserBookingsScreenState extends ConsumerState<AdminUserBookingsScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  List<AdminUserBookingResponse> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Default: Next month
    _startDate = DateTime.now();
    _endDate = _startDate.add(const Duration(days: 31));
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final fetched = await ref.read(adminRepositoryProvider).getUserBookings(
      widget.user.id.toString(),
      start: _startDate,
      end: _endDate,
    );
    if (mounted) {
      setState(() {
        _bookings = fetched;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: MediaQuery.of(context).size.width < LayoutConstants.kMobileBreakpoint
          ? AppBar(
              title: Text("Bookings: ${widget.user.firstName} ${widget.user.lastName}"),
              centerTitle: false,
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: LayoutConstants.kMaxContentWidth),
          child: Column(
            children: [
              // Header Card with User Info and Filter
              if (MediaQuery.of(context).size.width >= LayoutConstants.kMobileBreakpoint)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Back',
                      ),
                      const SizedBox(width: 8),
                      Text("Back to Users", style: textTheme.titleMedium),
                    ],
                  ),
                ),
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 0,
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: colorScheme.primary.withOpacity(0.1),
                            child: Icon(Icons.person, color: colorScheme.primary, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${widget.user.firstName} ${widget.user.lastName}", 
                                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                Text(widget.user.email, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          _buildRoleBadge(widget.user.role, colorScheme),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Time Range", style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
                              const SizedBox(height: 4),
                              Text(
                                "${DateFormat('dd.MM.yy').format(_startDate)} - ${DateFormat('dd.MM.yy').format(_endDate)}",
                                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          FilledButton.icon(
                            onPressed: _selectDateRange,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text("Edit Range"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bookings List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _bookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_note_outlined, size: 64, color: colorScheme.outline.withOpacity(0.3)),
                                const SizedBox(height: 16),
                                Text("No bookings found for this range", 
                                  style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 8),
                                Text("The current backend status is documented in `backend_demand.md`.",
                                  style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _bookings.length,
                            itemBuilder: (context, index) {
                              final booking = _bookings[index];
                              return _buildBookingCard(booking, colorScheme, textTheme, dateFormat);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(AdminUserBookingResponse booking, ColorScheme colorScheme, TextTheme textTheme, DateFormat dateFormat) {
    return BookingCard(
      title: booking.description?.isNotEmpty == true ? booking.description! : "Booking #${booking.id}",
      subtitle: "Room: ${booking.roomName ?? "Unknown Room"}",
      startTime: booking.startTime,
      endTime: booking.endTime,
      status: booking.status,
      onSubtitleTap: () async {
        if (booking.roomId != null && booking.roomId != 0) {
           // Helper to find building by name (since response usually has room name not ID, but we have roomId in response model)
           // ideally we fetch the full room object
           
           setState(() => _isLoading = true);
           try {
              // We need a way to get a single room. 
              // AdminRepository.getAllRooms() gets all.
              // Let's filter from all rooms for now as a fallback or add getRoomById.
              // Efficiency: getAllRooms is heavy. 
              // Better: Check if roomName contains building info or assume we need to fetch.
              
              // Let's rely on getAllRooms for now as it's available, optimization later.
              final allRooms = await ref.read(adminRepositoryProvider).getAllRooms();
              final roomIdx = allRooms.indexWhere((r) => r.id == booking.roomId.toString());
              
              if (mounted) setState(() => _isLoading = false);
              
              if (roomIdx != -1 && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminRoomDetailScreen(room: allRooms[roomIdx])),
                );
              } else if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Room details not found.")));
              }
           } catch (e) {
              if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
           }
        }
      },
      actions: [
        TextButton.icon(
          onPressed: () => _confirmCancel(booking),
          icon: const Icon(Icons.close),
          label: const Text('Cancel'),
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
        ),
      ],
    );
  }

  Future<void> _confirmCancel(AdminUserBookingResponse booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking?"),
        content: Text("Are you sure you want to cancel the booking for ${booking.roomName ?? 'Unknown Room'} on ${DateFormat('dd.MM.yyyy').format(booking.startTime)}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text("Cancel Booking"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(adminRepositoryProvider).adminCancelBooking(booking.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Booking cancelled successfully")),
          );
          _loadBookings();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to cancel booking")),
          );
        }
      }
    }
  }



  Widget _buildRoleBadge(String role, ColorScheme colorScheme) {
    Color color;
    switch (role.toUpperCase()) {
      case "ADMIN": color = colorScheme.error; break;
      case "STAFF": color = colorScheme.primary; break;
      case "LECTURER": color = colorScheme.secondary; break;
      case "STUDENT": color = colorScheme.tertiary; break;
      default: color = colorScheme.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
