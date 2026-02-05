import 'package:flutter/material.dart';

import '../../Models/Enums/equipment_type.dart';

class RoomListTile extends StatelessWidget {
  final String roomName;
  final int capacity;
  final List<EquipmentType> equipmentTypes;
  final Widget trailing;
  final Widget? leading;
  final VoidCallback? onTap;

  const RoomListTile({
    super.key,
    required this.roomName,
    required this.capacity,
    required this.equipmentTypes,
    required this.trailing,
    this.leading,
    this.onTap,
  });

  IconData _getIconForType(EquipmentType type) {
    switch (type) {
      case EquipmentType.beamer:
        return Icons.videocam;
      case EquipmentType.whiteboard:
        return Icons.edit;
      case EquipmentType.display:
        return Icons.tv;
      case EquipmentType.videoConference:
        return Icons.video_call;
      case EquipmentType.hdmiCable:
        return Icons.cable;
      case EquipmentType.other:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Text(
        "Room: $roomName",
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            Icon(
              Icons.people_outline,
              size: 16,
              color: colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              "$capacity",
              style: TextStyle(
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 16),
            if (equipmentTypes.isNotEmpty)
              ...equipmentTypes.take(5).map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        _getIconForType(type),
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      trailing: trailing,
    );
  }
}
