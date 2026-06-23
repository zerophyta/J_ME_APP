import 'package:flutter/material.dart';
import '../api/api_client.dart';

class MessageEditingScreen extends StatefulWidget {
  final int chatId;
  final int messageId;
  final String originalText;
  const MessageEditingScreen({
    super.key,
    required this.chatId,
    required this.messageId,
    required this.originalText,
  });

  @override
  State<MessageEditingScreen> createState() => _MessageEditingScreenState();
}

class _MessageEditingScreenState extends State<MessageEditingScreen> {
  final ApiClient api = ApiClient();
  late TextEditingController controller;
  String message = "";

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.originalText);
  }

  Future<void> _saveEdit() async {
    bool success = await api.editMessage(widget.chatId, widget.messageId, controller.text);
    setState(() {
      message = success ? "Message updated ✅" : "Update failed ❌";
    });
    if (success) Navigator.pop(context, controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Message")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: null,
              decoration: const InputDecoration(labelText: "Edit message"),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                const Spacer(),
                ElevatedButton(onPressed: _saveEdit, child: const Text("Save")),
              ],
            ),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
