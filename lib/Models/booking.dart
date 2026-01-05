import 'Enums/booking_status.dart';

class Booking {
  final String id;
  final String roomId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;

  const Booking({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.cancelledAt,
  });

  Booking copyWith({
    String? id,
    String? roomId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
  }) {
    return Booking(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      userId: json['userId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: BookingStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt'] as String) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt'] as String) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking &&
        other.id == id &&
        other.roomId == roomId &&
        other.userId == userId &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.confirmedAt == confirmedAt &&
        other.cancelledAt == cancelledAt;
  }

  @override
  int get hashCode => Object.hash(id, roomId, userId, startTime, endTime, status, createdAt, confirmedAt, cancelledAt);

  @override
  String toString() =>
      'Booking(id: $id, roomId: $roomId, userId: $userId, startTime: $startTime, endTime: $endTime, status: $status, createdAt: $createdAt, confirmedAt: $confirmedAt, cancelledAt: $cancelledAt)';
}
