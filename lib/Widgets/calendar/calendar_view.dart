import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'calendar_models.dart';

class CalendarView extends StatefulWidget {
  final DateTime selectedDate;
  final List<RoomGridItem> visibleRooms;
  final List<CalendarBooking> bookings;
  final DateTime initialStartTime;
  final DateTime initialEndTime;
  final bool showInitialSuggestion; // 👈 NEW
  final Function(RoomGridItem, DateTime, DateTime) onBookingSelected;

  const CalendarView({
    super.key,
    required this.selectedDate,
    required this.visibleRooms,
    required this.bookings,
    required this.initialStartTime,
    required this.initialEndTime,
    this.showInitialSuggestion = true, // Default true for backward compat
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

  Duration _preferredDuration = const Duration(hours: 1);

  DraftBooking? _draftBooking;
  late ScrollController _scrollController;

  bool _hasScrolledToInitial = false;
  final Map<int, GlobalKey> _roomColumnKeys = {};
  double _dragDyOffset = 0;

  @override
  void initState() {
    super.initState();

    final initialDiff = widget.initialEndTime.difference(
      widget.initialStartTime,
    );
    if (initialDiff > Duration.zero) {
      _preferredDuration = initialDiff;
    }

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
      final offset = (initialPixel - (hourHeight * 2)).clamp(
        0.0,
        double.infinity,
      );
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
    var hour = time.hour;
    if (hour < startHour && time.day != widget.selectedDate.day) {
      hour += 24;
    }
    final hourOffset = hour - startHour;
    final minuteOffset = time.minute / 60.0;
    return (hourOffset + minuteOffset) * hourHeight;
  }

  DateTime _getTimeFromPixel(double pixel) {
    final totalMinutes = (pixel / hourHeight * 60).round();
    final snappedMinutes = (totalMinutes / snapMinutes).round() * snapMinutes;

    // end of the day clamp to 23:59
    final maxMinutes = (endHour - startHour) * 60;
    if (snappedMinutes >= maxMinutes) {
      return DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        23,
        59,
      );
    }

    final hours = (startHour + snappedMinutes ~/ 60).clamp(
      startHour,
      endHour - 1,
    );
    final minutes = (snappedMinutes % 60).clamp(0, 59);

    return DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      hours,
      minutes,
    );
  }

  void _moveDraftBooking(Offset globalPosition) {
    if (_draftBooking == null) return;

    for (final room in widget.visibleRooms) {
      final key = _roomColumnKeys[room.id];
      if (key == null) continue;

      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;

      final localPosition = renderBox.globalToLocal(globalPosition);
      final size = renderBox.size;

      // Check if pointer is within this room's column width
      if (localPosition.dx >= 0 && localPosition.dx <= size.width) {
        // Calculate new start time based on pointer position - offset
        // We clamp the Y coordinate to be within valid hours, ensuring
        // the bottom of the booking doesn't go below the end hour (24:00).
        final duration = _draftBooking!.endTime.difference(
          _draftBooking!.startTime,
        );
        final bookingPixelHeight = hourHeight * (duration.inMinutes / 60);
        final maxTopPixel =
            (endHour - startHour) * hourHeight - bookingPixelHeight;

        final newTopPixel = (localPosition.dy - _dragDyOffset).clamp(
          0.0,
          maxTopPixel > 0 ? maxTopPixel : 0.0,
        );

        final newStartTime = _getTimeFromPixel(newTopPixel);
        final now = DateTime.now();
        final isToday = widget.selectedDate.year == now.year &&
            widget.selectedDate.month == now.month &&
            widget.selectedDate.day == now.day;
        // Prevent dragging the whole booking into the past
        if (isToday && newStartTime.isBefore(now)) {
          // Snap to now or block move
          return;
        }
        // duration is already calculated above
        final newEndTime = newStartTime.add(duration);

        // Calculate exact pixels for smoothness during drag
        final startPixel = newTopPixel;
        final endPixel = startPixel + (hourHeight * (duration.inMinutes / 60));

        setState(() {
          if (_draftBooking!.roomId != room.id) {
            _draftBooking = DraftBooking(
              roomId: room.id,
              roomInfo: room,
              startTime: newStartTime,
              endTime: newEndTime,
              startPixelOffset: startPixel,
              endPixelOffset: endPixel,
              isPreselected: _draftBooking!.isPreselected,
            );
          } else {
            _draftBooking!.startTime = newStartTime;
            _draftBooking!.endTime = newEndTime;
            _draftBooking!.startPixelOffset = startPixel;
            _draftBooking!.endPixelOffset = endPixel;
          }
        });
        return;
      }
    }
  }

