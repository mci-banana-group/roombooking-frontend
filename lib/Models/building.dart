class Building {
  final int id;
  final String name;
  final String address;

  const Building({required this.id, required this.name, required this.address});

  factory Building.fromJson(Map<String, dynamic> json) => Building(
    id: json['id'] as int,
    name: json['name'] as String,
    address: json['address'] as String,
  );
}
