import 'Enums/room_status.dart';
import 'room_equipment.dart';
import 'building.dart';

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
  final Building? building;
  final String description;
  final String confirmationCode;

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
    this.building,
    this.description = '',
    this.confirmationCode = '',
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
    Building? building,
    String? description,
    String? confirmationCode,
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
      building: building ?? this.building,
      description: description ?? this.description,
      confirmationCode: confirmationCode ?? this.confirmationCode,
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
      'building': building?.toJson(),
      'description': description,
      'confirmationCode': confirmationCode,
    };
  }

  static int _readInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    // 1. Unwrap "room" key if present (from dev branch logic)
    final Map<String, dynamic> data = (json['room'] != null && json['room'] is Map<String, dynamic>) 
        ? json['room'] 
        : json;

    // 2. Building parsing
    Building? parsedBuilding;
    String buildingName = '';
    
    // Check main JSON for building (sibling of room) or fallback to inner data
    if (json['building'] != null && json['building'] is Map<String, dynamic>) {
      parsedBuilding = Building.fromJson(json['building']);
      buildingName = parsedBuilding.name;
    } else if (data['building'] != null && data['building'] is Map<String, dynamic>) {
      parsedBuilding = Building.fromJson(data['building']);
      buildingName = parsedBuilding.name;
    }

    return Room(
      id: (data['id'] ?? data['roomNumber'] ?? '').toString(),
      name: data['name'] as String? ?? 'Unnamed',
      roomNumber: (data['roomNumber'] ?? '').toString(),
      capacity: _readInt(data['capacity']),
      floor: _readInt(data['floor']),
      // Use location from data, fallback to building name if available
      location: (data['location'] as String? ?? '').isNotEmpty 
          ? (data['location'] as String) 
          : buildingName,
      equipment: (data['equipment'] as List<dynamic>?)
              ?.map((e) => RoomEquipment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentStatus: _parseStatus(data['status'] as String?),
      estimatedWalkingTime: Duration(milliseconds: _readInt(data['estimatedWalkingTime'])),
      building: parsedBuilding,
      description: data['description']?.toString() ?? "",
      confirmationCode: data['confirmationCode']?.toString() ?? "",
    );
  }

  static RoomStatus _parseStatus(String? status) {
    if (status == null) return RoomStatus.free;
    switch (status.toUpperCase()) {
      case 'OCCUPIED': return RoomStatus.occupied;
      case 'AVAILABLE': 
      case 'FREE':
        return RoomStatus.free;
      default: return RoomStatus.free;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Room &&
      other.id == id &&
      other.name == name &&
      other.roomNumber == roomNumber &&
      other.capacity == capacity &&
      other.floor == floor &&
      other.location == location &&
      other.currentStatus == currentStatus &&
      other.estimatedWalkingTime == estimatedWalkingTime &&
      other.building == building &&
      other.description == description &&
      other.confirmationCode == confirmationCode;
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
    building,
    description,
    confirmationCode,
  );

  @override
  String toString() =>
      'Room(id: $id, name: $name, roomNumber: $roomNumber, capacity: $capacity, floor: $floor, location: $location, equipment: $equipment, currentStatus: $currentStatus, estimatedWalkingTime: $estimatedWalkingTime, building: $building, description: $description, confirmationCode: $confirmationCode)';
}
