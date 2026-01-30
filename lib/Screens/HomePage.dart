import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Widgets/home/BookingDetailsCard.dart';
import '../Widgets/home/QuickCalendarCard.dart';
import '../Widgets/home/FindRoomButton.dart';

import '../Services/auth_service.dart';
import '../Services/booking_service.dart';
import '../Services/room_service.dart';
import '../Models/booking.dart';
import '../Models/Enums/booking_status.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final BookingService _bookingService = BookingService();
  final RoomService _roomService = RoomService();

  final GlobalKey<BookingDetailsCardState> _cardKey = GlobalKey<BookingDetailsCardState>();
  Booking? _checkInBooking;
  String? _checkInRoomName;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  bool _canSearch = false;

  @override
  void initState() {
    super.initState();
    _loadActiveBooking();
  }

  Future<void> _loadActiveBooking() async {
    if (!mounted) return;
    
    // Only fetch if authenticated
    if (!_authService.isAuthenticated) return;

    try {
      final bookingsData = await _authService.getMyBookings();
      final bookings = bookingsData
          .map((json) => Booking.fromJson(json as Map<String, dynamic>))
          .toList();

      final now = DateTime.now();
      
      // Find a booking that is:
      // 1. Confirmed (RESERVED)
      // 2. Start time is within next 15 mins OR currently running
      // 3. Not yet ended
      
      Booking? targetBooking;
      
      for (final booking in bookings) {
        if (booking.status != BookingStatus.confirmed) continue;

        final fifteenMinutesBefore = booking.startTime.subtract(const Duration(minutes: 15));
        
        // Active if: now >= start-15min AND now < end
        if (now.isAfter(fifteenMinutesBefore) && now.isBefore(booking.endTime)) {
          targetBooking = booking;
          break; // Found one, stop searching
        }
      }

      if (targetBooking != null) {
        // Fetch room name
        final room = await _roomService.getRoomById(targetBooking.roomId);
        if (mounted) {
          setState(() {
            _checkInBooking = targetBooking;
            _checkInRoomName = room?.name ?? 'Room ${targetBooking?.roomId}';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _checkInBooking = null;
            _checkInRoomName = null;
          });
        }
      }
    } catch (e) {
      print('Error loading active booking: $e');
    }
  }

  Future<void> _showCheckInDialog() async {
    if (_checkInBooking == null) return;
    
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check in to booking'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Enter check-in code'),
          keyboardType: TextInputType.number,
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
      if (code.isEmpty) return;

      setState(() => _isLoading = true);

      try {
        final bookingIdInt = int.tryParse(_checkInBooking!.id) ?? 0;
        final success = await _bookingService.checkInBooking(
            bookingId: bookingIdInt, 
            code: code
        );

        if (success) {
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Checked in successfully!'), backgroundColor: Colors.green),
             );
           }
           // Reload to remove the card
           await _loadActiveBooking();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Check-in failed. Invalid code?'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              if (_checkInBooking != null) ...[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left accent strip
                                Container(
                                  width: 6,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.login_rounded,
                                                color: Theme.of(context).colorScheme.primary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Ready for Check-in',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _checkInRoomName ?? 'Loading room...',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${DateFormat('HH:mm').format(_checkInBooking!.startTime)} - ${DateFormat('HH:mm').format(_checkInBooking!.endTime)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _isLoading ? null : _showCheckInDialog,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).colorScheme.primary,
                                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: _isLoading 
                                              ? const SizedBox(
                                                  height: 20, 
                                                  width: 20, 
                                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                                )
                                              : const Text(
                                                  'Check In Now',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        bool isMobile = constraints.maxWidth < 768;
                        if (isMobile) {
                          return Column(
                            children: [
                              BookingDetailsCard(
                                key: _cardKey,
                                isMobile: true,
                                selectedDate: _selectedDate,
                                onBuildingChanged: (id, name) {
                                  setState(() {
                                    _canSearch = id != null;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),
                              QuickCalendarCard(
                                selectedDate: _selectedDate,
                                onDateSelected: (date) {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),
                              FindRoomButton(
                                onPressed: _canSearch
                                    ? () => _cardKey.currentState?.findRooms()
                                    : null,
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: BookingDetailsCard(
                                      key: _cardKey,
                                      isMobile: false,
                                      selectedDate: _selectedDate,
                                      onBuildingChanged: (id, name) {
                                        setState(() {
                                          _canSearch = id != null;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Flexible(
                                    flex: 1,
                                    child: QuickCalendarCard(
                                      selectedDate: _selectedDate,
                                      onDateSelected: (date) {
                                        setState(() {
                                          _selectedDate = date;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 400),
                                child: FindRoomButton(
                                  onPressed: _canSearch
                                      ? () => _cardKey.currentState?.findRooms()
                                      : null,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

            ],
          ),
        ),
      ],
    );
  }
}
