import 'package:flutter/material.dart';
import '../api/api_client.dart';

class ChatBackupScreen extends StatefulWidget {
  const ChatBackupScreen({super.key});

  @override
  State<ChatBackupScreen> createState() => _ChatBackupScreenState();
}

class _ChatBackupScreenState extends State<ChatBackupScreen> {
  final ApiClient api = ApiClient();
  String message = "";
  bool autoBackup = false;

  Future<void> _backupChats() async {
    bool success = await api.backupChats();
    setState(() {
      message = success ? "Backup successful ✅" : "Backup failed ❌";
    });
  }

  Future<void> _toggleAutoBackup(bool val) async {
    bool success = await api.setAutoBackup(val);
    if (success) {
      setState(() => autoBackup = val);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Backup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: _backupChats, child: const Text("Backup Now")),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Enable Auto Backup"),
              value: autoBackup,
              onChanged: _toggleAutoBackup,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/chat_restore"),
              child: const Text("Restore Backup"),
            ),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
