import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import '../../Models/admin_stats.dart';
import '../../Resources/AppColors.dart';

class MeetingStatsChart extends StatefulWidget {
  final AdminStats stats;
  final DateTime startDate;
  final DateTime endDate;
  final double? forcedHeight;

  const MeetingStatsChart({
    super.key,
    required this.stats,
    required this.startDate,
    required this.endDate,
    this.forcedHeight,
  });

  @override
  State<MeetingStatsChart> createState() => _MeetingStatsChartState();
}

class _MeetingStatsChartState extends State<MeetingStatsChart> {
  List<LineBarSpot> _touchedSpots = const [];

  void _clearTouchedSpots() {
    if (_touchedSpots.isNotEmpty) {
      setState(() {
        _touchedSpots = const [];
      });
    }
  }

  double _scaleFactor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / 1200).clamp(0.85, 1.15);
  }

  double _fontSize(
    BuildContext context,
    double size, {
    double? min,
    double? max,
  }) {
    final scale = _scaleFactor(context);
    final scaled = MediaQuery.textScalerOf(context).scale(size * scale);
    final lower = min ?? 0;
    final upper = max ?? double.infinity;
    return scaled.clamp(lower, upper);
  }

  double _chartHeightForWidth(double width) {
    final raw = width / 1.6;
    return raw.clamp(220, 380);
  }

  @override
  Widget build(BuildContext context) {
    final isTouchDevice = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.fuchsia);
    // Generate continuous date range from startDate to endDate
    final dates = <String>[];
    final s = DateTime(
      widget.startDate.year,
      widget.startDate.month,
      widget.startDate.day,
    );
    final e = DateTime(
      widget.endDate.year,
      widget.endDate.month,
      widget.endDate.day,
    );
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

    final totalSpots = getSpots(widget.stats.totalMeetings);
    final reservedSpots = getSpots(widget.stats.reservedMeetings);
    final checkedInSpots = getSpots(widget.stats.checkedInBookings);
    final completedSpots = getSpots(widget.stats.completedBookings);
    final userCancelledSpots = getSpots(widget.stats.userCancelledMeetings);
    final adminCancelledSpots = getSpots(widget.stats.adminCancelledMeetings);
    final noShowSpots = getSpots(widget.stats.noShowMeetings);

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
            LayoutBuilder(
              builder: (context, constraints) {
                final scale = _scaleFactor(context);
                final chartHeight =
                    widget.forcedHeight ?? _chartHeightForWidth(constraints.maxWidth);
                final dayCount = sortedDates.length;
                final perPointWidth = (constraints.maxWidth / dayCount)
                    .clamp(24, 56)
                    .toDouble();
                final desiredWidth = dayCount * perPointWidth;
                final minChartWidth = desiredWidth < constraints.maxWidth
                    ? constraints.maxWidth
                    : desiredWidth;
                final scrollBehavior = ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.trackpad,
                  },
                );
                Widget chartContent = SizedBox(
                  height: chartHeight,
                  child: ScrollConfiguration(
                    behavior: scrollBehavior,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: minChartWidth,
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
                                  axisNameWidget: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "Day",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: _fontSize(
                                          context,
                                          13,
                                          min: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  axisNameSize: 28 * scale,
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1, // Ensure integer intervals only
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 &&
                                          index < sortedDates.length) {
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
                                          final date =
                                              DateTime.tryParse(dateStr);
                                          if (date != null) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                DateFormat('dd.MM').format(date),
                                                style: TextStyle(
                                                  fontSize: _fontSize(
                                                    context,
                                                    11,
                                                    min: 12,
                                                  ),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                      return const SizedBox.shrink();
                                    },
                                    reservedSize: 30 * scale,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  axisNameWidget: Text(
                                    "Bookings",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: _fontSize(
                                        context,
                                        13,
                                        min: 13,
                                      ),
                                    ),
                                  ),
                                  axisNameSize: 28 * scale,
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40 * scale,
                                    getTitlesWidget: (value, meta) {
                                      if (value % 1 == 0) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            fontSize: _fontSize(
                                              context,
                                              11,
                                              min: 12,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                    interval: maxY > 10
                                        ? (maxY / 5).ceilToDouble()
                                        : 1,
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
                              showingTooltipIndicators: isTouchDevice &&
                                      _touchedSpots.isNotEmpty
                                  ? [ShowingTooltipIndicators(_touchedSpots)]
                                  : const [],
                              lineTouchData: LineTouchData(
                                handleBuiltInTouches: !isTouchDevice,
                                touchSpotThreshold: 20, // Hit test threshold
                                distanceCalculator: (Offset touchPoint,
                                        Offset spotPixelPoint) =>
                                    (touchPoint.dx - spotPixelPoint.dx).abs(),
                                touchCallback: isTouchDevice
                                    ? (event, response) {
                                        final isDown =
                                            event is FlTapDownEvent ||
                                                event is FlLongPressStart ||
                                                event is FlLongPressMoveUpdate ||
                                                event is FlPanStartEvent ||
                                                event is FlPanUpdateEvent;
                                        final isUp =
                                            event is FlTapUpEvent ||
                                                event is FlTapCancelEvent ||
                                                event is FlLongPressEnd ||
                                                event is FlPanEndEvent ||
                                                event is FlPanCancelEvent;
                                        if (isDown) {
                                          setState(() {
                                            _touchedSpots =
                                                response?.lineBarSpots ??
                                                    const [];
                                          });
                                        } else if (isUp) {
                                          if (_touchedSpots.isNotEmpty) {
                                            setState(() {
                                              _touchedSpots = const [];
                                            });
                                          }
                                        }
                                      }
                                    : null,
                                touchTooltipData: LineTouchTooltipData(
                                  fitInsideHorizontally: true,
                                  fitInsideVertically: true,
                                  getTooltipColor: (_) =>
                                      Colors.blueGrey.shade900,
                                  tooltipMargin: 16,
                                  tooltipPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  maxContentWidth: 220,
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

                                    return touchedSpots
                                        .map((LineBarSpot touchedSpot) {
                                      final textStyle = TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: _fontSize(
                                          context,
                                          13,
                                          min: 13,
                                        ),
                                      );
                                      String label = "";
                                      if (touchedSpot.bar.color ==
                                          AppColors.chartTotal)
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
                                        if (index >= 0 &&
                                            index < sortedDates.length) {
                                          final dateStr = sortedDates[index];
                                          final date =
                                              DateTime.tryParse(dateStr);
                                          final header = date != null
                                              ? DateFormat('dd.MM.yyyy')
                                                  .format(date)
                                              : "";

                                          return LineTooltipItem(
                                            '$header\n',
                                            TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: _fontSize(
                                                context,
                                                15,
                                                min: 14,
                                              ),
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '$label: ${touchedSpot.y.toInt()}',
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
                    ),
                  ),
                );
                if (!isTouchDevice) {
                  return chartContent;
                }
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (_) => _clearTouchedSpots(),
                  onTapCancel: _clearTouchedSpots,
                  onPanEnd: (_) => _clearTouchedSpots(),
                  onPanCancel: _clearTouchedSpots,
                  onLongPressEnd: (_) => _clearTouchedSpots(),
                  child: chartContent,
                );
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem(context, "Total", AppColors.chartTotal),
                _buildLegendItem(context, "Reservations", AppColors.chartReserved),
                _buildLegendItem(context, "Checked In", AppColors.chartCheckedIn),
                _buildLegendItem(context, "Completed", AppColors.chartCompleted),
                _buildLegendItem(
                  context,
                  "User Cancelled",
                  AppColors.chartUserCancelled,
                ),
                _buildLegendItem(
                  context,
                  "Admin Cancelled",
                  AppColors.chartAdminCancelled,
                ),
                _buildLegendItem(context, "No-Shows", AppColors.chartNoShowRed),
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

  Widget _buildLegendItem(BuildContext context, String title, Color color) {
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
          style: TextStyle(
            fontSize: _fontSize(
              context,
              13,
              min: 13,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
