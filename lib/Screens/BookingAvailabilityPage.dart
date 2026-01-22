import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ============================================================================
// MODELS
// ============================================================================

class RoomInfo {
  final int id;
  final String name;
  final int capacity;
  final Color color;
  final IconData icon;
  final String avatar;
  final String building;
  final String floor;
  final List<String> equipment;

  RoomInfo({
    required this.id,
    required this.name,
    required this.capacity,
    required this.color,
    required this.icon,
    required this.avatar,
    required this.building,
    required this.floor,
    required this.equipment,
  });
}

class Booking {
  final int roomId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;

  Booking({
    required this.roomId,
    required this.title,
    required this.startTime,
    required this.endTime,
  });
}

class DraftBooking {
  final int roomId;
  final RoomInfo roomInfo;
  DateTime startTime;
  DateTime endTime;
  double startPixelOffset;
  double endPixelOffset;

  DraftBooking({
    required this.roomId,
    required this.roomInfo,
    required this.startTime,
    required this.endTime,
    required this.startPixelOffset,
    required this.endPixelOffset,
  });
}

// ============================================================================
// TEST DATA (mock) – later replace with API
// ============================================================================

class MockData {
  static List<RoomInfo> getMockRooms() {
    return [
      RoomInfo(
        id: 1,
        name: 'Conference Room A',
        capacity: 10,
        color: const Color(0xFF6366F1),
        icon: Icons.meeting_room,
        avatar: '👩‍💼',
        building: 'Building A',
        floor: '2nd Floor',
        equipment: ['Projector', 'Whiteboard', 'Video Conference'],
      ),
      RoomInfo(
        id: 2,
        name: 'Board Room',
        capacity: 8,
        color: const Color(0xFF8B5CF6),
        icon: Icons.person,
        avatar: '🧑‍💼',
        building: 'Building B',
        floor: '3rd Floor',
        equipment: ['60" Screen', 'Conference Phone', 'Lighting Control'],
      ),
      RoomInfo(
        id: 3,
        name: 'Innovation Hub',
        capacity: 15,
        color: const Color(0xFFEC4899),
        icon: Icons.lightbulb,
        avatar: '👨‍💻',
        building: 'Building A',
        floor: '1st Floor',
        equipment: ['Smart Board', 'Camera', 'Sound System'],
      ),
      RoomInfo(
        id: 4,
        name: 'Quiet Zone',
        capacity: 4,
        color: const Color(0xFF06B6D4),
        icon: Icons.business,
        avatar: '🤫',
        building: 'Building C',
        floor: '2nd Floor',
        equipment: ['Noise Cancellation', 'Monitor', 'Desk Phone'],
      ),
      RoomInfo(
        id: 5,
        name: 'Training Center',
        capacity: 20,
        color: const Color(0xFF10B981),
        icon: Icons.school,
        avatar: '📚',
        building: 'Building D',
        floor: '1st Floor',
        equipment: ['Projector', 'Seats for 20', 'Breakout Tables'],
      ),
      RoomInfo(
        id: 6,
        name: 'Executive Suite',
        capacity: 6,
        color: const Color(0xFFF59E0B),
        icon: Icons.business,
        avatar: '👔',
        building: 'Building B',
        floor: '4th Floor',
        equipment: ['Premium AV', 'Coffee Station', 'Private Entry'],
      ),
      RoomInfo(
        id: 7,
        name: 'Tech Lab',
        capacity: 12,
        color: const Color(0xFF3B82F6),
        icon: Icons.business,
        avatar: '💻',
        building: 'Building A',
        floor: '3rd Floor',
        equipment: ['PC Workstations', 'Network', 'Server Access'],
      ),
      RoomInfo(
        id: 8,
        name: 'Creative Space',
        capacity: 18,
        color: const Color(0xFFEF4444),
        icon: Icons.palette,
        avatar: '🎨',
        building: 'Building C',
        floor: '2nd Floor',
        equipment: ['Design Tablets', 'Large Displays', 'Color Calibrated Monitors'],
      ),
    ];
  }

