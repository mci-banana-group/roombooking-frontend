class Equipment {
  final int id;
  final String name;
  final int quantity;
  final String description;

  const Equipment({
    required this.id,
    required this.name,
    required this.quantity,
    required this.description,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
    id: json['id'] as int,
    name: json['name'] as String,
    quantity: json['quantity'] as int,
    description: json['description'] as String,
  );
}
