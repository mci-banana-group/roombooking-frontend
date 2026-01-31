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
      mostSearchedItems: (json['mostSearchedItems'] as List<dynamic>?)
              ?.map((e) => SearchStat.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SearchStat {
  final String term;
  final int count;

  SearchStat({required this.term, required this.count});

  factory SearchStat.fromJson(Map<String, dynamic> json) {
    return SearchStat(
      term: json['term'] ?? 'Unknown',
      count: json['count'] ?? 0,
    );
  }
}