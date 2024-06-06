import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/alarm_provider.dart';
import 'package:intl/intl.dart';
import 'location_picker_screen.dart';

class EventSetupScreen extends StatefulWidget {
  final Event? event;

  EventSetupScreen({this.event});

  @override
  _EventSetupScreenState createState() => _EventSetupScreenState();
}

class _EventSetupScreenState extends State<EventSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _eventName = '';
  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _customMessage = '';
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _eventName = widget.event!.eventName;
      _eventDate = widget.event!.eventDate;
      _startTime = widget.event!.startTime;
      _endTime = widget.event!.endTime;
      _customMessage = widget.event!.customMessage;
      _latitude = widget.event!.latitude;
      _longitude = widget.event!.longitude;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alarmProvider = Provider.of<AlarmProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Set Up Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _eventName,
                decoration: InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _eventName = value!;
                },
              ),
              ListTile(
                title: Text(_eventDate == null ? 'Event Date' : DateFormat.yMd().format(_eventDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text(_startTime == null ? 'Event Start Time' : _startTime!.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: () => _pickTime(isStartTime: true),
              ),
              ListTile(
                title: Text(_endTime == null ? 'Event End Time' : _endTime!.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: () => _pickTime(isStartTime: false),
              ),
              if (_startTime != null && _endTime != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Duration: ${_endTime!.hour - _startTime!.hour} hours and ${_endTime!.minute - _startTime!.minute} minutes',
                  ),
                ),
              TextFormField(
                initialValue: _customMessage,
                decoration: InputDecoration(labelText: 'Custom Message'),
                onSaved: (value) {
                  _customMessage = value!;
                },
              ),
              ListTile(
                title: Text('Event Location'),
                subtitle: _latitude == null || _longitude == null
                    ? Text('No location selected')
                    : Text('Lat: $_latitude, Lng: $_longitude'),
                trailing: Icon(Icons.map),
                onTap: () async {
                  final location = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationPickerScreen(),
                    ),
                  );
                  if (location != null) {
                    setState(() {
                      _latitude = location.latitude;
                      _longitude = location.longitude;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (widget.event == null) {
                      alarmProvider.addEvent(
                        _eventName,
                        _eventDate!,
                        _startTime!,
                        _endTime!,
                        _customMessage,
                        _latitude,
                        _longitude,
                      );
                    } else {
                      alarmProvider.updateEvent(
                        widget.event!,
                        _eventName,
                        _eventDate!,
                        _startTime!,
                        _endTime!,
                        _customMessage,
                        _latitude,
                        _longitude,
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.event == null ? 'Add Event' : 'Update Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _eventDate) {
      setState(() {
        _eventDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }
}