  static List<Booking> getMockBookingsForDate(DateTime date) {
    return [
      Booking(roomId: 1, title: 'Morning Standup', startTime: date.add(const Duration(hours: 9)), endTime: date.add(const Duration(hours: 10))),
      Booking(roomId: 1, title: 'UX research', startTime: date.add(const Duration(hours: 14)), endTime: date.add(const Duration(hours: 16))),
      Booking(roomId: 2, title: 'Board Meeting', startTime: date.add(const Duration(hours: 10)), endTime: date.add(const Duration(hours: 12))),
      Booking(roomId: 2, title: 'Sprint planning', startTime: date.add(const Duration(hours: 14)), endTime: date.add(const Duration(hours: 16))),
      Booking(roomId: 2, title: 'Review Session', startTime: date.add(const Duration(hours: 16)), endTime: date.add(const Duration(hours: 18))),
      Booking(roomId: 3, title: 'Brainstorm', startTime: date.add(const Duration(hours: 13)), endTime: date.add(const Duration(hours: 14))),
      Booking(roomId: 3, title: 'Workshop', startTime: date.add(const Duration(hours: 15)), endTime: date.add(const Duration(hours: 17))),
      Booking(roomId: 4, title: 'Focus Time', startTime: date.add(const Duration(hours: 10)), endTime: date.add(const Duration(hours: 11))),
      Booking(roomId: 4, title: '1:1 Meeting', startTime: date.add(const Duration(hours: 15)), endTime: date.add(const Duration(hours: 16))),
      Booking(roomId: 5, title: 'Training Session', startTime: date.add(const Duration(hours: 9)), endTime: date.add(const Duration(hours: 12))),
      Booking(roomId: 5, title: 'Workshop', startTime: date.add(const Duration(hours: 14)), endTime: date.add(const Duration(hours: 17))),
      Booking(roomId: 6, title: 'Executive Meeting', startTime: date.add(const Duration(hours: 11)), endTime: date.add(const Duration(hours: 12))),
      Booking(roomId: 6, title: 'Strategy Session', startTime: date.add(const Duration(hours: 15)), endTime: date.add(const Duration(hours: 16))),
      Booking(roomId: 7, title: 'Demo Session', startTime: date.add(const Duration(hours: 10)), endTime: date.add(const Duration(hours: 11))),
      Booking(roomId: 7, title: 'Technical Review', startTime: date.add(const Duration(hours: 13)), endTime: date.add(const Duration(hours: 15))),
      Booking(roomId: 8, title: 'Design Workshop', startTime: date.add(const Duration(hours: 11)), endTime: date.add(const Duration(hours: 13))),
      Booking(roomId: 8, title: 'Creative Session', startTime: date.add(const Duration(hours: 15)), endTime: date.add(const Duration(hours: 17))),
    ];
  }
}

// ============================================================================
// BOOKING AVAILABILITY PAGE – SCREEN ONLY
// ============================================================================

class BookingAvailabilityPage extends StatefulWidget {
  final DateTime? date;
  final String? startTime;    // "HH:mm"
  final String? endTime;      // "HH:mm"
  final String? building;
  final int? attendees;
  final List<String>? equipment;
  final bool isFromQuickCalendar;

  const BookingAvailabilityPage({
    super.key,
    this.date,
    this.startTime,
    this.endTime,
    this.building,
    this.attendees,
    this.equipment,
    this.isFromQuickCalendar = false,
  });

  @override
  State<BookingAvailabilityPage> createState() => _BookingAvailabilityPageState();
}

class _BookingAvailabilityPageState extends State<BookingAvailabilityPage> {
  late DateTime _selectedDate;
  late DateTime _suggestedStartTime;
  late DateTime _suggestedEndTime;
  late List<RoomInfo> _rooms;
  late List<Booking> _bookings;
  int _visibleRoomStart = 0;

  @override
  void initState() {
    super.initState();
    _initializeBookingData();
    _rooms = MockData.getMockRooms();
    _bookings = MockData.getMockBookingsForDate(_selectedDate);
  }

