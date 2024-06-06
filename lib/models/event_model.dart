import 'dart:convert';
import 'package:flutter/material.dart';

class Event {
  final int id;
  final String eventName;
  final DateTime eventDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String customMessage;
  final double? latitude;
  final double? longitude;

  Event({
    required this.eventName,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.customMessage,
    this.latitude,
    this.longitude,
    int? id,
  }) : id = id ?? eventDate.millisecondsSinceEpoch;

  String toJson() {
    return jsonEncode({
      'id': id,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'customMessage': customMessage,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  factory Event.fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    return Event(
      id: data['id'],
      eventName: data['eventName'],
      eventDate: DateTime.parse(data['eventDate']),
      startTime: TimeOfDay(
        hour: int.parse(data['startTime'].split(':')[0]),
        minute: int.parse(data['startTime'].split(':')[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(data['endTime'].split(':')[0]),
        minute: int.parse(data['endTime'].split(':')[1]),
      ),
      customMessage: data['customMessage'],
      latitude: data['latitude'],
      longitude: data['longitude'],
    );
  }
}
