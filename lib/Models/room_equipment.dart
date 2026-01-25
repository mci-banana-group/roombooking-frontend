import 'Enums/equipment_type.dart';

class RoomEquipment {
  final String id;
  final EquipmentType type;
  final int quantity;
  final String? description;

  const RoomEquipment({required this.id, required this.type, required this.quantity, this.description});

  RoomEquipment copyWith({String? id, EquipmentType? type, int? quantity, String? description}) {
    return RoomEquipment(
      id: id ?? this.id,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type.toString(), 'quantity': quantity, 'description': description};
  }

  factory RoomEquipment.fromJson(Map<String, dynamic> json) {
    final dynamic rawType = json['type'] ?? json['name'];
    final dynamic rawQuantity = json['quantity'];

    return RoomEquipment(
      id: (json['id'] ?? '').toString(),
      type: EquipmentType.fromString(rawType?.toString()),
      quantity: (rawQuantity is num) ? rawQuantity.toInt() : int.tryParse(rawQuantity?.toString() ?? '') ?? 1,
      description: json['description'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomEquipment &&
        other.id == id &&
        other.type == type &&
        other.quantity == quantity &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(id, type, quantity, description);

  @override
  String toString() => 'RoomEquipment(id: $id, type: $type, quantity: $quantity, description: $description)';
}
