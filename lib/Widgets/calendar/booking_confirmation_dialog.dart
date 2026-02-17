import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'calendar_models.dart';

class BookingConfirmationDialog extends StatefulWidget {
  final RoomGridItem room;
  final DateTime selectedDate;
  final DateTime startTime;
  final DateTime endTime;
  final Future<void> Function(String) onConfirm;

  const BookingConfirmationDialog({
    super.key,
    required this.room,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.onConfirm,
  });

  @override
  State<BookingConfirmationDialog> createState() =>
      _BookingConfirmationDialogState();
}

class _BookingConfirmationDialogState extends State<BookingConfirmationDialog> {
  late TextEditingController _titleController;
  late FocusNode _focusNode;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'New Booking');
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && _titleController.text == 'New Booking') {
      _titleController.clear();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  Color _onColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final duration = widget.endTime.difference(widget.startTime);
    final durationHours = duration.inHours;
    final durationMinutes = duration.inMinutes % 60;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: widget.room.color,
                      radius: 24,
                      child: Text(
                        widget.room.avatar,
                        style: TextStyle(
                          fontSize: 20,
                          color: _onColor(widget.room.color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.room.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.room.building} - ${widget.room.floor}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Capacity: ${widget.room.capacity} persons',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.room.equipment.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available Equipment',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.room.equipment
                              .map(
                                (e) => Chip(
                                  label: Text(
                                    e,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.room.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow(
                        'Date:',
                        DateFormat('MMM d, yyyy').format(widget.startTime),
                      ),
                      const SizedBox(height: 8),
                      _detailRow(
                        'Start Time:',
                        DateFormat('HH:mm').format(widget.startTime),
                      ),
                      const SizedBox(height: 8),
                      _detailRow(
                        'End Time:',
                        DateFormat('HH:mm').format(widget.endTime),
                      ),
                      const SizedBox(height: 8),
                      _detailRow(
                        'Duration:',
                        durationHours > 0
                            ? '${durationHours}h ${durationMinutes}m'
                            : '${durationMinutes}m',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Title',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Enter booking title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              if (_titleController.text.isEmpty) return;
                              setState(() => _isSubmitting = true);
                              try {
                                await widget.onConfirm(_titleController.text);
                              } finally {
                                if (mounted)
                                  setState(() => _isSubmitting = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.room.color,
                        foregroundColor: _onColor(widget.room.color),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Confirm Booking'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
