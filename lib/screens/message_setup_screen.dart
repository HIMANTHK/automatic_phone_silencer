import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';

class MessageSetupScreen extends StatelessWidget {
  final TextEditingController _messageController = TextEditingController();

  MessageSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context);
    _messageController.text = messageProvider.message; // Pre-fill with existing message

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Messages'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Auto Reply Message'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Save Message'),
              onPressed: () {
                final message = _messageController.text;
                messageProvider.updateMessage(message);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
