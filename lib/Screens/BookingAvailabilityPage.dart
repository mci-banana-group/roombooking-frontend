import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/Enums/equipment_type.dart';
import '../Services/auth_service.dart';
import '../Services/room_service.dart';
import 'package:mci_booking_app/Screens/HomeScreen.dart';

import '../Widgets/calendar/calendar_models.dart';
import '../Widgets/calendar/calendar_view.dart';
import '../Widgets/calendar/booking_confirmation_dialog.dart';

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

    final now = DateTime.now();
    final isToday = widget.date.year == now.year && widget.date.month == now.month && widget.date.day == now.day;
    final startParts = widget.startTime.split(':');
    final endParts = widget.endTime.split(':');
    _calendarStartTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );
    _calendarEndTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );
    // If today and start time is in the past, set to now rounded up
    if (isToday && _calendarStartTime.isBefore(now)) {
      int minute = ((now.minute + 14) ~/ 15) * 15;
      int hour = now.hour + (minute >= 60 ? 1 : 0);
      minute = minute % 60;
      if (hour >= 24) hour = 23;
      _calendarStartTime = DateTime(now.year, now.month, now.day, hour, minute);
      _calendarEndTime = _calendarStartTime.add(const Duration(hours: 1));
      if (_calendarEndTime.day != _calendarStartTime.day) {
        _calendarEndTime = DateTime(_calendarStartTime.year, _calendarStartTime.month, _calendarStartTime.day, 23, 59);
      }
    }
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
            'start': start.toUtc().toIso8601String(),
            'end': end.toUtc().toIso8601String(),
          });

          if (success) {
            if (context.mounted) {
              Navigator.pop(context); // Close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking created successfully!')),
              );

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(initialIndex: 1),
                ),
                (route) => false,
              );
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

  bool _canGoPreviousDay() {
    final today = DateTime.now();
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final todayOnly = DateTime(today.year, today.month, today.day);
    return selected.isAfter(todayOnly);
  }

  void _goToPreviousDay() {
    if (_canGoPreviousDay()) {
      setState(() {
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      });
      _loadAvailability();
    }
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _loadAvailability();
  }

  List<String> _getEquipmentDisplayNames(List<String> apiValues) {
    if (apiValues.isEmpty) {
      print('DEBUG: Equipment list is empty');
      return [];
    }

    print('DEBUG: Converting equipment: $apiValues');

    final result = apiValues.map((value) {
      // Try matching against EquipmentType enum
      for (final equipType in EquipmentType.values) {
        // Match by apiValue OR displayName (handles both cases)
        if (equipType.apiValue.toUpperCase() == value.toUpperCase() ||
            equipType.displayName.toLowerCase() == value.toLowerCase()) {
          print('DEBUG: Matched "$value" to "${equipType.displayName}"');
          return equipType.displayName;
        }
      }
      print('DEBUG: No match for "$value", using fallback');
      return value; // Fallback if not found
    }).toList();

    print('DEBUG: Final equipment display: $result');
    return result;
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
              const SizedBox(height: 16),
              // Date Navigation
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _canGoPreviousDay()
                                ? _goToPreviousDay
                                : null,
                            icon: const Icon(Icons.arrow_back),
                          ),
                          Text(
                            DateFormat(
                              'EEEE, d. MMMM yyyy',
                            ).format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: _goToNextDay,
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info Badge
              if (!widget.isFromQuickCalendar &&
                  (widget.startTime.isNotEmpty ||
                      widget.capacity > 1 ||
                      widget.equipment.isNotEmpty))
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  if (widget.startTime.isNotEmpty)
                                    Text(
                                      'Requested: ${widget.startTime}–${widget.endTime}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  if (widget.capacity > 1)
                                    Text(
                                      'For ${widget.capacity} attendees',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  if (widget.equipment.isNotEmpty) ...[
                                    Builder(
                                      builder: (context) {
                                        final displayNames =
                                            _getEquipmentDisplayNames(
                                              widget.equipment,
                                            );
                                        return Text(
                                          'Equipment: ${displayNames.join(", ")}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

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
