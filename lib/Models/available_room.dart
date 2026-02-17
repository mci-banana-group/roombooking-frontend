import 'booking.dart';
import 'room.dart';

class AvailableRoom {
  final Room room;
  final List<Booking> bookings;

  const AvailableRoom({required this.room, required this.bookings});

  factory AvailableRoom.fromJson(Map<String, dynamic> json) {
    final roomJson = (json['room'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final bookingsJson = (json['bookings'] as List?)?.cast<dynamic>() ?? const <dynamic>[];

    return AvailableRoom(
      room: Room.fromJson(roomJson),
      bookings: bookingsJson.whereType<Map>().map((b) => Booking.fromJson(b.cast<String, dynamic>())).toList(),
    );
  }
}
