import 'package:flutter/material.dart';
import '../api/api_client.dart';

class ChatExportScreen extends StatefulWidget {
  final int chatId;
  const ChatExportScreen({super.key, required this.chatId});

  @override
  State<ChatExportScreen> createState() => _ChatExportScreenState();
}

class _ChatExportScreenState extends State<ChatExportScreen> {
  final ApiClient api = ApiClient();
  String message = "";
  String selectedFormat = "JSON";
  bool includeMedia = true;

  Future<void> _exportChat() async {
    bool success = await api.exportChat(widget.chatId, selectedFormat, includeMedia);
    setState(() {
      message = success ? "Export successful ✅" : "Export failed ❌";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Export Chat")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedFormat,
              items: ["JSON", "TXT", "ZIP"].map((format) {
                return DropdownMenuItem(value: format, child: Text(format));
              }).toList(),
              onChanged: (val) => setState(() => selectedFormat = val!),
            ),
            SwitchListTile(
              title: const Text("Include Media"),
              value: includeMedia,
              onChanged: (val) => setState(() => includeMedia = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _exportChat, child: const Text("Export")),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
