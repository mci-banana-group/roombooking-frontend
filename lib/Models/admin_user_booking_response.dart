import 'Enums/booking_status.dart';

class AdminUserBookingResponse {
  final int id;
  final int? roomId;
  final String? roomName;
  final int? userId;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;

  AdminUserBookingResponse({
    required this.id,
    this.roomId,
    this.roomName,
    this.userId,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory AdminUserBookingResponse.fromJson(Map<String, dynamic> json) {
    return AdminUserBookingResponse(
      id: json['id'] as int,
      roomId: json['roomId'] as int?,
      roomName: json['roomName'] as String?,
      userId: json['userId'] as int?,
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      endTime: DateTime.parse(json['endTime'] as String).toLocal(),
      status: BookingStatus.fromString(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'roomName': roomName,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.toApiString(),
    };
  }
}
