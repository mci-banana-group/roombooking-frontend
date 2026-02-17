enum RoomStatus {
  free,
  reserved,
  occupied;

  @override
  String toString() => name;

  static RoomStatus fromString(String string) {
    if (string == null || string.isEmpty) {
      return RoomStatus.free;
    }
    return RoomStatus.values.byName(string.toLowerCase());
  }
}
