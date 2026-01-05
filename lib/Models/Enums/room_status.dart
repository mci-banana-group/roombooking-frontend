enum RoomStatus {
  free,
  reserved,
  occupied;

  @override
  String toString() => name;

  static RoomStatus fromString(String string) => RoomStatus.values.byName(string.toLowerCase());
}
