import 'package:flutter/material.dart';
import '../api/api_client.dart';

class BroadcastScreen extends StatefulWidget {
  final int senderId;
  const BroadcastScreen({super.key, this.senderId = 1});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final ApiClient _api = ApiClient();
  final _contentController = TextEditingController();
  final _recipientsController = TextEditingController();
  String? _message;

  Future<void> _send() async {
    final content = _contentController.text.trim();
    final recipients = _recipientsController.text
        .split(',')
        .map((value) => int.tryParse(value.trim()))
        .whereType<int>()
        .toList();
    if (content.isEmpty || recipients.isEmpty) {
      setState(() => _message = 'Enter a message and recipient IDs');
      return;
    }
    try {
      final result = await _api.sendBroadcast(widget.senderId, content, recipients);
      setState(() => _message = result['message']?.toString() ?? 'Broadcast sent');
      _contentController.clear();
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Broadcast')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(
            controller: _recipientsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Recipient IDs, comma separated'),
          ),
          TextField(
            controller: _contentController,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _send, child: const Text('Send broadcast')),
          if (_message != null) Text(_message!),
        ]),
      ),
    );
  }
}