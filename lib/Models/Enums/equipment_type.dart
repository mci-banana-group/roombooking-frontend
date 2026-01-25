enum EquipmentType {
  beamer,
  whiteboard,
  display,
  videoConference,
  other;

  @override
  String toString() => name;

  static EquipmentType fromString(String? string) {
    final normalized = (string ?? '').trim();
    if (normalized.isEmpty) return EquipmentType.other;

    try {
      return EquipmentType.values.byName(normalized.toLowerCase());
    } catch (_) {
      // Backend may send values like "VIDEO_CONFERENCE" or other variants.
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
