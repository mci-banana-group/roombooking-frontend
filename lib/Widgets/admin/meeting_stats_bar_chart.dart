import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Models/admin_stats.dart';
import '../../Resources/AppColors.dart';

class MeetingStatsBarChart extends StatelessWidget {
  final AdminStats stats;
  final DateTime startDate;
  final DateTime endDate;

  const MeetingStatsBarChart({
    super.key,
    required this.stats,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Filter data based on date range
    bool isDateInRange(String dateStr) {
      final date = DateTime.tryParse(dateStr);
      if (date == null) return false;
      // Compare dates only (ignore time)
      final d = DateTime(date.year, date.month, date.day);
      final s = DateTime(startDate.year, startDate.month, startDate.day);
      final e = DateTime(endDate.year, endDate.month, endDate.day);
      return (d.isAtSameMomentAs(s) || d.isAfter(s)) &&
          (d.isAtSameMomentAs(e) || d.isBefore(e));
    }

    int sumInRange(Map<String, int> map) {
      int total = 0;
      map.forEach((key, value) {
        if (isDateInRange(key)) {
          total += value;
        }
      });
      return total;
    }

    // 2. Aggregate counts
    final totalMeetingsCount = sumInRange(stats.totalMeetings);
    final reservedCount = sumInRange(stats.reservedMeetings);
    final checkedInCount = sumInRange(stats.checkedInBookings);
    final completedCount = sumInRange(stats.completedBookings);
    final userCancelledCount = sumInRange(stats.userCancelledMeetings);
    final adminCancelledCount = sumInRange(stats.adminCancelledMeetings);
    final noShowCount = sumInRange(stats.noShowMeetings);

    // 3. Prepare Bar Groups
    // Index:
    // 0: Total
    // 1: Reserved
    // 2: Checked-In
    // 3: Completed
    // 4: User Cancelled
    // 5: Admin Cancelled
    // 6: No-Show
    final barGroups = [
      _makeGroupData(0, totalMeetingsCount.toDouble(), AppColors.chartTotal),
      _makeGroupData(1, reservedCount.toDouble(), AppColors.chartReserved),
      _makeGroupData(2, checkedInCount.toDouble(), AppColors.chartCheckedIn),
      _makeGroupData(3, completedCount.toDouble(), AppColors.chartCompleted),
      _makeGroupData(
        4,
        userCancelledCount.toDouble(),
        AppColors.chartUserCancelled,
      ),
      _makeGroupData(
        5,
        adminCancelledCount.toDouble(),
        AppColors.chartAdminCancelled,
      ),
      _makeGroupData(6, noShowCount.toDouble(), AppColors.chartNoShowRed),
    ];

    // Find Max Y
    double maxY = 0;
    for (var val in [
      totalMeetingsCount,
      reservedCount,
      checkedInCount,
      completedCount,
      userCancelledCount,
      adminCancelledCount,
      noShowCount,
    ]) {
      if (val > maxY) maxY = val.toDouble();
    }
    maxY = (maxY * 1.2).ceilToDouble();
    if (maxY < 5) maxY = 5;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Booking Status Distribution from ${DateFormat('dd.MM.yyyy').format(startDate)} to ${DateFormat('dd.MM.yyyy').format(endDate)}",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.5,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipColor: (_) => Colors.blueGrey.shade900,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String status = "";
                          switch (group.x) {
                            case 0:
                              status = "Total";
                              break;
                            case 1:
                              status = "Reserved";
                              break;
                            case 2:
                              status = "Checked-In";
                              break;
                            case 3:
                              status = "Completed";
                              break;
                            case 4:
                              status = "User Cancelled";
                              break;
                            case 5:
                              status = "Admin Cancelled";
                              break;
                            case 6:
                              status = "No-Shows";
                              break;
                          }
                          return BarTooltipItem(
                            '$status\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: rod.toY.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.white, // Or specific color
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10, // Smaller font to fit
                            );
                            Widget text;
                            switch (value.toInt()) {
                              case 0:
                                text = const Text('Total', style: style);
                                break;
                              case 1:
                                text = const Text('Reserved', style: style);
                                break;
                              case 2:
                                text = const Text('Checked-In', style: style);
                                break;
                              case 3:
                                text = const Text('Completed', style: style);
                                break;
                              case 4:
                                text = const Text(
                                  'User Cancelled',
                                  style: style,
                                );
                                break;
                              case 5:
                                text = const Text(
                                  'Admin Cancelled',
                                  style: style,
                                );
                                break;
                              case 6:
                                text = const Text('No-Show', style: style);
                                break;
                              default:
                                text = const Text('', style: style);
                                break;
                            }
                            return SideTitleWidget(
                              meta: meta,
                              space: 4,
                              child: text,
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value % 1 == 0) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          interval: maxY > 10 ? (maxY / 5).ceilToDouble() : 1,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: y,
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}
