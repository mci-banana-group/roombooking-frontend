import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../Resources/AppColors.dart';
import '../Models/Enums/equipment_type.dart';
import '../Models/admin_stats.dart';
import '../Services/admin_repository.dart';
import '../Widgets/admin/meeting_stats_bar_chart.dart';
import '../Widgets/admin/meeting_stats_chart.dart';
import '../Widgets/admin/room_list_tile.dart';


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
    final picked = await showDialog<DateTimeRange>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return _RangePickerDialog(
          initialRange: DateTimeRange(start: _start, end: _end),
          firstDate: DateTime(2023),
          lastDate: DateTime(2030),
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

  bool _isKnownEquipmentTerm(String term) {
    final normalized = term.trim();
    if (normalized.isEmpty) return false;
    for (final type in EquipmentType.values) {
      if (normalized == type.apiValue ||
          normalized.toLowerCase() == type.name.toLowerCase() ||
          normalized.toLowerCase() == type.displayName.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  String _humanizeEquipmentTerm(String term) {
    final cleaned = term.trim().replaceAll(RegExp(r'[_-]+'), ' ');
    if (cleaned.isEmpty) return 'Other';
    return cleaned
        .split(RegExp(r'\s+'))
        .map((part) {
          final lower = part.toLowerCase();
          if (lower.isEmpty) return '';
          return lower[0].toUpperCase() + lower.substring(1);
        })
        .join(' ');
  }

  IconData _iconForEquipmentType(EquipmentType type) {
    switch (type) {
      case EquipmentType.beamer:
        return Icons.videocam;
      case EquipmentType.whiteboard:
        return Icons.edit;
      case EquipmentType.display:
        return Icons.tv;
      case EquipmentType.videoConference:
        return Icons.video_call;
      case EquipmentType.hdmiCable:
        return Icons.cable;
      case EquipmentType.other:
        return Icons.devices;
    }
  }

  Widget _buildRankBadge(Color accent, int rank) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        "$rank",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: accent,
        ),
      ),
    );
  }

  Widget _buildDateRangeChip(ColorScheme colorScheme) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _pickDateRange,
      child: SizedBox(
        height: 48,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  "${_start.day}.${_start.month} - ${_end.day}.${_end.month}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, String? subtitle) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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

  Widget _statsPeriodHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Reporting period",
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            _buildDateRangeChip(colorScheme),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Your booking and usage overview.",
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_stats == null) {
      return const Center(child: Text("No stats available yet."));
    }

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
              if (width >= 1100)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 12,
                        children: [
                          _statsPeriodHeader(context),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
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
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Icon(Icons.show_chart), // Line Chart
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Icon(Icons.bar_chart), // Bar Chart
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
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
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Icon(Icons.show_chart), // Line Chart
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Icon(Icons.bar_chart), // Bar Chart
                                ),
                              ],
                            ),
                    ),
                  ],
                )
              else
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runAlignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 12,
                  children: [
                    _statsPeriodHeader(context),
                  ],
                ),
              const SizedBox(height: 16),

              if (width < 1100)
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
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
                                child: Icon(Icons.show_chart), // Line Chart
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
                                child: Icon(Icons.bar_chart), // Bar Chart
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
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
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
                                child: Icon(Icons.show_chart), // Line Chart
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
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
                "Key metrics",
                "Rates across booking outcomes.",
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
                        title: "Success rate",
                        percentage: _stats!.successRate,
                        description: "Checked in vs non‑cancelled bookings",
                        color: Colors.green,
                      ),
                      _PercentageStatCard(
                        title: "Attendance rate",
                        percentage: _stats!.attendanceRate,
                        description: "Checked in vs total bookings",
                        color: Colors.blue,
                      ),
                      _PercentageStatCard(
                        title: "Cancellation rate",
                        percentage: _stats!.cancellationRate,
                        description: "Cancelled vs total bookings",
                        color: Colors.orange,
                      ),
                      _PercentageStatCard(
                        title: "No‑show rate",
                        percentage: _stats!.noShowRate,
                        description: "No‑shows vs non‑cancelled bookings",
                        color: Colors.red,
                      ),
                      _PercentageStatCard(
                        title: "Efficiency rate",
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
      title: "Popular equipment",
      subtitle: "Top searches for this period.",
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      headerGap: 12,
      scrollBody: true,
      child: isEmpty
          ? _buildEmptyState("No equipment searches yet.")
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
                final isKnown = _isKnownEquipmentTerm(item.term);
                final equipmentType = EquipmentType.fromString(item.term);
                final displayName = isKnown
                    ? equipmentType.displayName
                    : _humanizeEquipmentTerm(item.term);
                final icon =
                    isKnown ? _iconForEquipmentType(equipmentType) : Icons.devices;
                return _EquipmentTrendTile(
                  leading: _buildRankBadge(colorScheme.primary, index + 1),
                  icon: icon,
                  name: displayName,
                  count: item.count,
                );
              },
            ),
    );
  }

  Widget _buildMostUsedRooms(BuildContext context, double listGap) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEmpty = _stats!.mostUsedRooms.isEmpty;
    return _SectionCard(
      title: "Room ranking",
      subtitle: "Rooms with the most booked time.",
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      headerGap: 12,
      scrollBody: true,
      child: isEmpty
          ? _buildEmptyState("No room usage yet.")
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
                return RoomListTile(
                  roomName: room.name,
                  capacity: room.capacity,
                  equipmentTypes: room.equipment
                      .where((e) => e.quantity > 0)
                      .map((e) => e.type)
                      .toList(),
                  leading:
                      _buildRankBadge(colorScheme.secondary, index + 1),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      timeDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
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

class _RangePickerDialog extends StatefulWidget {
  final DateTimeRange initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  const _RangePickerDialog({
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_RangePickerDialog> createState() => _RangePickerDialogState();
}

class _RangePickerDialogState extends State<_RangePickerDialog> {
  static const Color _mciBlue = AppColors.mciBlue;

  late DateTime _start;
  late DateTime _end;
  late DateTime _baseMonth;
  bool _selectingStart = false;

  @override
  void initState() {
    super.initState();
    _start = _stripTime(widget.initialRange.start);
    _end = _stripTime(widget.initialRange.end);
    _baseMonth = DateTime(_start.year, _start.month, 1);
  }

  DateTime _stripTime(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, 1);
  }

  int _daysInMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSelectable(DateTime day) {
    return !day.isBefore(_stripTime(widget.firstDate)) &&
        !day.isAfter(_stripTime(widget.lastDate));
  }

  void _handleDateTap(DateTime day) {
    if (!_isSelectable(day)) return;
    setState(() {
      if (_selectingStart) {
        _start = day;
        _end = day;
        _selectingStart = false;
      } else {
        if (day.isBefore(_start)) {
          _end = _start;
          _start = day;
        } else {
          _end = day;
        }
        _selectingStart = true;
      }
    });
  }

  Widget _buildMonth(
    BuildContext context,
    DateTime month,
    List<String> weekdayLabels,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final title = DateFormat('MMMM', locale.toString()).format(month);
    final daysInMonth = _daysInMonth(month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    final leadingEmpty = firstWeekday - 1;
    final items = <DateTime?>[];
    for (int i = 0; i < leadingEmpty; i++) {
      items.add(null);
    }
    for (int day = 1; day <= daysInMonth; day++) {
      items.add(DateTime(month.year, month.month, day));
    }

    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: weekdayLabels
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final day = items[index];
            if (day == null) return const SizedBox.shrink();
            final isStart = _isSameDay(day, _start);
            final isEnd = _isSameDay(day, _end);
            final inRange = day.isAfter(_start) && day.isBefore(_end);
            final isSame = isStart && isEnd;
            final isToday = _isSameDay(day, _stripTime(DateTime.now()));
            final enabled = _isSelectable(day);

            Color textColor = colorScheme.onSurface;
            if (!enabled) {
              textColor = colorScheme.onSurfaceVariant.withOpacity(0.4);
            } else if (isStart || isEnd) {
              textColor = Colors.white;
            } else if (inRange) {
              textColor = colorScheme.onSurface;
            }

            Color? background;
            if (inRange) {
              background = _mciBlue.withOpacity(0.12);
            }
            if (isStart || isEnd) {
              background = _mciBlue;
            }

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: enabled ? () => _handleDateTap(day) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(20),
                  border: isToday && !isStart && !isEnd
                      ? Border.all(color: _mciBlue, width: 1)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight:
                            isStart || isEnd || isSame ? FontWeight.bold : null,
                      ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = Localizations.localeOf(context);
    final weekdayLabels = List.generate(7, (index) {
      final date = DateTime(2020, 6, 1 + index);
      final label = DateFormat.E(locale.toString()).format(date);
      return label.substring(0, 1).toUpperCase();
    });

    final minBaseMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= 700;
          final maxBaseMonth =
              twoColumns ? _addMonths(lastMonth, -1) : lastMonth;
          final canPrev = _baseMonth.isAfter(minBaseMonth);
          final canNext = _baseMonth.isBefore(maxBaseMonth);
          final monthB = _addMonths(_baseMonth, 1);

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: math.min(860, MediaQuery.sizeOf(context).width - 32),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Select dates",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: _mciBlue,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_start.day}.${_start.month}.${_start.year} → ${_end.day}.${_end.month}.${_end.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: canPrev
                            ? () {
                                setState(() {
                                  _baseMonth = _addMonths(_baseMonth, -1);
                                });
                              }
                            : null,
                        color: _mciBlue,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: canNext
                            ? () {
                                setState(() {
                                  _baseMonth = _addMonths(_baseMonth, 1);
                                });
                              }
                            : null,
                        color: _mciBlue,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (twoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildMonth(context, _baseMonth, weekdayLabels),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMonth(context, monthB, weekdayLabels),
                        ),
                      ],
                    )
                  else
                    _buildMonth(context, _baseMonth, weekdayLabels),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _start = _stripTime(DateTime.now());
                            _end = _start;
                            _baseMonth = DateTime(_start.year, _start.month, 1);
                            _selectingStart = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _mciBlue,
                        ),
                        child: const Text('Today'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop(
                            DateTimeRange(start: _start, end: _end),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _mciBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 40),
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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

class _EquipmentTrendTile extends StatelessWidget {
  final Widget leading;
  final IconData icon;
  final String name;
  final int count;

  const _EquipmentTrendTile({
    required this.leading,
    required this.icon,
    required this.name,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: leading,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "$count ${count == 1 ? 'search' : 'searches'}",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
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
