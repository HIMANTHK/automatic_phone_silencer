import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class LocationSetupScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  final TextEditingController _soundModeController = TextEditingController();

  LocationSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Locations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Location Name'),
            ),
            TextField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _longitudeController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _radiusController,
              decoration: const InputDecoration(labelText: 'Radius (meters)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _soundModeController,
              decoration: const InputDecoration(labelText: 'Sound Mode'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Add Location'),
              onPressed: () {
                final name = _nameController.text;
                final latitude = double.parse(_latitudeController.text);
                final longitude = double.parse(_longitudeController.text);
                final radius = double.parse(_radiusController.text);
                final soundMode = _soundModeController.text;

                final profile = LocationProfile(
                  latitude: latitude,
                  longitude: longitude,
                  radius: radius,
                  soundMode: soundMode,
                  name: name,
                );

                locationProvider.addProfile(profile);
                Navigator.of(context).pop();
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: locationProvider.profiles.length,
                itemBuilder: (context, index) {
                  final profile = locationProvider.profiles[index];
                  return ListTile(
                    title: Text(profile.name),
                    subtitle: Text('Lat: ${profile.latitude}, Lon: ${profile.longitude}, Radius: ${profile.radius}m, Mode: ${profile.soundMode}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        locationProvider.removeProfile(profile);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
