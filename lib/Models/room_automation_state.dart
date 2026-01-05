class RoomAutomationState {
  // needed?

  final bool doorLocked;
  final bool lightOn;
  final bool ventilationOn;

  const RoomAutomationState({required this.doorLocked, required this.lightOn, required this.ventilationOn});

  RoomAutomationState copyWith({bool? doorLocked, bool? lightOn, bool? ventilationOn}) {
    return RoomAutomationState(
      doorLocked: doorLocked ?? this.doorLocked,
      lightOn: lightOn ?? this.lightOn,
      ventilationOn: ventilationOn ?? this.ventilationOn,
    );
  }

  Map<String, dynamic> toJson() {
    return {'doorLocked': doorLocked, 'lightOn': lightOn, 'ventilationOn': ventilationOn};
  }

  factory RoomAutomationState.fromJson(Map<String, dynamic> json) {
    return RoomAutomationState(
      doorLocked: json['doorLocked'] as bool,
      lightOn: json['lightOn'] as bool,
      ventilationOn: json['ventilationOn'] as bool,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomAutomationState &&
        other.doorLocked == doorLocked &&
        other.lightOn == lightOn &&
        other.ventilationOn == ventilationOn;
  }

  @override
  int get hashCode => Object.hash(doorLocked, lightOn, ventilationOn);

  @override
  String toString() => 'RoomAutomationState(doorLocked: $doorLocked, lightOn: $lightOn, ventilationOn: $ventilationOn)';
}
