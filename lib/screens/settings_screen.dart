import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Enable App'),
            value: settingsProvider.isAppEnabled,
            onChanged: (value) {
              settingsProvider.setAppEnabled(value);
            },
          ),
          ListTile(
            title: Text('Default Silent Mode Duration'),
            subtitle: Text('${settingsProvider.defaultSilentDuration} minutes'),
            onTap: () async {
              int? duration = await _showNumberPicker(
                context,
                'Default Silent Mode Duration',
                settingsProvider.defaultSilentDuration,
                1,
                60,
              );
              if (duration != null) {
                settingsProvider.setDefaultSilentDuration(duration);
              }
            },
          ),
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: settingsProvider.notificationsEnabled,
            onChanged: (value) {
              settingsProvider.setNotificationsEnabled(value);
            },
          ),
          // Add more settings options here
        ],
      ),
    );
  }

  Future<int?> _showNumberPicker(
      BuildContext context,
      String title,
      int currentValue,
      int minValue,
      int maxValue,
      ) async {
    return showDialog<int>(
      context: context,
      builder: (context) {
        int selectedValue = currentValue;
        return AlertDialog(
          title: Text(title),
          content: Container(
            height: 150,
            child: Column(
              children: [
                Text(title),
                DropdownButton<int>(
                  value: selectedValue,
                  items: List.generate(maxValue - minValue + 1, (index) {
                    return DropdownMenuItem<int>(
                      value: minValue + index,
                      child: Text('${minValue + index}'),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      selectedValue = value;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(selectedValue),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
