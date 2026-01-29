import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/room.dart' as api;
import '../Models/Enums/equipment_type.dart';
import '../Services/auth_service.dart';
import '../Services/room_service.dart';
import 'package:mci_booking_app/Screens/HomeScreen.dart';

import '../Widgets/calendar/calendar_models.dart';
import '../Widgets/calendar/calendar_view.dart';
import '../Widgets/calendar/booking_confirmation_dialog.dart';
import '../Models/available_room.dart';

// ============================================================================
// BOOKING AVAILABILITY PAGE
// ============================================================================

class BookingAvailabilityPage extends StatefulWidget {
  final DateTime date;
  final String startTime;
  final String endTime;
  final int capacity;
  final List<String> equipment;
  final bool isFromQuickCalendar;
  final int? buildingId;
  final String? buildingName;

  const BookingAvailabilityPage({
    super.key,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.equipment,
    this.isFromQuickCalendar = false,
    this.buildingId,
    this.buildingName,
  });

  @override
  State<BookingAvailabilityPage> createState() =>
      _BookingAvailabilityPageState();
}

class _BookingAvailabilityPageState extends State<BookingAvailabilityPage> {
  final RoomService _roomService = RoomService();

  // Use models from calendar_models.dart
  List<RoomGridItem> _rooms = [];
  List<CalendarBooking> _bookings = [];

  List<RoomGridItem> _visibleRooms = [];
  int _visibleRoomStart = 0;
  bool _isLoading = true;
  String? _loadError;
  int _activeRequests = 0;

  late DateTime _selectedDate;
  late DateTime _calendarStartTime;
  late DateTime _calendarEndTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;

    final startParts = widget.startTime.split(':');
    _calendarStartTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );

    final endParts = widget.endTime.split(':');
    _calendarEndTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final token = AuthService().token;
      if (token == null) throw Exception('Not authenticated');

      final availableRooms = await _roomService.getAvailableRoomsWithBookings(
        date: DateFormat('yyyy-MM-dd').format(widget.date),
        startTime: widget.startTime,
        endTime: widget.endTime,
        capacity: widget.capacity,
        buildingId: widget.buildingId,
        equipment: widget.equipment,
      );

      final roomColors = [
        const Color(0xFF42A5F5), // Blue
        const Color(0xFFEF5350), // Red
        const Color(0xFF66BB6A), // Green
        const Color(0xFFAB47BC), // Purple
        const Color(0xFFFFA726), // Orange
        const Color(0xFF26C6DA), // Cyan
      ];

      final mappedRooms = availableRooms.asMap().entries.map((entry) {
        final index = entry.key;
        final ar = entry.value;
        final color = roomColors[index % roomColors.length];

        return RoomGridItem(
          id: int.parse(ar.room.id),
          name: ar.room.name,
          capacity: ar.room.capacity,
          color: color,
          icon: Icons.meeting_room,
          avatar: ar.room.name.isNotEmpty ? ar.room.name[0].toUpperCase() : '?',
          building: ar.room.location,
          floor: 'Floor ${ar.room.floor}',
          equipment: ar.room.equipment.map((e) => e.type.displayName).toList(),
        );
      }).toList();

      final allBookings = <CalendarBooking>[];
      for (final ar in availableRooms) {
        for (final b in ar.bookings) {
          allBookings.add(
            CalendarBooking(
              roomId: int.parse(b.roomId),
              title: b.description,
              startTime: b.startTime,
              endTime: b.endTime,
            ),
          );
        }
      }

      setState(() {
        _rooms = mappedRooms;
        _bookings = allBookings;
        _visibleRoomStart = 0;
        _updateVisibleRooms();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  void _updateVisibleRooms() {
    final count = _getColumnsCount();
    final end = (_visibleRoomStart + count).clamp(0, _rooms.length);
    _visibleRooms = _rooms.sublist(_visibleRoomStart, end);
  }

  int _getColumnsCount() {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  void _nextRooms() {
    if (_visibleRoomStart + _getColumnsCount() < _rooms.length) {
      setState(() {
        _visibleRoomStart += 1;
        _updateVisibleRooms();
      });
    }
  }

  void _previousRooms() {
    if (_visibleRoomStart > 0) {
      setState(() {
        _visibleRoomStart -= 1;
        _updateVisibleRooms();
      });
    }
  }

  void _showBookingConfirmation(
    RoomGridItem room,
    DateTime start,
    DateTime end,
  ) {
    showDialog(
      context: context,
      builder: (context) => BookingConfirmationDialog(
        room: room,
        selectedDate: _selectedDate,
        startTime: start,
        endTime: end,
        onConfirm: (title) async {
          final success = await AuthService().createBooking({
            'roomId': room.id,
            'description': title,
            'startTime': start.toIso8601String(),
            'endTime': end.toIso8601String(),
          });

          if (success) {
            if (context.mounted) {
              Navigator.pop(context); // Close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking created successfully!')),
              );
              _loadAvailability(); // Reload data
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to create booking.')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Rooms'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.isFromQuickCalendar) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ), // Navigate back to Home
              );
            }
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateVisibleRooms();
          });

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_loadError != null) {
            return Center(child: Text('Error: $_loadError'));
          }

          if (_rooms.isEmpty) {
            return const Center(child: Text('No rooms found.'));
          }

          return Column(
            children: [
              // Pagination / Navigation controls if needed
              if (_rooms.length > _getColumnsCount())
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _previousRooms,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        'Showing ${_visibleRoomStart + 1}-${(_visibleRoomStart + _visibleRooms.length).clamp(0, _rooms.length)} of ${_rooms.length}',
                      ),
                      IconButton(
                        onPressed: _nextRooms,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: CalendarView(
                  selectedDate: _selectedDate,
                  visibleRooms: _visibleRooms,
                  bookings: _bookings,
                  initialStartTime: _calendarStartTime,
                  initialEndTime: _calendarEndTime,
                  onBookingSelected: _showBookingConfirmation,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
