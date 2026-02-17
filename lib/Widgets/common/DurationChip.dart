import 'package:flutter/material.dart';

class DurationChip extends StatelessWidget {
  final String label;
  final Color primaryColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const DurationChip(
    this.label,
    this.primaryColor, {
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor
                : primaryColor.withOpacity(0.1),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : primaryColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? Colors.white
                  : primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyDurationChip extends StatelessWidget {
  final String label;
  final Color primaryColor;

  const EmptyDurationChip(this.label, this.primaryColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
