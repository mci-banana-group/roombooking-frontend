enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  expired;

  @override
  String toString() => name;

  static BookingStatus fromString(String string) => BookingStatus.values.byName(string.toLowerCase());
}
