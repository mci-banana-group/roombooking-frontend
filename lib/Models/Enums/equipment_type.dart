enum EquipmentType {
  beamer,
  whiteboard,
  display,
  videoConference,
  other;

  @override
  String toString() => name;

  static EquipmentType fromString(String string) => EquipmentType.values.byName(string.toLowerCase());
}
