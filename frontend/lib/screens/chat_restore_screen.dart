import 'package:flutter/material.dart';
import '../api/api_client.dart';

class ChatRestoreScreen extends StatefulWidget {
  const ChatRestoreScreen({super.key});

  @override
  State<ChatRestoreScreen> createState() => _ChatRestoreScreenState();
}

class _ChatRestoreScreenState extends State<ChatRestoreScreen> {
  final ApiClient api = ApiClient();
  String message = "";

  Future<void> _restoreChats() async {
    bool success = await api.restoreChats();
    setState(() {
      message = success ? "Restore successful ✅" : "Restore failed ❌";
    });
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restore Chats")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _restoreChats, child: const Text("Restore Backup")),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
