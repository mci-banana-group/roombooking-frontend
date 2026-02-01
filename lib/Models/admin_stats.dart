class AdminStats {
  final int totalMeetings;
  final int cancelledMeetings;
  final int noShowMeetings;
  final int reservedMeetings;
  final List<SearchStat> mostSearchedItems;

  AdminStats({
    required this.totalMeetings,
    required this.cancelledMeetings,
    required this.noShowMeetings,
    required this.reservedMeetings,
    required this.mostSearchedItems,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalMeetings: json['totalMeetings'] ?? 0,
      cancelledMeetings: json['cancelledMeetings'] ?? 0,
      noShowMeetings: json['noShowMeetings'] ?? 0,
      reservedMeetings: json['reservedMeetings'] ?? 0,
      mostSearchedItems:
          (json['mostSearchedItems'] as List<dynamic>?)?.map((e) => SearchStat.fromJson(e)).toList() ?? [],
    );
  }

  // Calculated Statistics

  /// Number of successfully completed meetings (checked in)
  int get checkedInMeetings {
    // Total - cancelled - noShow - reserved (still pending)
    // This represents meetings that were actually held
    return totalMeetings - cancelledMeetings - noShowMeetings - reservedMeetings;
  }

  /// Percentage of successful meetings (checked in vs total non-cancelled)
  double get successRate {
    final nonCancelled = totalMeetings - cancelledMeetings;
    if (nonCancelled == 0) return 0.0;
    return (checkedInMeetings / nonCancelled) * 100;
  }

  /// Cancellation rate as percentage
  double get cancellationRate {
    if (totalMeetings == 0) return 0.0;
    return (cancelledMeetings / totalMeetings) * 100;
  }

  /// No-show rate as percentage
  double get noShowRate {
    final nonCancelled = totalMeetings - cancelledMeetings;
    if (nonCancelled == 0) return 0.0;
    return (noShowMeetings / nonCancelled) * 100;
  }

  /// Percentage of meetings that were actually attended
  double get attendanceRate {
    if (totalMeetings == 0) return 0.0;
    return ((checkedInMeetings) / totalMeetings) * 100;
  }

  /// Total number of "problematic" bookings (cancelled + no-show)
  int get problematicMeetings => cancelledMeetings + noShowMeetings;

  /// Efficiency rate: successful meetings vs total bookings made
  double get efficiencyRate {
    if (totalMeetings == 0) return 0.0;
    return (checkedInMeetings / totalMeetings) * 100;
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