  void _initializeBookingData() {
    _selectedDate = widget.date ?? DateTime.now();

    if (widget.startTime != null) {
      _suggestedStartTime = _parseTimeString(widget.startTime!, _selectedDate);
    } else {
      _suggestedStartTime = _selectedDate.add(const Duration(hours: 9));
    }

    if (widget.endTime != null) {
      _suggestedEndTime = _parseTimeString(widget.endTime!, _selectedDate);
    } else {
      _suggestedEndTime = _suggestedStartTime.add(const Duration(hours: 1));
    }
  }

  DateTime _parseTimeString(String timeString, DateTime dateBase) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts.length > 1 ? parts[1] : '0');
      return DateTime(dateBase.year, dateBase.month, dateBase.day, hour, minute);
    } catch (_) {
      return dateBase.add(const Duration(hours: 9));
    }
  }

  int _getColumnsCount() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 3;
    if (width < 1024) return 4;
    return 5;
  }

  List<RoomInfo> get _visibleRooms {
    final columnsCount = _getColumnsCount();
    return _rooms.sublist(
      _visibleRoomStart,
      (_visibleRoomStart + columnsCount).clamp(0, _rooms.length),
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
        _bookings = MockData.getMockBookingsForDate(_selectedDate);
      });
    }
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
      _bookings = MockData.getMockBookingsForDate(_selectedDate);
    });
  }

  void _previousRooms() {
    if (_visibleRoomStart > 0) {
      setState(() => _visibleRoomStart--);
    }
  }

  void _nextRooms() {
    final columnsCount = _getColumnsCount();
    if (_visibleRoomStart < _rooms.length - columnsCount) {
      setState(() => _visibleRoomStart++);
    }
  }

  void _showBookingConfirmation(RoomInfo room, DateTime startTime, DateTime endTime) {
    showDialog(
      context: context,
      builder: (context) => BookingConfirmationDialog(
        room: room,
        selectedDate: _selectedDate,
        startTime: startTime,
        endTime: endTime,
        onConfirm: (title) {
          setState(() {
            _bookings.add(
              Booking(
                roomId: room.id,
                title: title,
                startTime: startTime,
                endTime: endTime,
              ),
            );
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ $title booked in ${room.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Scheduler'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Room Scheduler',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a date and browse available meeting rooms',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _canGoPreviousDay() ? _goToPreviousDay : null,
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Text(
                          DateFormat('EEEE, d. MMMM yyyy').format(_selectedDate),
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

            if (widget.building != null ||
                widget.startTime != null ||
                widget.attendees != null)
              Padding(
                padding: const EdgeInsets.all(16),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.startTime != null)
                              Text(
                                'Requested: ${widget.startTime}–${widget.endTime}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (widget.building != null)
                              Text(
                                'Building: ${widget.building}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (widget.attendees != null)
                              Text(
                                'For ${widget.attendees} attendees',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (_rooms.length > _getColumnsCount())
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _visibleRoomStart > 0 ? _previousRooms : null,
                                  icon: const Icon(Icons.arrow_back),
                                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                  padding: EdgeInsets.zero,
                                ),
                                Expanded(
                                  child: Text(
                                    'Room ${_visibleRoomStart + 1} - ${(_visibleRoomStart + _getColumnsCount()).clamp(0, _rooms.length)} of ${_rooms.length}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _visibleRoomStart < _rooms.length - _getColumnsCount() ? _nextRooms : null,
                                  icon: const Icon(Icons.arrow_forward),
                                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: CalendarView(
                            selectedDate: _selectedDate,
                            visibleRooms: _visibleRooms,
                            bookings: _bookings,
                            onBookingSelected: _showBookingConfirmation,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CALENDAR VIEW
// ============================================================================

class CalendarView extends StatefulWidget {
  final DateTime selectedDate;
  final List<RoomInfo> visibleRooms;
  final List<Booking> bookings;
  final Function(RoomInfo, DateTime, DateTime) onBookingSelected;

  const CalendarView({
    super.key,
    required this.selectedDate,
    required this.visibleRooms,
    required this.bookings,
    required this.onBookingSelected,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  static const double hourHeight = 60.0;
  static const int startHour = 6;
  static const int endHour = 24;
  static const int snapMinutes = 15;

  DraftBooking? _draftBooking;
  late ScrollController _scrollController;
  late GlobalKey _calendarKey;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _calendarKey = GlobalKey();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _getPixelForTime(DateTime time) {
    final hourOffset = time.hour - startHour;
    final minuteOffset = time.minute / 60.0;
    return (hourOffset + minuteOffset) * hourHeight;
  }

  DateTime _getTimeFromPixel(double pixel) {
    final totalMinutes = (pixel / hourHeight * 60).round();
    final snappedMinutes = (totalMinutes / snapMinutes).round() * snapMinutes;
    final hours = (startHour + snappedMinutes ~/ 60).clamp(startHour, endHour - 1);
    final minutes = (snappedMinutes % 60).clamp(0, 59);

    return DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      hours,
      minutes,
    );
  }

  void _startDraftBooking(RoomInfo room, Offset localPosition) {
    final startTime = _getTimeFromPixel(localPosition.dy);
    final endTime = startTime.add(const Duration(hours: 1));

    setState(() {
      _draftBooking = DraftBooking(
        roomId: room.id,
        roomInfo: room,
        startTime: startTime,
        endTime: endTime,
        startPixelOffset: localPosition.dy,
        endPixelOffset: localPosition.dy + hourHeight,
      );
    });
  }

  void _updateDraftBookingEdge(
      Offset globalPosition,
      RenderBox roomBox,
      bool isStart,
      ) {
    final local = roomBox.globalToLocal(globalPosition);

    final newPixelOffset = local.dy.clamp(
      0.0,
      (endHour - startHour) * hourHeight,
    );

    setState(() {
      if (isStart) {
        _draftBooking!.startPixelOffset = newPixelOffset;
        _draftBooking!.startTime = _getTimeFromPixel(newPixelOffset);
      } else {
        _draftBooking!.endPixelOffset = newPixelOffset;
        _draftBooking!.endTime = _getTimeFromPixel(newPixelOffset);
      }

      if (_draftBooking!.endTime.isBefore(_draftBooking!.startTime)) {
        _draftBooking!.endTime =
            _draftBooking!.startTime.add(const Duration(minutes: 30));
        _draftBooking!.endPixelOffset =
            _draftBooking!.startPixelOffset + hourHeight / 2;
      }
    });
  }



  void _confirmDraftBooking() {
    if (_draftBooking != null) {
      widget.onBookingSelected(
        _draftBooking!.roomInfo,
        _draftBooking!.startTime,
        _draftBooking!.endTime,
      );
      setState(() => _draftBooking = null);
    }
  }

  void _cancelDraftBooking() {
    setState(() => _draftBooking = null);
  }

  List<Booking> _getBookingsForRoom(int roomId) {
    return widget.bookings.where((b) {
      return b.roomId == roomId &&
          b.startTime.year == widget.selectedDate.year &&
          b.startTime.month == widget.selectedDate.month &&
          b.startTime.day == widget.selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            key: _calendarKey,
            child: Column(
              children: [
                _buildRoomHeaders(),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTimeColumn(),
                        Expanded(
                          child: Row(
                            children: widget.visibleRooms
                                .map((room) => _buildRoomColumn(room))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_draftBooking != null)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: _cancelDraftBooking,
                  label: const Text('Cancel'),
                  icon: const Icon(Icons.close),
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  onPressed: _confirmDraftBooking,
                  label: const Text('Book'),
                  icon: const Icon(Icons.check),
                  backgroundColor: _draftBooking!.roomInfo.color,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRoomHeaders() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.only(left: 60, right: 8),
      child: Row(
        children: widget.visibleRooms
            .map(
              (room) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                children: [
                  Icon(room.icon, color: room.color, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    room.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: room.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    room.building,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildTimeColumn() {
    return SizedBox(
      width: 60,
      child: Column(
        children: List.generate(
          endHour - startHour,
              (index) {
            final hour = startHour + index;
            return SizedBox(
              height: hourHeight,
              child: Center(
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoomColumn(RoomInfo room) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final roomBox = context.findRenderObject() as RenderBox?;
          final bookingsForRoom = _getBookingsForRoom(room.id);

          return GestureDetector(
            onTapDown: (details) =>
                _startDraftBooking(room, details.localPosition),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withOpacity(0.2),
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // Hour grid
                  Column(
                    children: List.generate(
                      endHour - startHour,
                          (index) => Container(
                        height: hourHeight,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.1),
                            ),
                          ),
                          color: room.color.withOpacity(0.02),
                        ),
                      ),
                    ),
                  ),

                  // Existing bookings
                  ...bookingsForRoom.map((booking) {
                    final startPixel = _getPixelForTime(booking.startTime);
                    final endPixel = _getPixelForTime(booking.endTime);
                    final height = endPixel - startPixel;

                    return Positioned(
                      top: startPixel,
                      left: 2,
                      right: 2,
                      child: _buildBookingBlock(booking, room, height),
                    );
                  }),

                  // Draft booking
                  if (_draftBooking != null &&
                      _draftBooking!.roomId == room.id)
                    Positioned(
                      top: _draftBooking!.startPixelOffset,
                      left: 2,
                      right: 2,
                      child: _buildDraftBookingBlock(room, roomBox),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildBookingBlock(Booking booking, RoomInfo room, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: room.color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              booking.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftBookingBlock(RoomInfo room, RenderBox? renderBox) {
    final height = (_draftBooking!.endPixelOffset - _draftBooking!.startPixelOffset).abs();

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: room.color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: room.color,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${DateFormat('HH:mm').format(_draftBooking!.startTime)} - ${DateFormat('HH:mm').format(_draftBooking!.endTime)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Draft',
                  style: TextStyle(
                    fontSize: 8,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          _buildDragHandle(true, renderBox),
          _buildDragHandle(false, renderBox),
        ],
      ),
    );
  }

  Widget _buildDragHandle(bool isTop, RenderBox? renderBox) {
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: GestureDetector(
          onPanUpdate: (details) {
            if (renderBox != null) {
              _updateDraftBookingEdge(
                details.globalPosition,
                renderBox,
                isTop,
              );
            }
          },
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: _draftBooking!.roomInfo.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),

      ),
    );
  }
}

// ============================================================================
// BOOKING CONFIRMATION DIALOG
// ============================================================================

class BookingConfirmationDialog extends StatefulWidget {
  final RoomInfo room;
  final DateTime selectedDate;
  final DateTime startTime;
  final DateTime endTime;
  final Function(String) onConfirm;

  const BookingConfirmationDialog({
    super.key,
    required this.room,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.onConfirm,
  });

  @override
  State<BookingConfirmationDialog> createState() => _BookingConfirmationDialogState();
}

class _BookingConfirmationDialogState extends State<BookingConfirmationDialog> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'New Booking');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.endTime.difference(widget.startTime);
    final durationHours = duration.inHours;
    final durationMinutes = duration.inMinutes % 60;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: widget.room.color,
                      radius: 24,
                      child: Text(widget.room.avatar, style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.room.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.room.building} - ${widget.room.floor}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.room.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow('Date:', DateFormat('MMM d, yyyy').format(widget.startTime)),
                      const SizedBox(height: 8),
                      _detailRow('Start Time:', DateFormat('HH:mm').format(widget.startTime)),
                      const SizedBox(height: 8),
                      _detailRow('End Time:', DateFormat('HH:mm').format(widget.endTime)),
                      const SizedBox(height: 8),
                      _detailRow(
                        'Duration:',
                        durationHours > 0 ? '${durationHours}h ${durationMinutes}m' : '${durationMinutes}m',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Booking Title', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter booking title',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.isNotEmpty) {
                          widget.onConfirm(_titleController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: widget.room.color),
                      child: const Text('Confirm Booking'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
