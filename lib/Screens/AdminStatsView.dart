import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Models/admin_stats.dart';
import '../Services/admin_repository.dart';
import '../Widgets/admin/meeting_stats_bar_chart.dart';
import '../Widgets/admin/meeting_stats_chart.dart';

class AdminStatsView extends ConsumerStatefulWidget {
  const AdminStatsView({super.key});

  @override
  ConsumerState<AdminStatsView> createState() => _AdminStatsViewState();
}

class _AdminStatsViewState extends ConsumerState<AdminStatsView> {
  AdminStats? _stats;
  bool _isLoading = true;

  DateTime _start = DateTime.now().subtract(const Duration(days: 30));
  DateTime _end = DateTime.now();

  int _chartMode = 1; // 0: line, 1: bar, 2: both
  bool _chartModeInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_chartModeInitialized) {
      final width = MediaQuery.sizeOf(context).width;
      if (width >= 1200) {
        setState(() {
          _chartMode = 2;
          _chartModeInitialized = true;
        });
      }
    }
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final data = await ref
        .read(adminRepositoryProvider)
        .getStats(start: _start, end: _end);
    if (mounted) {
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _start, end: _end),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerHeadlineStyle: TextStyle(
                fontSize: _fontSize(context, 16),
                fontWeight: FontWeight.bold,
              ),
              headerHelpStyle: TextStyle(fontSize: _fontSize(context, 12)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _start = picked.start;
        _end = picked.end;
      });
      _loadStats();
    }
  }

  double _scaleFactor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / 1200).clamp(0.85, 1.15);
  }

  double _fontSize(BuildContext context, double size, {double? min}) {
    final scale = _scaleFactor(context);
    final scaled = MediaQuery.textScalerOf(context).scale(size * scale);
    if (min == null) return scaled;
    return scaled < min ? min : scaled;
  }

  int _metricsColumns(double width) {
    if (width >= 1200) return 3;
    if (width >= 900) return 2;
    return 1;
  }

  bool _twoColumnLists(double width) => width >= 1000;

  double _listCardFixedHeight(double width) {
    if (width >= 1200) return 620;
    if (width >= 900) return 560;
    return 520;
  }

  Widget _sectionHeader(BuildContext context, String title, String? subtitle) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_stats == null) return const Center(child: Text("No data."));

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = width >= 1200 ? 24.0 : 16.0;
        final colorScheme = Theme.of(context).colorScheme;

        final metricsColumns = _metricsColumns(width);
        final showTwoLists = _twoColumnLists(width);
        final listGap = width >= 1200 ? 24.0 : 16.0;
        final sectionGap = width >= 1200 ? 28.0 : 20.0;
        final canShowBothCharts = width >= 1200;
        final showBothCharts = canShowBothCharts && _chartMode == 2;
        final listCardHeight = _listCardFixedHeight(width);
        final metricCardHeight = width >= 1200 ? 132.0 : 140.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  _sectionHeader(
                    context,
                    "Stats Period",
                    "Overview of bookings and usage trends.",
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      "${_start.day}.${_start.month} - ${_end.day}.${_end.month}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                    ),
                    onPressed: _pickDateRange,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: canShowBothCharts
                      ? ToggleButtons(
                          borderRadius: BorderRadius.circular(10),
                          isSelected: [
                            _chartMode == 0,
                            _chartMode == 1,
                            _chartMode == 2,
                          ],
                          onPressed: (index) {
                            setState(() {
                              _chartMode = index;
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Icon(Icons.show_chart), // Line Chart
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Icon(Icons.bar_chart), // Bar Chart
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Icon(Icons.dashboard), // Both
                            ),
                          ],
                        )
                      : ToggleButtons(
                          borderRadius: BorderRadius.circular(10),
                          isSelected: [_chartMode == 0, _chartMode == 1],
                          onPressed: (index) {
                            setState(() {
                              _chartMode = index;
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Icon(Icons.show_chart), // Line Chart
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Icon(Icons.bar_chart), // Bar Chart
                            ),
                          ],
                        ),
                ),
              ),
              if (showBothCharts)
                LayoutBuilder(
                  builder: (context, chartConstraints) {
                    final availableWidth =
                        chartConstraints.maxWidth - listGap;
                    if (availableWidth < 640) {
                      return AnimatedCrossFade(
                        firstChild: MeetingStatsChart(
                          stats: _stats!,
                          startDate: _start,
                          endDate: _end,
                        ),
                        secondChild: MeetingStatsBarChart(
                          stats: _stats!,
                          startDate: _start,
                          endDate: _end,
                        ),
                        crossFadeState: _chartMode == 0
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 300),
                      );
                    }
                    final perChartWidth = availableWidth / 2;
                    final sharedHeight =
                        (perChartWidth / 1.6).clamp(240, 420).toDouble();
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: perChartWidth,
                          child: MeetingStatsChart(
                            stats: _stats!,
                            startDate: _start,
                            endDate: _end,
                            forcedHeight: sharedHeight,
                          ),
                        ),
                        SizedBox(width: listGap),
                        SizedBox(
                          width: perChartWidth,
                          child: MeetingStatsBarChart(
                            stats: _stats!,
                            startDate: _start,
                            endDate: _end,
                            forcedHeight: sharedHeight,
                            reserveLegendSpace: true,
                          ),
                        ),
                      ],
                    );
                  },
                )
              else
                AnimatedCrossFade(
                  firstChild: MeetingStatsChart(
                    stats: _stats!,
                    startDate: _start,
                    endDate: _end,
                  ),
                  secondChild: MeetingStatsBarChart(
                    stats: _stats!,
                    startDate: _start,
                    endDate: _end,
                  ),
                  crossFadeState: _chartMode == 0
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 300),
                ),

              SizedBox(height: sectionGap),

              _sectionHeader(
                context,
                "Performance Metrics",
                "Key rates across booking outcomes.",
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, gridConstraints) {
                  final availableWidth = gridConstraints.maxWidth;
                  final spacing = 16.0;
                  final columns = metricsColumns;
                  final totalSpacing = spacing * (columns - 1);
                  final tileWidth =
                      (availableWidth - totalSpacing) / columns;
                  final tileHeight = metricCardHeight;
                  final childAspectRatio = tileWidth / tileHeight;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: columns,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    children: [
                      _PercentageStatCard(
                        title: "Success Rate",
                        percentage: _stats!.successRate,
                        description: "Checked-in vs non-cancelled bookings",
                        color: Colors.green,
                      ),
                      _PercentageStatCard(
                        title: "Attendance Rate",
                        percentage: _stats!.attendanceRate,
                        description: "Checked-in vs total bookings",
                        color: Colors.blue,
                      ),
                      _PercentageStatCard(
                        title: "Cancellation Rate",
                        percentage: _stats!.cancellationRate,
                        description: "Cancelled vs total bookings",
                        color: Colors.orange,
                      ),
                      _PercentageStatCard(
                        title: "No-Show Rate",
                        percentage: _stats!.noShowRate,
                        description: "No-shows vs non-cancelled bookings",
                        color: Colors.red,
                      ),
                      _PercentageStatCard(
                        title: "Efficiency Rate",
                        percentage: _stats!.efficiencyRate,
                        description: "Successful meetings vs total bookings",
                        color: Colors.purple,
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: sectionGap),

              if (showTwoLists)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: listCardHeight,
                        child: _buildEquipmentTrends(context, listGap),
                      ),
                    ),
                    SizedBox(width: listGap),
                    Expanded(
                      child: SizedBox(
                        height: listCardHeight,
                        child: _buildMostUsedRooms(context, listGap),
                      ),
                    ),
                  ],
                )
              else ...[
                SizedBox(
                  height: listCardHeight,
                  child: _buildEquipmentTrends(context, listGap),
                ),
                SizedBox(height: listGap),
                SizedBox(
                  height: listCardHeight,
                  child: _buildMostUsedRooms(context, listGap),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEquipmentTrends(BuildContext context, double listGap) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEmpty = _stats!.mostSearchedItems.isEmpty;
    return _SectionCard(
      title: "Equipment Trends",
      subtitle: "Most searched equipment in the selected period.",
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      headerGap: 12,
      scrollBody: true,
      child: isEmpty
          ? _buildEmptyState("No search data.")
          : ListView.separated(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _stats!.mostSearchedItems.length,
              separatorBuilder: (_, __) => Divider(
                height: 16,
                color: colorScheme.outlineVariant.withOpacity(0.6),
              ),
              itemBuilder: (ctx, index) {
                final item = _stats!.mostSearchedItems[index];
                return _RankedRow(
                  index: index + 1,
                  title: item.term,
                  subtitle: "Searches",
                  accent: colorScheme.primary,
                  trailing: _StatPill(
                    label: "${item.count}",
                    suffix: "searched",
                    color: colorScheme.primary,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMostUsedRooms(BuildContext context, double listGap) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEmpty = _stats!.mostUsedRooms.isEmpty;
    return _SectionCard(
      title: "Most Used Rooms",
      subtitle: "Top rooms by total occupied time.",
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      headerGap: 12,
      scrollBody: true,
      child: isEmpty
          ? _buildEmptyState("No room usage data.")
          : ListView.separated(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _stats!.mostUsedRooms.length,
              separatorBuilder: (_, __) => Divider(
                height: 16,
                color: colorScheme.outlineVariant.withOpacity(0.6),
              ),
              itemBuilder: (ctx, index) {
                final roomUsage = _stats!.mostUsedRooms[index];
                final room = roomUsage.room;
                final hours = roomUsage.occupiedMinutes ~/ 60;
                final minutes = roomUsage.occupiedMinutes % 60;
                String timeDisplay;
                if (hours > 0 && minutes > 0) {
                  timeDisplay = "${hours}h ${minutes}m";
                } else if (hours > 0) {
                  timeDisplay = "${hours}h";
                } else {
                  timeDisplay = "${minutes}m";
                }
                return _RankedRow(
                  index: index + 1,
                  title: room.name,
                  subtitle:
                      "${room.building?.name ?? 'Unknown Building'} • Room ${room.roomNumber}",
                  accent: colorScheme.secondary,
                  trailing: _StatPill(
                    label: timeDisplay,
                    suffix: "total",
                    color: colorScheme.secondary,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool expandChild;
  final bool scrollBody;
  final EdgeInsetsGeometry padding;
  final double headerGap;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.expandChild = false,
    this.scrollBody = false,
    this.padding = const EdgeInsets.all(16),
    this.headerGap = 16,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: headerGap),
            if (scrollBody || expandChild) Expanded(child: child) else child,
          ],
        ),
      ),
    );
  }
}

class _RankedRow extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final Color accent;
  final Widget trailing;

  const _RankedRow({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            "$index",
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        trailing,
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String suffix;
  final Color color;

  const _StatPill({
    required this.label,
    required this.suffix,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: RichText(
        text: TextSpan(
          style: textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(text: label),
            TextSpan(
              text: " $suffix",
              style: textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for percentage-based statistics
class _PercentageStatCard extends StatelessWidget {
  final String title;
  final double percentage;
  final String description;
  final Color color;

  const _PercentageStatCard({
    required this.title,
    required this.percentage,
    required this.description,
    required this.color,
  });

  double _scaleFactor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / 1200).clamp(0.85, 1.15);
  }

  double _fontSize(BuildContext context, double size) {
    final scale = _scaleFactor(context);
    return MediaQuery.textScalerOf(context).scale(size * scale);
  }

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = percentage.clamp(0.0, 100.0);
    final displayPercentage = clampedPercentage.toStringAsFixed(1);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _fontSize(context, 16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$displayPercentage%",
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: _fontSize(context, 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: _fontSize(context, 12),
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: clampedPercentage / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
