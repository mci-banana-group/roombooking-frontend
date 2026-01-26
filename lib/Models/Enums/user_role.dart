enum UserRole {
  student,
  lecturer,
  staff,
  admin,
  user;

  @override
  String toString() => name;

  static UserRole fromString(String input) => UserRole.values.byName(input.toLowerCase());
}
