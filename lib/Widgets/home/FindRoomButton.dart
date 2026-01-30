import 'package:flutter/material.dart';

class FindRoomButton extends StatelessWidget {
  final int? roomCount;
  final VoidCallback? onPressed;

  const FindRoomButton({super.key, this.onPressed, this.roomCount});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    String buttonText = 'Find Available Rooms';
    if (roomCount != null) {
      if (roomCount == 0) {
        buttonText = 'No Rooms Available';
      } else if (roomCount == 1) {
        buttonText = 'Find 1 Available Room';
      } else {
        buttonText = 'Find $roomCount Available Rooms';
      }
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 18),
            const SizedBox(width: 8),
            Text(buttonText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
