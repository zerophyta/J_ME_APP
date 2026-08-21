import 'package:flutter/material.dart';
import '../api/api_client.dart';

class CallScreen extends StatefulWidget {
  final int userId;
  const CallScreen({super.key, this.userId = 1});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final ApiClient _api = ApiClient();
  final _calleeController = TextEditingController();
  List<dynamic> _history = [];
  int? _activeCallId;
  String _callType = 'voice';
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _api.getCallHistory(widget.userId);
      if (mounted) setState(() => _history = history);
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    }
  }

  Future<void> _toggleCall() async {
    try {
      if (_activeCallId == null) {
        final calleeId = int.tryParse(_calleeController.text);
        if (calleeId == null) {
          setState(() => _message = 'Enter a valid callee ID');
          return;
        }
        final call = await _api.startCall(widget.userId, calleeId, _callType);
        setState(() {
          _activeCallId = call['id'] as int?;
          _message = 'Call started';
        });
      } else {
        await _api.endCall(_activeCallId!);
        setState(() {
          _activeCallId = null;
          _message = 'Call ended';
        });
        await _loadHistory();
      }
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calls')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(
            controller: _calleeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Callee user ID'),
          ),
          DropdownButton<String>(
            value: _callType,
            items: const [
              DropdownMenuItem(value: 'voice', child: Text('Voice')),
              DropdownMenuItem(value: 'video', child: Text('Video')),
            ],
            onChanged: (value) => setState(() => _callType = value ?? 'voice'),
          ),
          ElevatedButton(
            onPressed: _toggleCall,
            child: Text(_activeCallId == null ? 'Start call' : 'End call'),
          ),
          if (_message != null) Text(_message!),
          const SizedBox(height: 12),
          const Text('Call history'),
          Expanded(
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final call = _history[index] as Map<String, dynamic>;
                return ListTile(
                  title: Text('${call['call_type']} call'),
                  subtitle: Text('Status: ${call['status']}'),
                  trailing: Text('#${call['id']}'),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}