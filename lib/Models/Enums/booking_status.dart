enum BookingStatus {
  /// Backend: `RESERVED`
  confirmed,

  cancelled,

  /// Backend: `CHECKED_IN`
  checkedIn,

  /// Backend: `NO_SHOW`
  expired;

  /// Backend representation (e.g. `RESERVED`, `CHECKED_IN`).
  String toApiString() {
    return switch (this) {
      BookingStatus.confirmed => 'RESERVED',
      BookingStatus.cancelled => 'CANCELLED',
      BookingStatus.checkedIn => 'CHECKED_IN',
      BookingStatus.expired => 'NO_SHOW',
    };
  }

  @override
  String toString() => toApiString();

  static BookingStatus fromString(String? string) {
    final normalized = (string ?? '').trim().toUpperCase();
    if (normalized.isEmpty) return BookingStatus.confirmed;

    // Support common variants.
    switch (normalized) {
      case 'RESERVED':
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      case 'CANCELLED':
      case 'CANCELED':
        return BookingStatus.cancelled;
      case 'CHECKED_IN':
      case 'CHECKEDIN':
        return BookingStatus.checkedIn;
      case 'NO_SHOW':
      case 'NOSHOW':
        return BookingStatus.expired;
      case 'EXPIRED':
        return BookingStatus.expired;
      default:
        // Defaulting to confirmed (RESERVED) for unknown statuses
        // to avoid UI breakage, as RESERVED is the standard initial state.
        return BookingStatus.confirmed;
    }
  }
}
