import 'Enums/room_status.dart';
import 'room_equipment.dart';

class Room {
  final String id;
  final String name;
  final String roomNumber;
  final int capacity;
  final int floor;
  final String location;
  final List<RoomEquipment> equipment;
  final RoomStatus currentStatus;
  final Duration estimatedWalkingTime;

  const Room({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.capacity,
    required this.floor,
    required this.location,
    required this.equipment,
    required this.currentStatus,
    required this.estimatedWalkingTime,
  });

  Room copyWith({
    String? id,
    String? name,
    String? roomNumber,
    int? capacity,
    int? floor,
    String? location,
    List<RoomEquipment>? equipment,
    RoomStatus? currentStatus,
    Duration? estimatedWalkingTime,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      roomNumber: roomNumber ?? this.roomNumber,
      capacity: capacity ?? this.capacity,
      floor: floor ?? this.floor,
      location: location ?? this.location,
      equipment: equipment ?? this.equipment,
      currentStatus: currentStatus ?? this.currentStatus,
      estimatedWalkingTime: estimatedWalkingTime ?? this.estimatedWalkingTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roomNumber': roomNumber,
      'capacity': capacity,
      'floor': floor,
      'location': location,
      'equipment': equipment.map((e) => e.toJson()).toList(),
      'currentStatus': currentStatus.toString(),
      'estimatedWalkingTime': estimatedWalkingTime.inMilliseconds,
    };
  }

  static int _readInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: (json['id'] ?? json['roomNumber'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      roomNumber: (json['roomNumber'] ?? '').toString(),
      capacity: _readInt(json['capacity'], fallback: 0),
      floor: _readInt(json['floor'], fallback: 0),
      location: json['location'] as String? ?? '',
      equipment:
          (json['equipment'] as List<dynamic>?)
              ?.map((e) => RoomEquipment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentStatus: RoomStatus.fromString((json['status'] as String?)?.toUpperCase() ?? 'FREE'),
      estimatedWalkingTime: Duration(milliseconds: _readInt(json['estimatedWalkingTime'], fallback: 0)),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Room) return false;
    if (equipment.length != other.equipment.length) return false;
    for (int i = 0; i < equipment.length; i++) {
      if (equipment[i] != other.equipment[i]) return false;
    }
    return other.id == id &&
        other.name == name &&
        other.roomNumber == roomNumber &&
        other.capacity == capacity &&
        other.floor == floor &&
        other.location == location &&
        other.currentStatus == currentStatus &&
        other.estimatedWalkingTime == estimatedWalkingTime;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    roomNumber,
    capacity,
    floor,
    location,
    Object.hashAll(equipment),
    currentStatus,
    estimatedWalkingTime,
  );

  @override
  String toString() =>
      'Room(id: $id, name: $name, roomNumber: $roomNumber, capacity: $capacity, floor: $floor, location: $location, equipment: $equipment, currentStatus: $currentStatus, estimatedWalkingTime: $estimatedWalkingTime)';
}
