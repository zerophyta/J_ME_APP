import 'package:flutter/material.dart';
import '../api/api_client.dart';

class StatusUploadScreen extends StatefulWidget {
  const StatusUploadScreen({super.key});

  @override
  State<StatusUploadScreen> createState() => _StatusUploadScreenState();
}

class _StatusUploadScreenState extends State<StatusUploadScreen> {
  final ApiClient api = ApiClient();
  final controller = TextEditingController();
  String message = "";

  Future<void> _uploadStatus() async {
    bool success = await api.uploadStatus(controller.text);
    setState(() {
      message = success ? "Status uploaded ✅" : "Upload failed ❌";
    });
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Status")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: controller, decoration: const InputDecoration(hintText: "Type your status...")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _uploadStatus, child: const Text("Post")),
            Text(message)
          ],
        ),
      ),
    );
  }
}
