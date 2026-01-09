import 'package:flutter/material.dart';
import 'BookingStep.dart';

class HowToBookSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final mutedColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 768;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to Book a Room',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              isMobile
                  ? _buildMobileLayout(primaryColor, textColor, mutedColor)
                  : _buildDesktopLayout(primaryColor, textColor, mutedColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(Color primaryColor, Color textColor, Color mutedColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BookingStep(
          number: 1,
          title: 'Detailed Search',
          description: 'Use the booking form to specify exact requirements - date, time, attendees, and equipment needs',
          primaryColor: primaryColor,
          textColor: textColor,
          mutedColor: mutedColor,
        ),
        const SizedBox(height: 30),
        BookingStep(
          number: 2,
          title: 'Quick View',
          description: 'Use the calendar to quickly browse all available rooms for a specific day',
          primaryColor: primaryColor,
          textColor: textColor,
          mutedColor: mutedColor,
        ),
        const SizedBox(height: 30),
        BookingStep(
          number: 3,
          title: 'Interactive Timeline',
          description: 'View room availability on a timeline and drag to select your preferred time slot',
          primaryColor: primaryColor,
          textColor: textColor,
          mutedColor: mutedColor,
        ),
        const SizedBox(height: 30),
        BookingStep(
          number: 4,
          title: 'Book & Confirm',
          description: 'Complete your booking and receive instant confirmation with QR code access',
          primaryColor: primaryColor,
          textColor: textColor,
          mutedColor: mutedColor,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(Color primaryColor, Color textColor, Color mutedColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BookingStep(
                number: 1,
                title: 'Detailed Search',
                description: 'Use the booking form to specify exact requirements - date, time, attendees, and equipment needs',
                primaryColor: primaryColor,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BookingStep(
                number: 2,
                title: 'Quick View',
                description: 'Use the calendar to quickly browse all available rooms for a specific day',
                primaryColor: primaryColor,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BookingStep(
                number: 3,
                title: 'Interactive Timeline',
                description: 'View room availability on a timeline and drag to select your preferred time slot',
                primaryColor: primaryColor,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BookingStep(
                number: 4,
                title: 'Book & Confirm',
                description: 'Complete your booking and receive instant confirmation with QR code access',
                primaryColor: primaryColor,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
