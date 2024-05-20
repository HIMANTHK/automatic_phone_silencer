import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Notification Settings'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to notification settings
              },
            ),
            // Add more settings here
          ],
        ),
      ),
    );
  }
}
