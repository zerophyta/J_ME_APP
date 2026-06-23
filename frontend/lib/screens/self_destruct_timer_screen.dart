import 'package:flutter/material.dart';
import '../api/api_client.dart';

class SelfDestructTimerScreen extends StatefulWidget {
  final int chatId;
  const SelfDestructTimerScreen({super.key, required this.chatId});

  @override
  State<SelfDestructTimerScreen> createState() => _SelfDestructTimerScreenState();
}

class _SelfDestructTimerScreenState extends State<SelfDestructTimerScreen> {
  final ApiClient api = ApiClient();
  int selectedSeconds = 30;
  String message = "";

  Future<void> _saveTimer() async {
    bool success = await api.setSelfDestructTimer(widget.chatId, selectedSeconds);
    setState(() {
      message = success ? "Timer updated ✅" : "Update failed ❌";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Self-Destruct Timer")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Slider(
              value: selectedSeconds.toDouble(),
              min: 5,
              max: 300,
              divisions: 59,
              label: "$selectedSeconds seconds",
              onChanged: (val) => setState(() => selectedSeconds = val.toInt()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveTimer, child: const Text("Save Timer")),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
