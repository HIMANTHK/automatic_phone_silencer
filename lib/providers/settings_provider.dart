import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences prefs;

  bool _isAppEnabled = true;
  bool get isAppEnabled => _isAppEnabled;

  int _defaultSilentDuration = 30;
  int get defaultSilentDuration => _defaultSilentDuration;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    prefs = await SharedPreferences.getInstance();
    _isAppEnabled = prefs.getBool('isAppEnabled') ?? true;
    _defaultSilentDuration = prefs.getInt('defaultSilentDuration') ?? 30;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    notifyListeners();
  }

  Future<void> setAppEnabled(bool value) async {
    _isAppEnabled = value;
    await prefs.setBool('isAppEnabled', value);
    notifyListeners();
  }

  Future<void> setDefaultSilentDuration(int value) async {
    _defaultSilentDuration = value;
    await prefs.setInt('defaultSilentDuration', value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await prefs.setBool('notificationsEnabled', value);
    notifyListeners();
  }
}
