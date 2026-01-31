import 'package:flutter/material.dart';

class RoomGridItem {
  final int id;
  final String name;
  final int capacity;
  final Color color;
  final IconData icon;
  final String avatar;
  final String building;
  final String floor;
  final List<String> equipment;

  const RoomGridItem({
    required this.id,
    required this.name,
    required this.capacity,
    required this.color,
    required this.icon,
    required this.avatar,
    required this.building,
    required this.floor,
    required this.equipment,
  });
}

class CalendarBooking {
  final int roomId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final bool isMyBooking;

  const CalendarBooking({
    required this.roomId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.isMyBooking = false,
  });
}

class DraftBooking {
  final int roomId;
  final RoomGridItem roomInfo;
  DateTime startTime;
  DateTime endTime;
  double startPixelOffset;
  double endPixelOffset;
  bool isPreselected;

  DraftBooking({
    required this.roomId,
    required this.roomInfo,
    required this.startTime,
    required this.endTime,
    required this.startPixelOffset,
    required this.endPixelOffset,
    this.isPreselected = false,
  });
}
