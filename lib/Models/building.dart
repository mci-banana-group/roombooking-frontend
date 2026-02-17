class Building {
  final int id;
  final String name;

  Building({
    required this.id,
    required this.name,
  });

  /// Factory constructor to create Building from JSON
  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  /// Convert Building to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() => 'Building(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Building && runtimeType == other.runtimeType && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
