class RoomUsageStats {
  final String roomId;
  final int totalBookings;
  final Duration averageUsageDuration; // in db as milliseconds
  final double utilizationRate;

  const RoomUsageStats({
    required this.roomId,
    required this.totalBookings,
    required this.averageUsageDuration,
    required this.utilizationRate,
  });

  RoomUsageStats copyWith({
    String? roomId,
    int? totalBookings,
    Duration? averageUsageDuration,
    double? utilizationRate,
  }) {
    return RoomUsageStats(
      roomId: roomId ?? this.roomId,
      totalBookings: totalBookings ?? this.totalBookings,
      averageUsageDuration: averageUsageDuration ?? this.averageUsageDuration,
      utilizationRate: utilizationRate ?? this.utilizationRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'totalBookings': totalBookings,
      'averageUsageDuration': averageUsageDuration.inMilliseconds,
      'utilizationRate': utilizationRate,
    };
  }

  factory RoomUsageStats.fromJson(Map<String, dynamic> json) {
    return RoomUsageStats(
      roomId: json['roomId'] as String,
      totalBookings: json['totalBookings'] as int,
      averageUsageDuration: Duration(milliseconds: json['averageUsageDuration'] as int),
      utilizationRate: (json['utilizationRate'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomUsageStats &&
        other.roomId == roomId &&
        other.totalBookings == totalBookings &&
        other.averageUsageDuration == averageUsageDuration &&
        other.utilizationRate == utilizationRate;
  }

  @override
  int get hashCode => Object.hash(roomId, totalBookings, averageUsageDuration, utilizationRate);

  @override
  String toString() =>
      'RoomUsageStats(roomId: $roomId, totalBookings: $totalBookings, averageUsageDuration: $averageUsageDuration, utilizationRate: $utilizationRate)';
}
