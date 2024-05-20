import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  late SharedPreferences prefs;
  late GeolocatorPlatform geolocator;

  List<LocationProfile> _profiles = [];
  List<LocationProfile> get profiles => _profiles;

  LocationProvider() {
    _initializeLocationService();
    loadProfiles();
  }

  Future<void> _initializeLocationService() async {
    geolocator = GeolocatorPlatform.instance;
    await Permission.location.request();
  }

  Future<void> loadProfiles() async {
    prefs = await SharedPreferences.getInstance();
    List<String>? profileStrings = prefs.getStringList('location_profiles');
    if (profileStrings != null) {
      _profiles = profileStrings.map((profile) => LocationProfile.fromJson(profile)).toList();
      notifyListeners();
    }
  }

  Future<void> addProfile(LocationProfile profile) async {
    _profiles.add(profile);
    notifyListeners();
    await _saveProfiles();
  }

  Future<void> removeProfile(LocationProfile profile) async {
    _profiles.remove(profile);
    notifyListeners();
    await _saveProfiles();
  }

  Future<void> _saveProfiles() async {
    List<String> profileStrings = _profiles.map((profile) => profile.toJson()).toList();
    await prefs.setStringList('location_profiles', profileStrings);
  }
}

class LocationProfile {
  final double latitude;
  final double longitude;
  final double radius;
  final String soundMode;
  final String name;

  LocationProfile({
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.soundMode,
    required this.name,
  });

  String toJson() {
    return jsonEncode({
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'soundMode': soundMode,
      'name': name,
    });
  }

  factory LocationProfile.fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    return LocationProfile(
      latitude: data['latitude'],
      longitude: data['longitude'],
      radius: data['radius'],
      soundMode: data['soundMode'],
      name: data['name'],
    );
  }
}
