import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

class BookingAvailabilityPage extends StatefulWidget {
  final DateTime date;
  final bool isFromQuickCalendar;

  const BookingAvailabilityPage({
    super.key,
    required this.date,
    this.isFromQuickCalendar = false,
  });

  @override
  State<BookingAvailabilityPage> createState() =>
      _BookingAvailabilityPageState();
}

class _BookingAvailabilityPageState extends State<BookingAvailabilityPage> {
  late EventsController _controller;
  late DateTime _selectedDate;
  int _visibleRoomStart = 0;
  late PageController _dayPageController;

  // Meeting rooms
  final List<RoomInfo> _rooms = [
    RoomInfo(
      id: 1,
      name: 'Conference Room A',
      capacity: 10,
      color: const Color(0xFF6366F1),
      icon: Icons.meeting_room,
      avatar: '👩‍💼',
    ),
    RoomInfo(
      id: 2,
      name: 'Board Room',
      capacity: 8,
      color: const Color(0xFF8B5CF6),
      icon: Icons.person,
      avatar: '🧑‍💼',
    ),
    RoomInfo(
      id: 3,
      name: 'Innovation Hub',
      capacity: 15,
      color: const Color(0xFFEC4899),
      icon: Icons.lightbulb,
      avatar: '👨‍💻',
    ),
    RoomInfo(
      id: 4,
      name: 'Quiet Zone',
      capacity: 4,
      color: const Color(0xFF06B6D4),
      icon: Icons.business,
      avatar: '🤫',
    ),
    RoomInfo(
      id: 5,
      name: 'Training Center',
      capacity: 20,
      color: const Color(0xFF10B981),
      icon: Icons.school,
      avatar: '📚',
    ),
    RoomInfo(
      id: 6,
      name: 'Executive Suite',
      capacity: 6,
      color: const Color(0xFFF59E0B),
      icon: Icons.business,
      avatar: '👔',
    ),
    RoomInfo(
      id: 7,
      name: 'Tech Lab',
      capacity: 12,
      color: const Color(0xFF3B82F6),
      icon: Icons.business,
      avatar: '💻',
    ),
    RoomInfo(
      id: 8,
      name: 'Creative Space',
      capacity: 18,
      color: const Color(0xFFEF4444),
      icon: Icons.palette,
      avatar: '🎨',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
    _controller = EventsController();
    _dayPageController = PageController(
      initialPage: 50,
      viewportFraction: 0.15,
    );
    _initializeEvents();
  }

  void _initializeEvents() {
    final events = <Event>[];
    final baseDate = _selectedDate;

    final sampleBookings = [
      // Conference Room A (id: 1)
      {'start': 9, 'end': 10, 'title': 'Morning Standup', 'description': 'Daily sync', 'room': 1},
      {'start': 14, 'end': 16, 'title': 'UX research', 'description': 'Today is...', 'room': 1},

      // Board Room (id: 2)
      {'start': 10, 'end': 12, 'title': 'Board Meeting', 'description': 'Quarterly review', 'room': 2},
      {'start': 14, 'end': 16, 'title': 'Sprint planning', 'description': 'Today is the sprint...', 'room': 2},
      {'start': 16, 'end': 18, 'title': 'Review Session', 'description': 'Code review', 'room': 2},

      // Innovation Hub (id: 3)
      {'start': 13, 'end': 14, 'title': 'Brainstorm', 'description': 'New ideas', 'room': 3},
      {'start': 15, 'end': 17, 'title': 'Workshop', 'description': 'Design workshop', 'room': 3},

      // Quiet Zone (id: 4)
      {'start': 10, 'end': 11, 'title': 'Focus Time', 'description': 'Concentration', 'room': 4},
      {'start': 15, 'end': 16, 'title': '1:1 Meeting', 'description': 'Check-in', 'room': 4},

      // Training Center (id: 5)
      {'start': 9, 'end': 12, 'title': 'Training Session', 'description': 'Onboarding', 'room': 5},
      {'start': 14, 'end': 17, 'title': 'Workshop', 'description': 'Advanced topics', 'room': 5},

      // Executive Suite (id: 6)
      {'start': 11, 'end': 12, 'title': 'Executive Meeting', 'description': 'Leadership sync', 'room': 6},
      {'start': 15, 'end': 16, 'title': 'Strategy Session', 'description': 'Planning', 'room': 6},

      // Tech Lab (id: 7)
      {'start': 10, 'end': 11, 'title': 'Demo Session', 'description': 'Product demo', 'room': 7},
      {'start': 13, 'end': 15, 'title': 'Technical Review', 'description': 'Code review', 'room': 7},

      // Creative Space (id: 8)
      {'start': 11, 'end': 13, 'title': 'Design Workshop', 'description': 'UI/UX design', 'room': 8},
      {'start': 15, 'end': 17, 'title': 'Creative Session', 'description': 'Ideation', 'room': 8},
    ];

    for (final booking in sampleBookings) {
      final startHour = booking['start'] as int;
      final endHour = booking['end'] as int;
      final roomId = booking['room'] as int;
      final title = booking['title'] as String;
      final description = booking['description'] as String;

      events.add(
        Event(
          columnIndex: roomId - 1,
          title: title,
          description: description,
          startTime: baseDate.add(Duration(hours: startHour)),
          endTime: baseDate.add(Duration(hours: endHour)),
        ),
      );
    }

    _controller.updateCalendarData((calendarData) {
      calendarData.addEvents(events);
    });
  }

  void _previousRooms() {
    if (_visibleRoomStart > 0) {
      setState(() => _visibleRoomStart--);
    }
  }

  void _nextRooms() {
    if (_visibleRoomStart < _rooms.length - 3) {
      setState(() => _visibleRoomStart++);
    }
  }

  List<RoomInfo> get _visibleRooms {
    return _rooms.sublist(
      _visibleRoomStart,
      (_visibleRoomStart + 3).clamp(0, _rooms.length),
    );
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDate = day;
    });
    _initializeEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Availability'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Room Scheduler',
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
                    'Select a date and browse available meeting rooms',
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

