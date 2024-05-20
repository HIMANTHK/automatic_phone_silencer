import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageProvider with ChangeNotifier {
  late SharedPreferences prefs;
  String _message = 'I am busy right now.';
  String get message => _message;

  MessageProvider() {
    loadMessage();
  }

  Future<void> loadMessage() async {
    prefs = await SharedPreferences.getInstance();
    _message = prefs.getString('auto_reply_message') ?? 'I am busy right now.';
    notifyListeners();
  }

  Future<void> updateMessage(String newMessage) async {
    _message = newMessage;
    notifyListeners();
    await prefs.setString('auto_reply_message', newMessage);
  }

  Future<void> sendAutoReply(String phoneNumber) async {
    await sendSMS(message: _message, recipients: [phoneNumber]);
  }
}
