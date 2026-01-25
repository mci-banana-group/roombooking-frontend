enum EquipmentType {
  beamer,
  whiteboard,
  display,
  videoConference,
  hdmiCable,
  other;

  /// Display name for the equipment
  String get displayName {
    switch (this) {
      case EquipmentType.beamer:
        return 'Beamer';
      case EquipmentType.whiteboard:
        return 'Whiteboard';
      case EquipmentType.display:
        return 'Display';
      case EquipmentType.videoConference:
        return 'Video Conference';
      case EquipmentType.hdmiCable:
        return 'HDMI Cable';
      case EquipmentType.other:
        return 'Other';
    }
  }

  /// Icon name for the equipment
  String get iconName {
    switch (this) {
      case EquipmentType.beamer:
        return 'videocam';
      case EquipmentType.whiteboard:
        return 'edit';
      case EquipmentType.display:
        return 'tv';
      case EquipmentType.videoConference:
        return 'video_call';
      case EquipmentType.hdmiCable:
        return 'cable';
      case EquipmentType.other:
        return 'devices';
    }
  }

  @override
  String toString() => displayName;

  static EquipmentType fromString(String? string) {
    final normalized = (string ?? '').trim();
    if (normalized.isEmpty) return EquipmentType.other;

    try {
      return EquipmentType.values.byName(normalized.toLowerCase());
    } catch (_) {
      // Backend may send values like "VIDEO_CONFERENCE", "HDMI_CABLE" or other variants.
      final cleaned = normalized.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
      for (final v in EquipmentType.values) {
        if (v.name.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '') == cleaned) {
          return v;
        }
      }
      return EquipmentType.other;
    }
  }
}