          // Calendar Section with max width constraint
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Day Selector - 7 days with circular icons (smaller)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: SizedBox(
                          height: 80,
                          child: PageView.builder(
                            controller: _dayPageController,
                            onPageChanged: (index) {
                              final day = widget.date.add(Duration(days: index - 50));
                              _onDaySelected(day);
                            },
                            itemBuilder: (context, index) {
                              final day = widget.date.add(Duration(days: index - 50));
                              final isSelected = DateFormat('yyyy-MM-dd').format(day) ==
                                  DateFormat('yyyy-MM-dd').format(_selectedDate);

                              return GestureDetector(
                                onTap: () {
                                  _dayPageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Center(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.outline,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat('EEE').format(day).substring(0, 3),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          DateFormat('d').format(day),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Room Selector - With arrows and room names (bigger names)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        child: Row(
                          children: [
                            // Previous Arrow
                            SizedBox(
                              width: 40,
                              child: IconButton(
                                onPressed: _visibleRoomStart > 0 ? _previousRooms : null,
                                icon: const Icon(Icons.arrow_back),
                                tooltip: 'Previous rooms',
                              ),
                            ),
                            // Room Names
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: _visibleRooms
                                    .map((room) {
                                  return Flexible(
                                    child: Text(
                                      room.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: room.color,
                                      ),
                                    ),
                                  );
                                })
                                    .toList(),
                              ),
                            ),
                            // Next Arrow
                            SizedBox(
                              width: 40,
                              child: IconButton(
                                onPressed: _visibleRoomStart < _rooms.length - 3
                                    ? _nextRooms
                                    : null,
                                icon: const Icon(Icons.arrow_forward),
                                tooltip: 'Next rooms',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Calendar - Shows only 1 day (6 AM - 9 PM with smaller timeline)
          SliverFillRemaining(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: EventsPlanner(
                      controller: _controller,
                      daysShowed: 1,
                      initialDate: _selectedDate,
                      heightPerMinute: 0.6, // Smaller timeline
                      initialVerticalScrollOffset: 6 * 60 * 0.6, // Scroll to 6 AM
                      daysHeaderParam: DaysHeaderParam(
                        daysHeaderHeight: 0,
                      ),
                      columnsParam: ColumnsParam(
                        columns: _visibleRooms.length,
                        columnsLabels: _visibleRooms.map((r) => r.name).toList(),
                        columnsColors: _visibleRooms
                            .map((r) => r.color.withOpacity(0.05))
                            .toList(),
                        columnsForegroundColors:
                        _visibleRooms.map((r) => r.color).toList(),
                        columnsWidthRatio: List.filled(
                          _visibleRooms.length,
                          1 / _visibleRooms.length,
                        ),
                        columnHeaderBuilder: (day, isToday, columnIndex, columnWidth) {
                          final room = _visibleRooms[columnIndex];
                          return Container(
                            width: columnWidth,
                            color: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Room Name
                                Text(
                                  room.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: room.color,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Room Capacity
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: room.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: room.color.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    '${room.capacity} people',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: room.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      dayParam: DayParam(
                        onSlotTap: (columnIndex, exactDateTime, roundDateTime) {
                          final actualRoomIndex = _visibleRoomStart + columnIndex;
                          if (actualRoomIndex < _rooms.length) {
                            _showBookingDialog(
                              _rooms[actualRoomIndex],
                              roundDateTime,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(RoomInfo room, DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (context) => TimeSlotSelectionDialog(
        room: room,
        selectedDate: selectedDate,
        onSelectTimeframe: (startTime, endTime) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Booking: ${room.name}\n${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _dayPageController.dispose();
    super.dispose();
  }
}

// Room Information Model
class RoomInfo {
  final int id;
  final String name;
  final int capacity;
  final Color color;
  final IconData icon;
  final String avatar;

  RoomInfo({
    required this.id,
    required this.name,
    required this.capacity,
    required this.color,
    required this.icon,
    required this.avatar,
  });
}

// Time Slot Selection Dialog
class TimeSlotSelectionDialog extends StatefulWidget {
  final RoomInfo room;
  final DateTime selectedDate;
  final Function(DateTime, DateTime) onSelectTimeframe;

  const TimeSlotSelectionDialog({
    super.key,
    required this.room,
    required this.selectedDate,
    required this.onSelectTimeframe,
  });

  @override
  State<TimeSlotSelectionDialog> createState() =>
      _TimeSlotSelectionDialogState();
}

class _TimeSlotSelectionDialogState extends State<TimeSlotSelectionDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = const TimeOfDay(hour: 14, minute: 0);
    _endTime = const TimeOfDay(hour: 15, minute: 0);
  }

  Future<void> _selectStartTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (pickedTime != null) {
      setState(() => _startTime = pickedTime);
    }
  }

  Future<void> _selectEndTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (pickedTime != null) {
      setState(() => _endTime = pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final isValidTimeframe = endDateTime.isAfter(startDateTime);

    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: widget.room.color,
            radius: 20,
            child: Text(
              widget.room.avatar,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.room.name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Capacity: ${widget.room.capacity} people',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _selectStartTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(_startTime.format(context)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Time',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _selectEndTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(_endTime.format(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isValidTimeframe)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'End time must be after start time',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: isValidTimeframe
              ? () {
            widget.onSelectTimeframe(startDateTime, endDateTime);
            Navigator.pop(context);
          }
              : null,
          child: const Text('Book Room'),
        ),
      ],
    );
  }
}
