import 'package:flutter/material.dart';

class EquipmentCheckbox extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool?) onChanged;
  final bool isDark;
  final Color primaryColor;
  final Color textColor;

  const EquipmentCheckbox({
    required this.label,
    required this.isSelected,
    required this.onChanged,
    required this.isDark,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
            border: Border.all(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.2), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(value: isSelected, onChanged: onChanged, activeColor: primaryColor),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
