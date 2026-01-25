import 'package:flutter/material.dart';
import '../../Models/booking.dart';
import '../../Models/Enums/booking_status.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final String roomName;

  const BookingCard({super.key, required this.booking, required this.roomName});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: isMobile ? 6 : 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2), width: 1),
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
                          color: Theme.of(context).colorScheme.onSurface,
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(booking.startTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: isMobile ? 12 : 14,
                    color: Theme.of(context).colorScheme.onSurface,
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: isMobile ? 12 : 14,
                    color: Theme.of(context).colorScheme.onSurface,
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ref: #${booking.id.length > 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id.toUpperCase()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 4 : 8),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.close, size: isMobile ? 16 : 18),
                  label: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 4 : 8),
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
        backgroundColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange;
        icon = Icons.schedule;
        label = 'Pending';
        break;
      case BookingStatus.confirmed:
        backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.15);
        textColor = Theme.of(context).colorScheme.primary;
        icon = Icons.check_circle;
        label = 'Reserved';
        break;
      case BookingStatus.cancelled:
        backgroundColor = Colors.red.withOpacity(0.15);
        textColor = Colors.red;
        icon = Icons.cancel;
        label = 'Cancelled';
        break;
      case BookingStatus.checkedIn:
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green;
        icon = Icons.verified;
        label = 'Checked in';
        break;
      case BookingStatus.expired:
        backgroundColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.15);
        textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
        icon = Icons.schedule;
        label = 'No show';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2 : 4),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(6)),
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
