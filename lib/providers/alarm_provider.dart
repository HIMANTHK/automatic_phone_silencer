import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:geolocator/geolocator.dart';
import '../models/event_model.dart';  // Import the Event model

class AlarmProvider with ChangeNotifier {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late SharedPreferences prefs;

  List<Event> _events = [];
  List<Event> get events => _events;

  String _deviceStatus = 'Unknown';
  String get deviceStatus => _deviceStatus;

  AlarmProvider() {
    _initializeNotifications();
    loadEvents();
    checkDeviceStatus();
  }

  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones(); // Initialize time zones
  }

  Future<void> loadEvents() async {
    prefs = await SharedPreferences.getInstance();
    List<String>? eventStrings = prefs.getStringList('events');
    if (eventStrings != null) {
      _events = eventStrings.map((event) => Event.fromJson(event)).toList();
      notifyListeners();
    }
  }

  Future<void> addEvent(String eventName, DateTime eventDate, TimeOfDay startTime, TimeOfDay endTime, String customMessage, double? latitude, double? longitude) async {
    final event = Event(
      eventName: eventName,
      eventDate: eventDate,
      startTime: startTime,
      endTime: endTime,
      customMessage: customMessage,
      latitude: latitude,
      longitude: longitude,
    );
    _events.add(event);
    notifyListeners();

    await _scheduleEvent(event);
    await _saveEvents();
  }

  Future<void> updateEvent(Event oldEvent, String eventName, DateTime eventDate, TimeOfDay startTime, TimeOfDay endTime, String customMessage, double? latitude, double? longitude) async {
    final newEvent = Event(
      id: oldEvent.id,
      eventName: eventName,
      eventDate: eventDate,
      startTime: startTime,
      endTime: endTime,
      customMessage: customMessage,
      latitude: latitude,
      longitude: longitude,
    );
    int index = _events.indexOf(oldEvent);
    if (index != -1) {
      _events[index] = newEvent;
      notifyListeners();

      await flutterLocalNotificationsPlugin.cancel(oldEvent.id);
      await _scheduleEvent(newEvent);
      await _saveEvents();
    }
  }

  Future<void> removeEvent(Event event) async {
    _events.remove(event);
    notifyListeners();
    await flutterLocalNotificationsPlugin.cancel(event.id);
    await _saveEvents();
  }

  Future<void> _scheduleEvent(Event event) async {
    final startDateTime = DateTime(event.eventDate.year, event.eventDate.month, event.eventDate.day, event.startTime.hour, event.startTime.minute);
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'event_channel',
      'Event Notifications',
      channelDescription: 'Channel for Event notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('silent'),
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      event.id,
      event.eventName,
      'Event starts at ${event.startTime.hour}:${event.startTime.minute}',
      tz.TZDateTime.from(startDateTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    if (await Permission.notification.request().isGranted) {
      // Trigger silent mode
    }
  }

  Future<void> _saveEvents() async {
    List<String> eventStrings = _events.map((event) => event.toJson()).toList();
    await prefs.setStringList('events', eventStrings);
  }

  Future<void> checkDeviceStatus() async {
    // Check the device's current ringer mode
    // This functionality is not directly supported by flutter_ringtone_player,
    // you might need to use another package or native code for this.
    // For demonstration, we're setting the status to normal
    _deviceStatus = 'Normal';
    notifyListeners();
  }

  void updateDeviceStatus() async {
    bool isEventRunning = _events.any((event) {
      final startDateTime = DateTime(event.eventDate.year, event.eventDate.month, event.eventDate.day, event.startTime.hour, event.startTime.minute);
      final endDateTime = DateTime(event.eventDate.year, event.eventDate.month, event.eventDate.day, event.endTime.hour, event.endTime.minute);
      return startDateTime.isBefore(DateTime.now()) && endDateTime.isAfter(DateTime.now());
    });

    if (isEventRunning) {
      // Set volume to zero to simulate silent mode
      FlutterRingtonePlayer.playRingtone(volume: 0.0);
      _deviceStatus = 'Silent';
    } else {
      FlutterRingtonePlayer.stop();
      _deviceStatus = 'Normal';
    }

    notifyListeners();
  }

  Future<void> checkLocation(Event event) async {
    if (event.latitude == null || event.longitude == null) {
      // No location set for this event
      updateDeviceStatus();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double distanceInMeters = Geolocator.distanceBetween(
      event.latitude!,
      event.longitude!,
      position.latitude,
      position.longitude,
    );

    if (distanceInMeters <= 500) {
      // User is within 500 meters of the event location
      updateDeviceStatus();
    } else {
      // User is not within the required distance
      FlutterRingtonePlayer.stop();
      _deviceStatus = 'Normal';
      notifyListeners();
    }
  }
}
