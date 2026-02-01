import 'room.dart';

class AdminStats {
  final Map<String, int> totalMeetings;
  final Map<String, int> userCancelledMeetings;
  final Map<String, int> adminCancelledMeetings;
  final Map<String, int> completedBookings;
  final Map<String, int> checkedInBookings;
  final Map<String, int> noShowMeetings;
  final Map<String, int> reservedMeetings;
  final List<SearchStat> mostSearchedItems;
  final List<RoomUsageCount> mostUsedRooms;

  AdminStats({
    required this.totalMeetings,
    required this.userCancelledMeetings,
    required this.adminCancelledMeetings,
    required this.completedBookings,
    required this.checkedInBookings,
    required this.noShowMeetings,
    required this.reservedMeetings,
    required this.mostSearchedItems,
    required this.mostUsedRooms,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalMeetings: _parseIntMap(json['totalMeetings']),
      userCancelledMeetings: _parseIntMap(json['userCancelledMeetings']),
      adminCancelledMeetings: _parseIntMap(json['adminCancelledMeetings']),
      completedBookings: _parseIntMap(json['completedBookings']),
      checkedInBookings: _parseIntMap(json['checkedInBookings']),
      noShowMeetings: _parseIntMap(json['noShowMeetings']),
      reservedMeetings: _parseIntMap(json['reservedMeetings']),
      mostSearchedItems:
          (json['mostSearchedItems'] as List<dynamic>?)?.map((e) => SearchStat.fromJson(e)).toList() ?? [],
      mostUsedRooms: (json['mostUsedRooms'] as List<dynamic>?)?.map((e) => RoomUsageCount.fromJson(e)).toList() ?? [],
    );
  }

  static Map<String, int> _parseIntMap(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      final result = <String, int>{};
      value.forEach((key, val) {
        result[key.toString()] = _toInt(val);
      });
      return result;
    }
    return {};
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  // Helper to sum all values in a map
  int _sumMap(Map<String, int> map) => map.values.fold(0, (sum, val) => sum + val);

  // Aggregated values (summing across all keys)
  int get totalMeetingsCount => _sumMap(totalMeetings);
  int get userCancelledMeetingsCount => _sumMap(userCancelledMeetings);
  int get adminCancelledMeetingsCount => _sumMap(adminCancelledMeetings);
  int get completedBookingsCount => _sumMap(completedBookings);
  int get checkedInBookingsCount => _sumMap(checkedInBookings);
  int get noShowMeetingsCount => _sumMap(noShowMeetings);
  int get reservedMeetingsCount => _sumMap(reservedMeetings);

  // Combined cancelled (user + admin)
  int get cancelledMeetingsCount => userCancelledMeetingsCount + adminCancelledMeetingsCount;

  // Calculated Statistics

  /// Number of successfully completed meetings (checked in)
  int get checkedInMeetings {
    // Total - cancelled - noShow - reserved (still pending)
    // This represents meetings that were actually held
    return totalMeetingsCount - cancelledMeetingsCount - noShowMeetingsCount - reservedMeetingsCount;
  }

  /// Percentage of successful meetings (checked in vs total non-cancelled)
  double get successRate {
    final nonCancelled = totalMeetingsCount - cancelledMeetingsCount;
    if (nonCancelled == 0) return 0.0;
    return (checkedInMeetings / nonCancelled) * 100;
  }

  /// Cancellation rate as percentage
  double get cancellationRate {
    if (totalMeetingsCount == 0) return 0.0;
    return (cancelledMeetingsCount / totalMeetingsCount) * 100;
  }

  /// No-show rate as percentage
  double get noShowRate {
    final nonCancelled = totalMeetingsCount - cancelledMeetingsCount;
    if (nonCancelled == 0) return 0.0;
    return (noShowMeetingsCount / nonCancelled) * 100;
  }

  /// Percentage of meetings that were actually attended
  double get attendanceRate {
    if (totalMeetingsCount == 0) return 0.0;
    return ((checkedInMeetings) / totalMeetingsCount) * 100;
  }

  /// Total number of "problematic" bookings (cancelled + no-show)
  int get problematicMeetings => cancelledMeetingsCount + noShowMeetingsCount;

  /// Efficiency rate: successful meetings vs total bookings made
  double get efficiencyRate {
    if (totalMeetingsCount == 0) return 0.0;
    return (checkedInMeetings / totalMeetingsCount) * 100;
  }
}

class SearchStat {
  final String term;
  final int count;

  SearchStat({required this.term, required this.count});

  factory SearchStat.fromJson(Map<String, dynamic> json) {
    return SearchStat(term: json['term'] ?? 'Unknown', count: json['count'] ?? 0);
  }
}

class RoomUsageCount {
  final Room room;
  final int occupiedMinutes;

  RoomUsageCount({required this.room, required this.occupiedMinutes});

  factory RoomUsageCount.fromJson(Map<String, dynamic> json) {
    return RoomUsageCount(
      room: Room.fromJson(json['room'] as Map<String, dynamic>),
      occupiedMinutes: (json['occupiedMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}
