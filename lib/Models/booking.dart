import 'Enums/booking_status.dart';

class Booking {
  final String id;
  final String roomId;
  final String userId;
  final String description;
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
    required this.description,
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
    String? description,
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
      description: description ?? this.description,
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

  static DateTime _readDateTime(dynamic value, {DateTime? fallback}) {
    if (value is DateTime) return value.toLocal();
    final str = value?.toString();
    if (str == null || str.isEmpty)
      return (fallback ?? DateTime.fromMillisecondsSinceEpoch(0)).toLocal();
    final parsed = DateTime.tryParse(str);
    return parsed?.toLocal() ??
        (fallback ?? DateTime.fromMillisecondsSinceEpoch(0)).toLocal();
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic val) {
      if (val == null) return '';
      if (val is Map) return val['id']?.toString() ?? '';
      return val.toString();
    }

    return Booking(
      id: (json['id'] ?? '').toString(),
      roomId: (json['roomId']?.toString()) ?? extractId(json['room']),
      userId: (json['userId'] ?? json['user'] ?? '').toString(),
      description: json['description']?.toString() ?? '',
      startTime: _readDateTime(
        json['startTime'] ?? json['start'],
        fallback: DateTime.now(),
      ),
      endTime: _readDateTime(
        json['endTime'] ?? json['end'],
        fallback: DateTime.now(),
      ),
      status: BookingStatus.fromString((json['status'] ?? '').toString()),
      createdAt: _readDateTime(json['createdAt'], fallback: DateTime.now()),
      confirmedAt: json['confirmedAt'] != null
          ? _readDateTime(json['confirmedAt'])
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? _readDateTime(json['cancelledAt'])
          : null,
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
  int get hashCode => Object.hash(
    id,
    roomId,
    userId,
    startTime,
    endTime,
    status,
    createdAt,
    confirmedAt,
    cancelledAt,
  );

  @override
  String toString() =>
      'Booking(id: $id, roomId: $roomId, userId: $userId, startTime: $startTime, endTime: $endTime, status: $status, createdAt: $createdAt, confirmedAt: $confirmedAt, cancelledAt: $cancelledAt)';
}