  void _startDraftBooking(RoomGridItem room, Offset localPosition) {
    final startTime = _getTimeFromPixel(localPosition.dy);

    // Clamp end time to not exceed the calendar's end boundary
    DateTime endTime = startTime.add(_preferredDuration);
    final calendarEnd = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      endHour - 1,
      59,
    );
    if (endTime.isAfter(calendarEnd)) {
      endTime = calendarEnd;
    }

    setState(() {
      _draftBooking = DraftBooking(
        roomId: room.id,
        roomInfo: room,
        startTime: startTime,
        endTime: endTime,
        startPixelOffset: localPosition.dy,
        endPixelOffset:
            localPosition.dy +
            (hourHeight * (endTime.difference(startTime).inMinutes / 60)),
        isPreselected: false,
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
        // Prevent dragging start into the past (gray zone)
        final now = DateTime.now();
        final isToday = widget.selectedDate.year == now.year &&
            widget.selectedDate.month == now.month &&
            widget.selectedDate.day == now.day;
        DateTime newStart = _getTimeFromPixel(newPixelOffset);
        if (isToday && newStart.isBefore(now)) {
          // Snap to next 15-min slot >= now
          int minute = ((now.minute + 14) ~/ 15) * 15;
          int hour = now.hour + (minute >= 60 ? 1 : 0);
          minute = minute % 60;
          if (hour >= 24) hour = 23;
          newStart = DateTime(now.year, now.month, now.day, hour, minute);
          _draftBooking!.startPixelOffset = _getPixelForTime(newStart);
        } else {
          _draftBooking!.startPixelOffset = newPixelOffset;
        }
        _draftBooking!.startTime = newStart;
      } else {
        _draftBooking!.endPixelOffset = newPixelOffset;
        _draftBooking!.endTime = _getTimeFromPixel(newPixelOffset);
      }

      if (_draftBooking!.endTime.isBefore(_draftBooking!.startTime)) {
        _draftBooking!.endTime = _draftBooking!.startTime.add(
          const Duration(minutes: 30),
        );
        _draftBooking!.endPixelOffset =
            _draftBooking!.startPixelOffset + hourHeight / 2;
      }

      _preferredDuration = _draftBooking!.endTime.difference(
        _draftBooking!.startTime,
      );
    });
  }

  void _confirmDraftBooking() {
    if (_draftBooking != null && !_draftBooking!.isPreselected) {
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

  List<CalendarBooking> _getBookingsForRoom(int roomId) {
    return widget.bookings.where((b) {
      return b.roomId == roomId &&
          b.startTime.year == widget.selectedDate.year &&
          b.startTime.month == widget.selectedDate.month &&
          b.startTime.day == widget.selectedDate.day;
    }).toList();
  }

  List<CalendarBooking> _getOverlappingBookings(
    int roomId,
    DateTime start,
    DateTime end,
  ) {
    return widget.bookings.where((booking) {
      if (booking.roomId != roomId) return false;
      return booking.endTime.isAfter(start) && booking.startTime.isBefore(end);
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
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate room column width for overlay positioning
                              final roomWidth =
                                  constraints.maxWidth /
                                  widget.visibleRooms.length;

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Row(
                                    children: widget.visibleRooms
                                        .map((room) => _buildRoomColumn(room))
                                        .toList(),
                                  ),

                                  // OVERLAY DRAGGABLE DRAFT
                                  if (_draftBooking != null &&
                                      !_draftBooking!.isPreselected)
                                    _buildOverlayDraft(roomWidth),
                                ],
                              );
                            },
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
                Builder(
                  builder: (context) {
                    final overlappingBookings = _getOverlappingBookings(
                      _draftBooking!.roomId,
                      _draftBooking!.startTime,
                      _draftBooking!.endTime,
                    );
                    final hasOverlap = overlappingBookings.isNotEmpty;
                    return FloatingActionButton.extended(
                      onPressed: hasOverlap ? null : _confirmDraftBooking,
                      label: const Text('Book'),
                      icon: const Icon(Icons.check),
                      backgroundColor: hasOverlap
                          ? Colors.grey.withOpacity(0.3)
                          : _draftBooking!.roomInfo.color,
                      foregroundColor: hasOverlap
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white,
                      elevation: hasOverlap ? 0 : null,
                      disabledElevation: 0,
                    );
                  },
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
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
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
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
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRoomColumn(RoomGridItem room) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final roomBox = context.findRenderObject() as RenderBox?;
          final bookingsForRoom = _getBookingsForRoom(room.id);

          // preselection pixels
          final suggestionStart = _getPixelForTime(widget.initialStartTime);
          final suggestionEnd = _getPixelForTime(widget.initialEndTime);
          // suggestion if room doesn't have the active draft and no overlap
          final suggestionOverlaps = _getOverlappingBookings(
            room.id,
            widget.initialStartTime,
            widget.initialEndTime,
          );
          final showSuggestion = widget.showInitialSuggestion && // 👈 Check flag
              _draftBooking?.roomId != room.id && suggestionOverlaps.isEmpty;

          if (!_roomColumnKeys.containsKey(room.id)) {
            _roomColumnKeys[room.id] = GlobalKey();
          }

          // Determine if this is today
          final now = DateTime.now();
          final isToday = widget.selectedDate.year == now.year &&
              widget.selectedDate.month == now.month &&
              widget.selectedDate.day == now.day;

          return GestureDetector(
            onTapDown: (details) {
              // Only allow booking if not in the past
              if (isToday) {
                final tapTime = _getTimeFromPixel(details.localPosition.dy);
                if (tapTime.isBefore(now)) return;
              }
              _startDraftBooking(room, details.localPosition);
            },
            child: Container(
              key: _roomColumnKeys[room.id],
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // Render 15-min slots, graying out past intervals
                  Column(
                    children: List.generate(
                      endHour - startHour,
                      (index) {
                        final hour = startHour + index;
                        // Remove grayed out color for past slots
                        return Container(
                          height: hourHeight,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.1),
                              ),
                            ),
                            color: room.color.withOpacity(0.02),
                          ),
                        );
                      },
                    ),
                  ),
                  if (isToday)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: _getPixelForTime(now).clamp(
                        0.0,
                        (endHour - startHour) * hourHeight,
                      ),
                      child: Container(
                        color: Colors.grey.withOpacity(0.1),
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
                          if (isToday && widget.initialStartTime.isBefore(now)) return;
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
                        child: _buildSuggestionBlock(
                          room,
                          suggestionEnd - suggestionStart,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingBlock(
    CalendarBooking booking,
    RoomGridItem room,
    double height,
  ) {
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

  Widget _buildOverlayDraft(double roomWidth) {
    // Find index of current draft room in visible rooms
    final roomIndex = widget.visibleRooms.indexWhere(
      (r) => r.id == _draftBooking!.roomId,
    );

    // If room is not visible (e.g. scrolled away horizontally), don't show or handle gracefully
    // For now we assume visible since we snap to visible rooms
    if (roomIndex == -1) return const SizedBox.shrink();

    final leftOffset = roomIndex * roomWidth;

    return Positioned(
      top: _draftBooking!.startPixelOffset,
      left: leftOffset,
      width: roomWidth,
      child: GestureDetector(
        onPanStart: (details) {
          _dragDyOffset = details.localPosition.dy;
        },
        onPanUpdate: (details) {
          // We need global position
          _moveDraftBooking(details.globalPosition);
        },
        child: _buildDraftBookingBlock(_draftBooking!.roomInfo),
      ),
    );
  }

  Widget _buildDraftBookingBlock(RoomGridItem room) {
    final height =
        (_draftBooking!.endPixelOffset - _draftBooking!.startPixelOffset).abs();
    final overlappingBookings = _getOverlappingBookings(
      _draftBooking!.roomId,
      _draftBooking!.startTime,
      _draftBooking!.endTime,
    );
    final hasOverlap = overlappingBookings.isNotEmpty;

    final borderColor = hasOverlap ? Colors.red : room.color;
    final bgColor = hasOverlap
        ? Colors.red.withOpacity(0.1)
        : room.color.withOpacity(0.5);

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
          _buildDragHandle(true),
          _buildDragHandle(false),
        ],
      )
    );
  }

  Widget _buildSuggestionBlock(RoomGridItem room, double height) {
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

  Widget _buildDragHandle(bool isTop) {
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: GestureDetector(
          onPanUpdate: (details) {
            final key = _roomColumnKeys[_draftBooking!.roomId];
            final renderBox =
                key?.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              _updateDraftBookingEdge(details.globalPosition, renderBox, isTop);
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
