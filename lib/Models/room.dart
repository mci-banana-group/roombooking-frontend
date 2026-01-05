import 'Enums/room_status.dart';
import 'room_equipment.dart';

class Room {
  final String id;
  final String name;
  final String roomNumber;
  final int size;
  final int floor;
  final String location;
  final List<RoomEquipment> equipment;
  final RoomStatus currentStatus;
  final Duration estimatedWalkingTime;

  const Room({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.size,
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
    int? size,
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
      size: size ?? this.size,
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
      'size': size,
      'floor': floor,
      'location': location,
      'equipment': equipment.map((e) => e.toJson()).toList(),
      'currentStatus': currentStatus.toString(),
      'estimatedWalkingTime': estimatedWalkingTime.inMilliseconds,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      name: json['name'] as String,
      roomNumber: json['roomNumber'] as String,
      size: json['size'] as int,
      floor: json['floor'] as int,
      location: json['location'] as String,
      equipment: (json['equipment'] as List<dynamic>)
          .map((e) => RoomEquipment.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentStatus: RoomStatus.fromString(json['currentStatus'] as String),
      estimatedWalkingTime: Duration(milliseconds: json['estimatedWalkingTime'] as int),
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
        other.size == size &&
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
    size,
    floor,
    location,
    Object.hashAll(equipment),
    currentStatus,
    estimatedWalkingTime,
  );

  @override
  String toString() =>
      'Room(id: $id, name: $name, roomNumber: $roomNumber, size: $size, floor: $floor, location: $location, equipment: $equipment, currentStatus: $currentStatus, estimatedWalkingTime: $estimatedWalkingTime)';
}
