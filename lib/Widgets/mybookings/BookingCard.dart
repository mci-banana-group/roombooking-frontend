import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../Resources/AppColors.dart';
import '../../models/Enums/booking_status.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final String roomName;

  const BookingCard({
    super.key,
    required this.booking,
    required this.roomName,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDarkMode ? Theme.of(context).cardColor : AppColors.cardWhite,
      elevation: 2,
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 6 : 8,
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with room name and status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roomName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(context, isMobile),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 12),
            // Date and time info
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: isMobile ? 14 : 16,
                  color: AppColors.mutedText,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(booking.startTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Time range
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: isMobile ? 14 : 16,
                  color: AppColors.mutedText,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Reference ID
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: isMobile ? 14 : 16,
                  color: AppColors.mutedText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ref: #${booking.id.substring(0, 8).toUpperCase()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedText,
                      fontSize: isMobile ? 11 : 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.edit, size: isMobile ? 16 : 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryAccent,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 12,
                      vertical: isMobile ? 4 : 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.close, size: isMobile ? 16 : 18),
                  label: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.statusRed,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 12,
                      vertical: isMobile ? 4 : 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isMobile) {
    late Color backgroundColor;
    late Color textColor;
    late IconData icon;
    late String label;

    switch (booking.status) {
      case BookingStatus.pending:
        backgroundColor = AppColors.statusYellow.withOpacity(0.2);
        textColor = AppColors.statusYellow;
        icon = Icons.schedule;
        label = 'Pending';
        break;
      case BookingStatus.confirmed:
        backgroundColor = AppColors.primaryAccent.withOpacity(0.2);
        textColor = AppColors.primaryAccent;
        icon = Icons.check_circle;
        label = 'Confirmed';
        break;
      case BookingStatus.cancelled:
        backgroundColor = AppColors.statusRed.withOpacity(0.2);
        textColor = AppColors.statusRed;
        icon = Icons.cancel;
        label = 'Cancelled';
        break;
      case BookingStatus.expired:
        backgroundColor = AppColors.mutedText.withOpacity(0.2);
        textColor = AppColors.mutedText;
        icon = Icons.schedule;
        label = 'Expired';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 12 : 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}