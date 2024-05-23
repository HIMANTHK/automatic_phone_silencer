import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import 'event_setup_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Automatic Phone Silencer'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Current'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: Column(
          children: [
            DeviceStatus(),
            Expanded(
              child: TabBarView(
                children: [
                  EventList(isUpcoming: true),
                  EventList(isCurrent: true),
                  EventList(isUpcoming: false),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventSetupScreen()),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class DeviceStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alarmProvider = Provider.of<AlarmProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Current Device Status: ${alarmProvider.deviceStatus}',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class EventList extends StatelessWidget {
  final bool isUpcoming;
  final bool isCurrent;

  EventList({this.isUpcoming = false, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    final alarmProvider = Provider.of<AlarmProvider>(context);
    final now = DateTime.now();
    final events = alarmProvider.events.where((event) {
      final startDateTime = DateTime(
        event.eventDate.year,
        event.eventDate.month,
        event.eventDate.day,
        event.startTime.hour,
        event.startTime.minute,
      );
      final endDateTime = DateTime(
        event.eventDate.year,
        event.eventDate.month,
        event.eventDate.day,
        event.endTime.hour,
        event.endTime.minute,
      );

      if (isUpcoming) {
        return startDateTime.isAfter(now);
      } else if (isCurrent) {
        return startDateTime.isBefore(now) && endDateTime.isAfter(now);
      } else {
        return endDateTime.isBefore(now);
      }
    }).toList();

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final startDateTime = DateTime(
          event.eventDate.year,
          event.eventDate.month,
          event.eventDate.day,
          event.startTime.hour,
          event.startTime.minute,
        );
        final endDateTime = DateTime(
          event.eventDate.year,
          event.eventDate.month,
          event.eventDate.day,
          event.endTime.hour,
          event.endTime.minute,
        );

        return ListTile(
          title: Text(event.eventName),
          subtitle: Text(
            'Date: ${DateFormat.yMd().format(event.eventDate)}\n'
                'Start: ${event.startTime.format(context)}\n'
                'End: ${event.endTime.format(context)}\n'
                'Duration: ${endDateTime.difference(startDateTime).inHours} hours and ${endDateTime.difference(startDateTime).inMinutes % 60} minutes',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventSetupScreen(event: event)),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => alarmProvider.removeEvent(event),
              ),
            ],
          ),
        );
      },
    );
  }
}
