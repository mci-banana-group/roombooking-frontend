enum UserRole {
  student,
  lecturer,
  staff,
  admin;

  @override
  String toString() => name;

  static UserRole fromString(String input) => UserRole.values.byName(input.toLowerCase());
}
