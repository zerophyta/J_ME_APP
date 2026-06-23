import 'package:flutter/material.dart';
import '../api/api_client.dart';

class DisappearingMessagesScreen extends StatefulWidget {
  final int chatId;
  const DisappearingMessagesScreen({super.key, required this.chatId});

  @override
  State<DisappearingMessagesScreen> createState() => _DisappearingMessagesScreenState();
}

class _DisappearingMessagesScreenState extends State<DisappearingMessagesScreen> {
  final ApiClient api = ApiClient();
  int selectedDuration = 86400; // default 24h in seconds
  String message = "";

  Future<void> _saveDuration() async {
    bool success = await api.setDisappearingMessages(widget.chatId, selectedDuration);
    setState(() {
      message = success ? "Disappearing messages updated ✅" : "Update failed ❌";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Disappearing Messages")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<int>(
              value: selectedDuration,
              items: const [
                DropdownMenuItem(value: 300, child: Text("5 minutes")),
                DropdownMenuItem(value: 3600, child: Text("1 hour")),
                DropdownMenuItem(value: 86400, child: Text("24 hours")),
                DropdownMenuItem(value: 604800, child: Text("1 week")),
              ],
              onChanged: (val) => setState(() => selectedDuration = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveDuration, child: const Text("Save")),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
