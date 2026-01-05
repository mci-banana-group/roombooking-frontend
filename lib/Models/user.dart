import 'Enums/user_role.dart';

class User {
  final String id;
  final String name;
  final UserRole role;

  const User({required this.id, required this.name, required this.role});

  User copyWith({String? id, String? name, UserRole? role}) {
    return User(id: id ?? this.id, name: name ?? this.name, role: role ?? this.role);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'role': role.toString()};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.name == name && other.role == role;
  }

  @override
  int get hashCode => Object.hash(id, name, role);

  @override
  String toString() => 'User(id: $id, name: $name, role: $role)';
}
