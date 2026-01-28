import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/room.dart' as api;
import '../Models/Enums/equipment_type.dart';
import '../Services/auth_service.dart';
import '../Services/room_service.dart';
import 'package:mci_booking_app/Screens/HomeScreen.dart';

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

  Booking({required this.roomId, required this.title, required this.startTime, required this.endTime});
}

// ✅ FIX 1: Added isPreselected flag
class DraftBooking {
  final int roomId;
  final RoomInfo roomInfo;
  DateTime startTime;
  DateTime endTime;
  double startPixelOffset;
  double endPixelOffset;
  bool isPreselected;

  DraftBooking({
    required this.roomId,
    required this.roomInfo,
    required this.startTime,
    required this.endTime,
    required this.startPixelOffset,
    required this.endPixelOffset,
    this.isPreselected = false,
  });
}

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
  final AuthService _authService = AuthService();

  late DateTime _selectedDate;
  late DateTime _calendarStartTime;
  late DateTime _calendarEndTime;
  late List<RoomInfo> _rooms;
  late List<Booking> _bookings;
  int _visibleRoomStart = 0;

  bool _isLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initializeBookingData();
    _rooms = <RoomInfo>[];
    _bookings = <Booking>[];
    _loadAvailability();
  }

  void _initializeBookingData() {
    _selectedDate = widget.date;
    _calendarStartTime = _parseTimeString(widget.startTime, _selectedDate);
    _calendarEndTime = _parseTimeString(widget.endTime, _selectedDate);
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

  int _roomIdAsInt(String rawId) {
    final parsed = int.tryParse(rawId);
    if (parsed != null) return parsed;

    int hash = 0;
    for (final unit in rawId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  Color _colorForRoom(int id) {
    const palette = <Color>[
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF3B82F6),
      Color(0xFFEF4444),
    ];
    return palette[id.abs() % palette.length];
  }

  IconData _iconForRoom(api.Room room) {
    if (room.capacity >= 15) return Icons.school;
    if (room.capacity >= 10) return Icons.meeting_room;
    return Icons.person;
  }

  String _avatarForRoom(api.Room room) {
    final trimmed = room.name.trim();
    if (trimmed.isEmpty) return '🏢';
    return trimmed.characters.first.toUpperCase();
  }

  RoomInfo _roomInfoFromApiRoom(api.Room room) {
    final idInt = _roomIdAsInt(room.id);
    return RoomInfo(
      id: idInt,
      name: room.name,
      capacity: room.capacity,
      color: _colorForRoom(idInt),
      icon: _iconForRoom(room),
      avatar: _avatarForRoom(room),
      building: room.location.isNotEmpty ? room.location : 'Unknown',
      floor: room.floor == 0 ? '—' : '${room.floor}. Floor',
      equipment: room.equipment.map((e) => e.type.displayName).toList(),
    );
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final String filterStartTime;
      final String filterEndTime;

      if (widget.isFromQuickCalendar) {
        filterStartTime = '06:00';
        filterEndTime = '23:59';
      } else {
        filterStartTime = widget.startTime;
        filterEndTime = widget.endTime;
      }

      final List<String>? equipmentFilter = widget.equipment.isEmpty ? null : widget.equipment;

      final availableRooms = await _roomService.getAvailableRoomsWithBookings(
        date: dateStr,
        startTime: filterStartTime,
        endTime: filterEndTime,
        capacity: widget.capacity,
        equipment: equipmentFilter,
        buildingId: widget.buildingId,
      );

      final rooms = availableRooms.map((ar) => _roomInfoFromApiRoom(ar.room)).toList();

      final bookings = <Booking>[];
      for (final ar in availableRooms) {
        final roomIdInt = _roomIdAsInt(ar.room.id);
        for (final b in ar.bookings) {
          bookings.add(
            Booking(
              roomId: roomIdInt,
              title: b.status.toString().isNotEmpty ? b.status.toString() : 'Booked',
              startTime: b.startTime,
              endTime: b.endTime,
            ),
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _rooms = rooms;
        _bookings = bookings;
        _visibleRoomStart = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _rooms = <RoomInfo>[];
        _bookings = <Booking>[];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _toApiUtcIso(DateTime dt) {
    return dt.toUtc().toIso8601String();
  }

  int _getColumnsCount() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 3;
    if (width < 1024) return 4;
    return 5;
  }

  List<RoomInfo> get _visibleRooms {
    final columnsCount = _getColumnsCount();
    return _rooms.sublist(_visibleRoomStart, (_visibleRoomStart + columnsCount).clamp(0, _rooms.length));
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
        onConfirm: (title) async {
          final apiRoomId = room.id;

          final success = await _authService.createBooking({
            'start': _toApiUtcIso(startTime),
            'end': _toApiUtcIso(endTime),
            'description': title,
            'roomId': apiRoomId,
          });

          if (!context.mounted) return;

          if (success) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('✓ $title booked in ${room.name}'), duration: const Duration(seconds: 2)),
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(initialIndex: 1),
              ),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking failed. Please try again.'), duration: Duration(seconds: 2)),
            );
          }
        },
      ),
    );
  }

  // ✅ FIX 6: Equipment display with better matching
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
        title: const Text('Room Scheduler'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadAvailability,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.buildingName != null ? 'Available rooms in ${widget.buildingName}' : 'Select a date and browse available meeting rooms',
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
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
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
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        IconButton(onPressed: _goToNextDay, icon: const Icon(Icons.arrow_forward)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ✅ FIX 2: Filter info box with ConstrainedBox for consistent width
            if (!widget.isFromQuickCalendar && (widget.startTime.isNotEmpty || widget.capacity > 1 || widget.equipment.isNotEmpty))
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                if (widget.startTime.isNotEmpty)
                                  Text(
                                    'Requested: ${widget.startTime}–${widget.endTime}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                if (widget.capacity > 1)
                                  Text('For ${widget.capacity} attendees', style: Theme.of(context).textTheme.bodySmall),
                                if (widget.equipment.isNotEmpty) ...[
                                  Builder(
                                    builder: (context) {
                                      final displayNames = _getEquipmentDisplayNames(widget.equipment);
                                      print('DEBUG: Displaying equipment: $displayNames');
                                      return Text(
                                        'Equipment: ${displayNames.join(", ")}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      );
                                    },
                                  ),
                                ]
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
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (_isLoading)
                          const Expanded(child: Center(child: CircularProgressIndicator()))
                        else if (_loadError != null)
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 520),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.wifi_off, size: 32),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Could not load availability.',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _loadError!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _loadAvailability,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else if (_rooms.isEmpty)
                            const Expanded(
                              child: Center(
                                child: Text('No rooms available for the selected criteria. Try adjusting your filters.'),
                              ),
                            )
                          else ...[
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
                                  initialStartTime: _calendarStartTime,
                                  initialEndTime: _calendarEndTime,
                                  onBookingSelected: _showBookingConfirmation,
                                ),
                              ),
                            ],
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
  final DateTime initialStartTime;
  final DateTime initialEndTime;
  final Function(RoomInfo, DateTime, DateTime) onBookingSelected;

  const CalendarView({
    super.key,
    required this.selectedDate,
    required this.visibleRooms,
    required this.bookings,
    required this.initialStartTime,
    required this.initialEndTime,
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
  bool _hasScrolledToInitial = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasScrolledToInitial) {
        _scrollToInitialTime();
        _hasScrolledToInitial = true;
      }
    });
  }

  void _scrollToInitialTime() {
    try {
      final initialPixel = _getPixelForTime(widget.initialStartTime);
      final offset = (initialPixel - (hourHeight * 2)).clamp(0.0, double.infinity);
      _scrollController.jumpTo(offset);
    } catch (e) {
      print('DEBUG: Error scrolling to initial time: $e');
    }
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

    return DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, hours, minutes);
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
        isPreselected: false,
      );
    });
  }

  void _updateDraftBookingEdge(Offset globalPosition, RenderBox roomBox, bool isStart) {
    final local = roomBox.globalToLocal(globalPosition);
    final newPixelOffset = local.dy.clamp(0.0, (endHour - startHour) * hourHeight);

    setState(() {
      if (isStart) {
        _draftBooking!.startPixelOffset = newPixelOffset;
        _draftBooking!.startTime = _getTimeFromPixel(newPixelOffset);
      } else {
        _draftBooking!.endPixelOffset = newPixelOffset;
        _draftBooking!.endTime = _getTimeFromPixel(newPixelOffset);
      }

      if (_draftBooking!.endTime.isBefore(_draftBooking!.startTime)) {
        _draftBooking!.endTime = _draftBooking!.startTime.add(const Duration(minutes: 30));
        _draftBooking!.endPixelOffset = _draftBooking!.startPixelOffset + hourHeight / 2;
      }
    });
  }

  void _confirmDraftBooking() {
    if (_draftBooking != null && !_draftBooking!.isPreselected) {
      widget.onBookingSelected(_draftBooking!.roomInfo, _draftBooking!.startTime, _draftBooking!.endTime);
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

  List<Booking> _getOverlappingBookings(int roomId, DateTime start, DateTime end) {
    return widget.bookings.where((booking) {
      if (booking.roomId != roomId) return false;
      return !(booking.endTime.isBefore(start) || booking.startTime.isAfter(end));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
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
                          child: Row(children: widget.visibleRooms.map((room) => _buildRoomColumn(room)).toList()),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_draftBooking != null && !_draftBooking!.isPreselected)
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
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: room.color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    room.building,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 8, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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
        children: List.generate(endHour - startHour, (index) {
          final hour = startHour + index;
          return SizedBox(
            height: hourHeight,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRoomColumn(RoomInfo room) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final roomBox = context.findRenderObject() as RenderBox?;
          final bookingsForRoom = _getBookingsForRoom(room.id);

          // preselection pixels
          final suggestionStart = _getPixelForTime(widget.initialStartTime);
          final suggestionEnd = _getPixelForTime(widget.initialEndTime);
          // suggestion if room doesn't have the active draft and no overlap
          final suggestionOverlaps = _getOverlappingBookings(room.id, widget.initialStartTime, widget.initialEndTime);
          final showSuggestion = _draftBooking?.roomId != room.id && suggestionOverlaps.isEmpty;

          return GestureDetector(
            onTapDown: (details) => _startDraftBooking(room, details.localPosition),
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2))),
              ),
              child: Stack(
                children: [
                   Column(
                    children: List.generate(
                      endHour - startHour,
                          (index) => Container(
                        height: hourHeight,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
                          ),
                          color: room.color.withOpacity(0.02),
                        ),
                      ),
                    ),
                  ),
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
                  // SUGGESTION BLOCK
                  if (showSuggestion)
                    Positioned(
                      top: suggestionStart,
                      left: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          // Click on suggestion -> Make it active for this room
                          setState(() {
                            _draftBooking = DraftBooking(
                              roomId: room.id,
                              roomInfo: room,
                              startTime: widget.initialStartTime,
                              endTime: widget.initialEndTime,
                              startPixelOffset: suggestionStart,
                              endPixelOffset: suggestionEnd,
                              isPreselected: false, // Active!
                            );
                          });
                        },
                        child: _buildSuggestionBlock(room, suggestionEnd - suggestionStart),
                      ),
                    ),

                  // ACTIVE DRAFT
                  if (_draftBooking != null && _draftBooking!.roomId == room.id)
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
      decoration: BoxDecoration(color: room.color.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
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
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftBookingBlock(RoomInfo room, RenderBox? renderBox) {
    final height = (_draftBooking!.endPixelOffset - _draftBooking!.startPixelOffset).abs();
    final overlappingBookings = _getOverlappingBookings(
      _draftBooking!.roomId,
      _draftBooking!.startTime,
      _draftBooking!.endTime,
    );
    final hasOverlap = overlappingBookings.isNotEmpty;

    final borderColor = hasOverlap ? Colors.red : room.color;
    final bgColor = hasOverlap ? Colors.red.withOpacity(0.1) : room.color.withOpacity(0.5);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: borderColor,
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
                if (hasOverlap)
                  Text(
                    'Overlaps booking!',
                    style: TextStyle(
                      fontSize: 8,
                      fontStyle: FontStyle.italic,
                      color: Colors.red.shade700,
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

  Widget _buildSuggestionBlock(RoomInfo room, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: room.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: room.color.withOpacity(0.5),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Icon(Icons.add, color: room.color.withOpacity(0.5), size: 16),
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
              _updateDraftBookingEdge(details.globalPosition, renderBox, isTop);
            }
          },
          child: Container(
            height: 12,
            decoration: BoxDecoration(color: _draftBooking!.roomInfo.color, borderRadius: BorderRadius.circular(4)),
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
  final Future<void> Function(String) onConfirm;

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
  late FocusNode _focusNode;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'New Booking');
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && _titleController.text == 'New Booking') {
      _titleController.clear();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
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
                          const SizedBox(height: 8),
                          Text(
                            'Capacity: ${widget.room.capacity} persons',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.room.equipment.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available Equipment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.room.equipment
                              .map((e) => Chip(
                            label: Text(e, style: const TextStyle(fontSize: 11)),
                            backgroundColor: Colors.blue.withOpacity(0.2),
                          ))
                              .toList(),
                        ),
                      ],
                    ),
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
                      focusNode: _focusNode,
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
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                        if (_titleController.text.isEmpty) return;
                        setState(() => _isSubmitting = true);
                        try {
                          await widget.onConfirm(_titleController.text);
                        } finally {
                          if (mounted) setState(() => _isSubmitting = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: widget.room.color),
                      child: _isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Confirm Booking'),
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
