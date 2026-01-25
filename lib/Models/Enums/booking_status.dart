enum BookingStatus {
  /// Backend: `PENDING` (if used)
  pending,

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
      BookingStatus.pending => 'PENDING',
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
    if (normalized.isEmpty) return BookingStatus.pending;

    // Support common variants.
    switch (normalized) {
      case 'RESERVED':
        return BookingStatus.confirmed;
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      case 'PENDING':
        return BookingStatus.pending;
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
        return BookingStatus.pending;
    }
  }
}
