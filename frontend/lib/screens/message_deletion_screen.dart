import 'package:flutter/material.dart';
import '../api/api_client.dart';

class MessageDeletionScreen extends StatefulWidget {
  final int chatId;
  final int messageId;
  const MessageDeletionScreen({super.key, required this.chatId, required this.messageId});

  @override
  State<MessageDeletionScreen> createState() => _MessageDeletionScreenState();
}

class _MessageDeletionScreenState extends State<MessageDeletionScreen> {
  final ApiClient api = ApiClient();
  String message = "";

  Future<void> _deleteForMe() async {
    bool success = await api.deleteMessageForMe(widget.chatId, widget.messageId);
    setState(() => message = success ? "Deleted for me ✅" : "Failed ❌");
  }

  Future<void> _deleteForEveryone() async {
    bool success = await api.deleteMessageForEveryone(widget.chatId, widget.messageId);
    setState(() => message = success ? "Deleted for everyone ✅" : "Failed ❌");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delete Message")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: _deleteForMe, child: const Text("Delete for Me")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _deleteForEveryone, child: const Text("Delete for Everyone")),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
