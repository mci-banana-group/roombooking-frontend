import 'package:flutter/material.dart';

class FindRoomButton extends StatelessWidget {
  final int? roomCount;
  final VoidCallback? onPressed;

  const FindRoomButton({super.key, this.onPressed, this.roomCount});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    // Disable if roomCount is explicitly 0.
    // If roomCount is null, we assume we are still loading or initial state, so keep enabled (or handle as loading).
    // Assuming enabled for null based on previous logic.
    final bool isEnabled = roomCount != 0;



    return Container(
      width: double.infinity,
      height: 56, // Fixed height for consistency
      decoration: BoxDecoration(
        color: isEnabled ? primaryColor : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isEnabled) ...[
                const Icon(Icons.search, size: 22, color: Colors.white),
                const SizedBox(width: 10),
                const Text(
                  'Show Rooms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${roomCount ?? 0}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  'No Rooms Available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
