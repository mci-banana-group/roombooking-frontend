import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/admin_stats.dart'; 
import '../Services/admin_repository.dart'; 

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

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final data = await ref.read(adminRepositoryProvider).getStats(start: _start, end: _end);
    if (mounted) {
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    }
  }

  void _onCardTap(String category, int count) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("$category Details", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text("Number: $count", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Hier könnte wir eine Liste der Buchungen anzeigen, die zu dieser Kategorie gehören.)",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
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
              headerHeadlineStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
              Text("Stats Period", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  "${_start.day}.${_start.month} - ${_end.day}.${_end.month}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                onPressed: _pickDateRange,
              ),
            ],
          ),
          const SizedBox(height: 20),

          //Statistic Karten
          _FancyStatRow(
            title: "Total Bookings",
            value: _stats!.totalMeetings.toString(),
            icon: Icons.bar_chart,
            color1: Colors.blue.shade400,
            color2: Colors.blue.shade700,
            onTap: () => _onCardTap("Total Bookings", _stats!.totalMeetings),
          ),
          const SizedBox(height: 12),
          
          _FancyStatRow(
            title: "Reservations",
            value: _stats!.reservedMeetings.toString(),
            icon: Icons.bookmark_added,
            color1: Colors.green.shade400,
            color2: Colors.green.shade700,
            onTap: () => _onCardTap("Reservations", _stats!.reservedMeetings),
          ),
          const SizedBox(height: 12),

          _FancyStatRow(
            title: "Cancelled Meetings",
            value: _stats!.cancelledMeetings.toString(),
            icon: Icons.cancel_presentation,
            color1: Colors.orange.shade400,
            color2: Colors.orange.shade700,
            onTap: () => _onCardTap("Cancelled Meetings", _stats!.cancelledMeetings),
          ),
          const SizedBox(height: 12),

          _FancyStatRow(
            title: "No-Shows",
            value: _stats!.noShowMeetings.toString(),
            icon: Icons.person_off,
            color1: Colors.red.shade400,
            color2: Colors.red.shade700,
            onTap: () => _onCardTap("No-Shows", _stats!.noShowMeetings),
          ),

          const SizedBox(height: 30),
          
          //Equipment Trends
          Text("Equipment Trends", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          
          if (_stats!.mostSearchedItems.isEmpty)
             _buildEmptyState()
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Text("${index + 1}", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(item.term, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text("${item.count} searched", style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                );
              },
            ),
            
            // --- HINWEIS ---
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(child: Text("Room Utilization (Most/Least Used) will be added.", style: TextStyle(color: Colors.brown))),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text("No search data.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

//fancy widget for stat row
class _FancyStatRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;

  const _FancyStatRow({
    required this.title,
    required this.value,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color2.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Icon im Hintergrund
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  icon,
                  size: 150,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              //Inhalt
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 20),
                    // Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}