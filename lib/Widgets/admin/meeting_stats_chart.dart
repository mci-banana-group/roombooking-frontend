import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Models/admin_stats.dart';
import '../../Resources/AppColors.dart';

class MeetingStatsChart extends StatelessWidget {
  final AdminStats stats;
  final DateTime startDate;
  final DateTime endDate;

  const MeetingStatsChart({
    super.key,
    required this.stats,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    // Generate continuous date range from startDate to endDate
    final dates = <String>[];
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    final e = DateTime(endDate.year, endDate.month, endDate.day);
    if (e.isBefore(s)) {
      dates.add(DateFormat('yyyy-MM-dd').format(s));
    } else {
      final dayCount = e.difference(s).inDays + 1;
      for (int i = 0; i < dayCount; i++) {
        final d = DateTime(s.year, s.month, s.day + i);
        dates.add(DateFormat('yyyy-MM-dd').format(d));
      }
    }
    final sortedDates = dates;

    if (sortedDates.isEmpty) return const SizedBox();

    // Map each date to an index (0, 1, 2...) for X-axis
    // Construct spots for each series
    List<FlSpot> getSpots(Map<String, int> dataMap) {
      return List.generate(sortedDates.length, (index) {
        final dateKey = sortedDates[index];
        final value = dataMap[dateKey]?.toDouble() ?? 0.0;
        return FlSpot(index.toDouble(), value);
      });
    }

    // Combine cancelled (User + Admin) removed - showing separate

    final totalSpots = getSpots(stats.totalMeetings);
    final reservedSpots = getSpots(stats.reservedMeetings);
    final checkedInSpots = getSpots(stats.checkedInBookings);
    final completedSpots = getSpots(stats.completedBookings);
    final userCancelledSpots = getSpots(stats.userCancelledMeetings);
    final adminCancelledSpots = getSpots(stats.adminCancelledMeetings);
    final noShowSpots = getSpots(stats.noShowMeetings);

    final lineBars = <LineChartBarData>[
      _buildLine(reservedSpots, AppColors.chartReserved),
      _buildLine(checkedInSpots, AppColors.chartCheckedIn),
      _buildLine(completedSpots, AppColors.chartCompleted),
      _buildLine(userCancelledSpots, AppColors.chartUserCancelled),
      _buildLine(adminCancelledSpots, AppColors.chartAdminCancelled),
      _buildLine(noShowSpots, AppColors.chartNoShowRed),
      _buildLine(totalSpots, AppColors.chartTotal),
    ];

    // Find Max Y for scaling
    double maxY = 0;
    for (var bar in lineBars) {
      for (var spot in bar.spots) {
        if (spot.y > maxY) maxY = spot.y;
      }
    }
    maxY = (maxY * 1.2).ceilToDouble(); // Add some buffer
    if (maxY < 5) maxY = 5;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Booking Trends",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.5,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 16.0,
                  left: 6.0,
                  bottom: 8.0,
                ),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        axisNameWidget: const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Day",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        axisNameSize: 30,
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1, // Ensure integer intervals only
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < sortedDates.length) {
                              final count = sortedDates.length;
                              // Ensure we don't crowd labels: >15 days -> every 2 days.
                              int interval = 1;
                              if (count > 15) {
                                interval = 2;
                              }

                              if (index == 0 ||
                                  index == count - 1 ||
                                  index % interval == 0) {
                                final dateStr = sortedDates[index];
                                final date = DateTime.tryParse(dateStr);
                                if (date != null) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat('dd.MM').format(date),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: const Text(
                          "Bookings",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        axisNameSize: 30,
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
                    minX: 0,
                    maxX: sortedDates.length.toDouble() - 1,
                    minY: 0,
                    maxY: maxY,
                    lineBarsData: lineBars,
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchSpotThreshold: 20, // Hit test threshold
                      distanceCalculator:
                          (Offset touchPoint, Offset spotPixelPoint) =>
                              (touchPoint.dx - spotPixelPoint.dx).abs(),
                      touchTooltipData: LineTouchTooltipData(
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipColor: (_) => Colors.blueGrey.shade900,
                        getTooltipItems: (touchedSpots) {
                          // Define Priority based on Legend Order
                          final priority = {
                            AppColors.chartTotal: 0,
                            AppColors.chartReserved: 1,
                            AppColors.chartCheckedIn: 2,
                            AppColors.chartCompleted: 3,
                            AppColors.chartUserCancelled: 4,
                            AppColors.chartAdminCancelled: 5,
                            AppColors.chartNoShowRed: 6,
                          };

                          touchedSpots.sort((a, b) {
                            final pA = priority[a.bar.color] ?? 99;
                            final pB = priority[b.bar.color] ?? 99;
                            return pA.compareTo(pB);
                          });

                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            final textStyle = TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            );
                            String label = "";
                            if (touchedSpot.bar.color == AppColors.chartTotal)
                              label = "Total";
                            else if (touchedSpot.bar.color ==
                                AppColors.chartReserved)
                              label = "Reserved";
                            else if (touchedSpot.bar.color ==
                                AppColors.chartCheckedIn)
                              label = "Checked-In";
                            else if (touchedSpot.bar.color ==
                                AppColors.chartCompleted)
                              label = "Completed";
                            else if (touchedSpot.bar.color ==
                                AppColors.chartUserCancelled)
                              label = "User Cancelled";
                            else if (touchedSpot.bar.color ==
                                AppColors.chartAdminCancelled)
                              label = "Admin Cancelled";
                            else if (touchedSpot.bar.color ==
                                AppColors.chartNoShowRed)
                              label = "No-Show";

                            // Add Date Header to the first item
                            if (touchedSpot == touchedSpots.first) {
                              final index = touchedSpot.x.toInt();
                              if (index >= 0 && index < sortedDates.length) {
                                final dateStr = sortedDates[index];
                                final date = DateTime.tryParse(dateStr);
                                final header = date != null
                                    ? DateFormat('dd.MM.yyyy').format(date)
                                    : "";

                                return LineTooltipItem(
                                  '$header\n',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '$label: ${touchedSpot.y.toInt()}',
                                      style: textStyle,
                                    ),
                                  ],
                                );
                              }
                            }

                            return LineTooltipItem(
                              '$label: ${touchedSpot.y.toInt()}',
                              textStyle,
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem("Total", AppColors.chartTotal),
                _buildLegendItem("Reservations", AppColors.chartReserved),
                _buildLegendItem("Checked In", AppColors.chartCheckedIn),
                _buildLegendItem("Completed", AppColors.chartCompleted),
                _buildLegendItem(
                  "User Cancelled",
                  AppColors.chartUserCancelled,
                ),
                _buildLegendItem(
                  "Admin Cancelled",
                  AppColors.chartAdminCancelled,
                ),
                _buildLegendItem("No-Shows", AppColors.chartNoShowRed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
