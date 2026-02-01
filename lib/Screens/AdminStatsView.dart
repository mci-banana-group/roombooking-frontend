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

  bool _showLineChart = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
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
            datePickerTheme: const DatePickerThemeData(
              headerHeadlineStyle: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              headerHelpStyle: TextStyle(fontSize: 12.0),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_stats == null) return const Center(child: Text("No data."));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Stats Period",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  "${_start.day}.${_start.month} - ${_end.day}.${_end.month}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                ),
                onPressed: _pickDateRange,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart Toggle & Chart
          if (_stats != null) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(10),
                  isSelected: [_showLineChart, !_showLineChart],
                  onPressed: (index) {
                    setState(() {
                      _showLineChart = index == 0;
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
              crossFadeState: _showLineChart
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),
          ],

          const SizedBox(height: 30),

          // Performance Metrics Section
          Text(
            "Performance Metrics",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),

          _PercentageStatCard(
            title: "Success Rate",
            percentage: _stats!.successRate,
            description: "Checked-in vs non-cancelled bookings",
            color: Colors.green,
          ),
          const SizedBox(height: 10),

          _PercentageStatCard(
            title: "Attendance Rate",
            percentage: _stats!.attendanceRate,
            description: "Checked-in vs total bookings",
            color: Colors.blue,
          ),
          const SizedBox(height: 10),

          _PercentageStatCard(
            title: "Cancellation Rate",
            percentage: _stats!.cancellationRate,
            description: "Cancelled vs total bookings",
            color: Colors.orange,
          ),
          const SizedBox(height: 10),

          _PercentageStatCard(
            title: "No-Show Rate",
            percentage: _stats!.noShowRate,
            description: "No-shows vs non-cancelled bookings",
            color: Colors.red,
          ),
          const SizedBox(height: 10),

          _PercentageStatCard(
            title: "Efficiency Rate",
            percentage: _stats!.efficiencyRate,
            description: "Successful meetings vs total bookings",
            color: Colors.purple,
          ),

          const SizedBox(height: 30),

          //Equipment Trends
          Text(
            "Equipment Trends",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),

          if (_stats!.mostSearchedItems.isEmpty)
            _buildEmptyState("No search data.")
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stats!.mostSearchedItems.length,
              itemBuilder: (ctx, index) {
                final item = _stats!.mostSearchedItems[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      item.term,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${item.count} searched",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 30),

          // Most Used Rooms Section
          Text(
            "Most Used Rooms",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),

          if (_stats!.mostUsedRooms.isEmpty)
            _buildEmptyState("No room usage data.")
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stats!.mostUsedRooms.length,
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
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.1),
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      room.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${room.building?.name ?? 'Unknown Building'} - Room ${room.roomNumber}",
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        timeDisplay,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
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
                  style: const TextStyle(
                    fontSize: 16,
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
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
