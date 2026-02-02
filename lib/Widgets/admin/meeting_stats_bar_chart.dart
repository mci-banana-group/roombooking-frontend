import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import '../../Models/admin_stats.dart';
import '../../Resources/AppColors.dart';

class MeetingStatsBarChart extends StatelessWidget {
  final AdminStats stats;
  final DateTime startDate;
  final DateTime endDate;
  final double? forcedHeight;
  final bool reserveLegendSpace;

  const MeetingStatsBarChart({
    super.key,
    required this.stats,
    required this.startDate,
    required this.endDate,
    this.forcedHeight,
    this.reserveLegendSpace = false,
  });

  double _scaleFactor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / 1200).clamp(0.95, 1.2);
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
    final barSpecs = [
      _BarSpec(0, totalMeetingsCount.toDouble(), AppColors.chartTotal(context)),
      _BarSpec(1, reservedCount.toDouble(), AppColors.chartReserved),
      _BarSpec(2, checkedInCount.toDouble(), AppColors.chartCheckedIn),
      _BarSpec(3, completedCount.toDouble(), AppColors.chartCompleted),
      _BarSpec(4, userCancelledCount.toDouble(), AppColors.chartUserCancelled),
      _BarSpec(5, adminCancelledCount.toDouble(), AppColors.chartAdminCancelled),
      _BarSpec(6, noShowCount.toDouble(), AppColors.chartNoShowRed),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final scale = _scaleFactor(context);
                final chartHeight =
                    forcedHeight ?? _chartHeightForWidth(constraints.maxWidth);
                final isCompact = constraints.maxWidth < 520;
                final barCount = barSpecs.length;
                final slotMinWidth = isCompact ? 96.0 : 140.0;
                final minChartWidth = math.max(
                  constraints.maxWidth,
                  barCount * slotMinWidth,
                );
                final perBarSlot = minChartWidth / barCount;
                final barWidth =
                    (perBarSlot * 0.45).clamp(6, 28).toDouble();
                final sizedBarGroups = barSpecs
                    .map(
                      (spec) =>
                          _makeGroupData(spec.x, spec.y, spec.color, barWidth),
                    )
                    .toList();
                return SizedBox(
                  height: chartHeight,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.touch,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: minChartWidth,
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
                                  getTooltipColor: (_) =>
                                      Colors.blueGrey.shade900,
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
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
                                      TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: _fontSize(context, 14),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: rod.toY.toInt().toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: _fontSize(context, 12),
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
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      final style = TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: _fontSize(
                                          context,
                                          13,
                                          min: 14,
                                        ),
                                      );
                                      Widget label(String text) {
                                        final child = Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Text(text, style: style),
                                        );
                                        if (!isCompact) return child;
                                        return Transform.rotate(
                                          angle: -math.pi / 4,
                                          alignment: Alignment.topLeft,
                                          child: child,
                                        );
                                      }

                                      Widget text;
                                      final index = value.toInt();
                                      switch (value.toInt()) {
                                        case 0:
                                          text = label('Total');
                                          break;
                                        case 1:
                                          text = label(
                                            isCompact ? 'Resv' : 'Reserved',
                                          );
                                          break;
                                        case 2:
                                          text = label(
                                            isCompact
                                                ? 'Check-In'
                                                : 'Checked-In',
                                          );
                                          break;
                                        case 3:
                                          text = label(
                                            isCompact ? 'Compl' : 'Completed',
                                          );
                                          break;
                                        case 4:
                                          text = label(
                                            isCompact
                                                ? 'U-Cxl'
                                                : 'User Cancelled',
                                          );
                                          break;
                                        case 5:
                                          text = label(
                                            isCompact
                                                ? 'A-Cxl'
                                                : 'Admin Cancelled',
                                          );
                                          break;
                                        case 6:
                                          text = label(
                                            isCompact ? 'No-Show' : 'No-Show',
                                          );
                                          break;
                                        default:
                                          text = const SizedBox.shrink();
                                          break;
                                      }
                                      if (index == 4 || index == 5) {
                                        final shift = 6.0 * scale;
                                        text = Transform.translate(
                                          offset: Offset(
                                            index == 4 ? -shift : shift,
                                            0,
                                          ),
                                          child: text,
                                        );
                                      }
                                      return SideTitleWidget(
                                        meta: meta,
                                        space: isCompact ? 16 : 10,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Transform.translate(
                                            offset: const Offset(0, 6),
                                            child: text,
                                          ),
                                        ),
                                      );
                                    },
                                    reservedSize: (isCompact ? 120 : 72) * scale,
                                  ),
                                ),
                                leftTitles: AxisTitles(
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
                                              12,
                                              min: 13,
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
                              barGroups: sizedBarGroups,
                              gridData: const FlGridData(
                                show: true,
                                drawVerticalLine: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (reserveLegendSpace) ...[
              const SizedBox(height: 16),
              Opacity(
                opacity: 0,
                child: IgnorePointer(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                       _buildLegendItem(context, "Total", AppColors.chartTotal(context)),
                      _buildLegendItem(
                        context,
                        "Reservations",
                        AppColors.chartReserved,
                      ),
                      _buildLegendItem(
                        context,
                        "Checked In",
                        AppColors.chartCheckedIn,
                      ),
                      _buildLegendItem(
                        context,
                        "Completed",
                        AppColors.chartCompleted,
                      ),
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
                      _buildLegendItem(
                        context,
                        "No-Shows",
                        AppColors.chartNoShowRed,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(
    int x,
    double y,
    Color color,
    double barWidth,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: barWidth,
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

class _BarSpec {
  final int x;
  final double y;
  final Color color;

  const _BarSpec(this.x, this.y, this.color);
}
