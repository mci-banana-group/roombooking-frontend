import 'package:flutter/material.dart';
import 'package:mci_booking_app/Resources/AppColors.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Total Bookings',
              value: totalBookings.toString(),
              icon: Icons.calendar_month,
              iconColor: AppColors.primaryAccent,
              isDarkMode: isDarkMode,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: _StatCard(
              title: 'Upcoming',
              value: upcomingBookings.toString(),
              icon: Icons.check_circle,
              iconColor: AppColors.primaryAccent,
              isDarkMode: isDarkMode,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: _StatCard(
              title: 'Past Bookings',
              value: pastBookings.toString(),
              icon: Icons.history,
              iconColor: AppColors.mutedText,
              isDarkMode: isDarkMode,
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
  final bool isDarkMode;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Card(
      color: isDarkMode ? Theme.of(context).cardColor : AppColors.cardWhite,
      elevation: 1,
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
                      color: AppColors.mutedText,
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