import 'package:flutter/material.dart';
import '../api/api_client.dart';

class ViewOnceScreen extends StatefulWidget {
  final int chatId;
  const ViewOnceScreen({super.key, required this.chatId});

  @override
  State<ViewOnceScreen> createState() => _ViewOnceScreenState();
}

class _ViewOnceScreenState extends State<ViewOnceScreen> {
  final ApiClient api = ApiClient();
  String message = "";
  bool includeCaption = false;
  final captionController = TextEditingController();

  Future<void> _sendViewOnce(String filePath) async {
    bool success = await api.sendViewOnce(widget.chatId, filePath, includeCaption ? captionController.text : null);
    setState(() {
      message = success ? "Sent as View Once ✅" : "Failed ❌";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send View Once")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Include Caption"),
              value: includeCaption,
              onChanged: (val) => setState(() => includeCaption = val),
            ),
            if (includeCaption)
              TextField(
                controller: captionController,
                decoration: const InputDecoration(hintText: "Enter caption..."),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendViewOnce("/path/to/file.jpg"),
              child: const Text("Send View Once"),
            ),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
