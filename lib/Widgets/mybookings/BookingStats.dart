import 'package:flutter/material.dart';

class BookingStats extends StatelessWidget {
  final int totalBookings;
  final int upcomingBookings;
  final int pastBookings;

  const BookingStats({
    super.key,
    required this.totalBookings,
    required this.upcomingBookings,
    required this.pastBookings,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Total Bookings',
              value: totalBookings.toString(),
              icon: Icons.calendar_month,
              iconColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: _StatCard(
              title: 'Upcoming',
              value: upcomingBookings.toString(),
              icon: Icons.check_circle,
              iconColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: _StatCard(
              title: 'Past Bookings',
              value: pastBookings.toString(),
              icon: Icons.history,
              iconColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      fontSize: isMobile ? 10 : 12,
                    ),
                  ),
                ),
                Icon(
                  icon,
                  size: isMobile ? 16 : 20,
                  color: iconColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 24 : 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
