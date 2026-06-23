import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api_client.dart';

class MediaScreen extends StatefulWidget {
  final int chatId;
  final int senderId;

  const MediaScreen({super.key, required this.chatId, required this.senderId});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final ApiClient api = ApiClient();
  File? _selectedFile;
  String message = "";

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedFile = File(picked.path);
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;
    bool success = await api.uploadMedia(
      widget.chatId,
      widget.senderId,
      _selectedFile!,
      "image", // type: image, video, audio, doc
    );
    setState(() {
      message = success ? "Upload successful ✅" : "Upload failed ❌";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Media")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pickFile, child: const Text("Pick File")),
            if (_selectedFile != null) Image.file(_selectedFile!, height: 200),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _uploadFile, child: const Text("Upload")),
            Text(message)
          ],
        ),
      ),
    );
  }
}
