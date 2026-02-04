import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/Enums/equipment_type.dart';
import '../Services/auth_service.dart';
import '../Services/room_service.dart';
import 'package:mci_booking_app/Screens/HomeScreen.dart';

import '../Widgets/calendar/calendar_models.dart';
import '../Widgets/calendar/calendar_view.dart';
import '../Widgets/calendar/booking_confirmation_dialog.dart';
import '../Constants/layout_constants.dart';

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
  State<BookingAvailabilityPage> createState() => _BookingAvailabilityPageState();
}

class _BookingAvailabilityPageState extends State<BookingAvailabilityPage> {
  final RoomService _roomService = RoomService();

  // Use models from calendar_models.dart
  List<RoomGridItem> _rooms = [];
  List<CalendarBooking> _bookings = [];

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

    if (widget.startTime.isNotEmpty && widget.endTime.isNotEmpty) {
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
    } else {
      // Default view time if no specific time selected (e.g. 08:00 - 09:00 for scrolling target)
      _calendarStartTime = DateTime(widget.date.year, widget.date.month, widget.date.day, 8, 0);
      _calendarEndTime = DateTime(widget.date.year, widget.date.month, widget.date.day, 9, 0);
    }

    // Smart adjustment: If today and start time is in the past, set to now rounded up
    final now = DateTime.now();
    final isToday = widget.date.year == now.year && widget.date.month == now.month && widget.date.day == now.day;

    if (isToday && _calendarStartTime.isBefore(now)) {
      int minute = ((now.minute + 14) ~/ 15) * 15;
      int hour = now.hour + (minute >= 60 ? 1 : 0);
      minute = minute % 60;
      if (hour >= 24) hour = 23;

      _calendarStartTime = DateTime(widget.date.year, widget.date.month, widget.date.day, hour, minute);

      // Keep original duration if possible, otherwise default to 1h
      final originalDuration = _calendarEndTime.difference(_calendarStartTime);
      final durationToUse = originalDuration.inMinutes > 0 ? originalDuration : const Duration(hours: 1);

      _calendarEndTime = _calendarStartTime.add(durationToUse);

      // Clamp end of day
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

      if (!mounted) return;

      final primaryColor = Theme.of(context).colorScheme.primary;

      // Remove the rainbow colors list and use mciBlue for all
      final mappedRooms = availableRooms.asMap().entries.map((entry) {
        final ar = entry.value;
        final color = primaryColor;

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

      final currentUserId = AuthService().currentUser?.id;
      final allBookings = <CalendarBooking>[];
      for (final ar in availableRooms) {
        for (final b in ar.bookings) {
          final isMyBooking = b.userId == currentUserId.toString();
          allBookings.add(
            CalendarBooking(
              roomId: int.parse(b.roomId),
              title: b.description,
              startTime: b.startTime,
              endTime: b.endTime,
              isMyBooking: isMyBooking,
            ),
          );
        }
      }

      setState(() {
        // Only show rooms available at wanted time
        final wantedStart = _calendarStartTime;
        final wantedEnd = _calendarEndTime;
        final availableRoomIds = <int>{};
        for (final room in mappedRooms) {
          final roomBookings = allBookings.where((b) => b.roomId == room.id);
          final hasOverlap = roomBookings.any((b) => b.endTime.isAfter(wantedStart) && b.startTime.isBefore(wantedEnd));
          if (!hasOverlap) {
            availableRoomIds.add(room.id);
          }
        }
        _rooms = mappedRooms.where((room) => availableRoomIds.contains(room.id)).toList();
        _bookings = allBookings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showBookingConfirmation(RoomGridItem room, DateTime start, DateTime end) {
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Booking created successfully!')));

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen(initialIndex: 1)),
                (route) => false,
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create booking.')));
            }
          }
        },
      ),
    );
  }

  bool _canGoPreviousDay() {
    final today = DateTime.now();
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).size.width < LayoutConstants.kMobileBreakpoint
          ? AppBar(
              title: const Text('Available Rooms'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (widget.isFromQuickCalendar) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
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
              // Compact Header with Date Navigation, Info Badge, and Pagination
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Desktop Back Button
                        if (constraints.maxWidth >= LayoutConstants.kMobileBreakpoint)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () => Navigator.of(context).pop(),
                                  tooltip: "Back",
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Back to Home",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),

                        // Row 1: Date Navigation and Pagination
                        Row(
                          children: [
                            // Date Navigation
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: _canGoPreviousDay() ? _goToPreviousDay : null,
                                      icon: const Icon(Icons.arrow_back_ios, size: 18),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                    InkWell(
                                      onTap: _selectDate,
                                      borderRadius: BorderRadius.circular(6),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                        child: Text(
                                          DateFormat('EEE, d. MMM yyyy').format(_selectedDate),
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _goToNextDay,
                                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                  ],
                                ),
                              ),
                            ),


                          ],
                        ),

                        // Row 2: Compact Info Badge (if needed)
                        if (!widget.isFromQuickCalendar &&
                            (widget.startTime.isNotEmpty || widget.capacity > 1 || widget.equipment.isNotEmpty)) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 14),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 2,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      if (widget.startTime.isNotEmpty)
                                        Text(
                                          '${widget.startTime}–${widget.endTime}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      if (widget.capacity > 1)
                                        Text(
                                          '${widget.capacity} people',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      if (widget.equipment.isNotEmpty)
                                        Builder(
                                          builder: (context) {
                                            final displayNames = _getEquipmentDisplayNames(widget.equipment);
                                            return Text(
                                              displayNames.join(", "),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Calendar takes remaining space
              Expanded(
                child: CalendarView(
                  selectedDate: _selectedDate,
                  visibleRooms: _rooms,
                  bookings: _bookings,
                  initialStartTime: _calendarStartTime,
                  initialEndTime: _calendarEndTime,
                  showInitialSuggestion: widget.startTime.isNotEmpty,
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
