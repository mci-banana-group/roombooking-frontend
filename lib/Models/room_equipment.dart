import 'Enums/equipment_type.dart';

class RoomEquipment {
  final String id;
  final EquipmentType type;
  final String? description;

  const RoomEquipment({required this.id, required this.type, this.description});

  RoomEquipment copyWith({String? id, EquipmentType? type, String? description}) {
    return RoomEquipment(id: id ?? this.id, type: type ?? this.type, description: description ?? this.description);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type.toString(), 'description': description};
  }

  factory RoomEquipment.fromJson(Map<String, dynamic> json) {
    return RoomEquipment(
      id: json['id'] as String,
      type: EquipmentType.fromString(json['type'] as String),
      description: json['description'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomEquipment && other.id == id && other.type == type && other.description == description;
  }

  @override
  int get hashCode => Object.hash(id, type, description);

  @override
  String toString() => 'RoomEquipment(id: $id, type: $type, description: $description)';
}
