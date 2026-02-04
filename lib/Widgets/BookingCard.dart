import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/Enums/booking_status.dart';

class BookingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final List<Widget>? actions;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.actions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final timeFormat = DateFormat('HH:mm');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // No border as requested
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildCardContent(textTheme, colorScheme, dateFormat, timeFormat),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildCardContent(textTheme, colorScheme, dateFormat, timeFormat),
            ),
    );
  }

  Widget _buildCardContent(TextTheme textTheme, ColorScheme colorScheme, DateFormat dateFormat, DateFormat timeFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusChip(status, colorScheme),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date and Time
            Icon(Icons.calendar_today, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              dateFormat.format(startTime),
              style: textTheme.bodyMedium,
            ),
            const SizedBox(width: 16),
            Icon(Icons.access_time, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              "${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}",
              style: textTheme.bodyMedium,
            ),
            
            const Spacer(),
            
            // Actions
            if (actions != null && actions!.isNotEmpty)
              ...actions!,
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(BookingStatus status, ColorScheme colorScheme) {
    final s = status.toApiString(); // Assuming toApiString exists or using toString
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case BookingStatus.confirmed: // Mapped from RESERVED
        color = Colors.green;
        icon = Icons.check_circle_outline;
        label = "RESERVED";
        break;
      case BookingStatus.checkedIn:
        color = colorScheme.primary;
        icon = Icons.login;
        label = "CHECKED IN";
        break;
      case BookingStatus.cancelled:
        color = colorScheme.error;
        icon = Icons.cancel_outlined;
        label = "CANCELLED";
        break;
      case BookingStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        label = "PENDING";
        break;
      case BookingStatus.expired: // Mapped from NO_SHOW
        color = colorScheme.outline;
        icon = Icons.event_busy;
        label = "NO SHOW";
        break;
      default:
        color = colorScheme.outline;
        icon = Icons.help_outline;
        label = s;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
