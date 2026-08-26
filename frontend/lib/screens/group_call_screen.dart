import 'package:flutter/material.dart';
import '../api/api_client.dart';

class GroupCallScreen extends StatefulWidget {
  final int groupId;
  final int userId;
  final String initialCallType;

  const GroupCallScreen({
    super.key,
    required this.groupId,
    required this.userId,
    this.initialCallType = 'group_voice',
  });

  @override
  State<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  final ApiClient _api = ApiClient();
  final TextEditingController _callIdController = TextEditingController();
  int? _activeCallId;
  String _callType = 'group_voice';
  String? _message;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _callType = widget.initialCallType;
  }

  Future<void> _startCall() async {
    await _run(() async {
      final call = await _api.startGroupCall(
        widget.userId,
        widget.groupId,
        _callType,
      );
      final callId = call['id'];
      if (callId is! int) throw Exception('Backend returned no call ID');
      setState(() {
        _activeCallId = callId;
        _callIdController.text = callId.toString();
        _message = 'Group call started';
      });
    });
  }

  Future<void> _joinCall() async {
    final callId = int.tryParse(_callIdController.text.trim());
    if (callId == null) {
      setState(() => _message = 'Enter a valid group call ID');
      return;
    }
    await _run(() async {
      await _api.joinGroupCall(callId, widget.userId);
      setState(() {
        _activeCallId = callId;
        _message = 'Joined group call #$callId';
      });
    });
  }

  Future<void> _leaveCall() async {
    final callId = _activeCallId;
    if (callId == null) return;
    await _run(() async {
      await _api.leaveGroupCall(callId, widget.userId);
      setState(() {
        _activeCallId = null;
        _message = 'Left group call #$callId';
      });
    });
  }

  Future<void> _endCall() async {
    final callId = _activeCallId;
    if (callId == null) return;
    await _run(() async {
      await _api.endGroupCall(callId, widget.userId);
      setState(() {
        _activeCallId = null;
        _message = 'Group call #$callId ended';
      });
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _message = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    _callIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveCall = _activeCallId != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Group Call')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Group #${widget.groupId}'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _callType,
              decoration: const InputDecoration(labelText: 'Call type'),
              items: const [
                DropdownMenuItem(
                  value: 'group_voice',
                  child: Text('Group voice'),
                ),
                DropdownMenuItem(
                  value: 'group_video',
                  child: Text('Group video'),
                ),
              ],
              onChanged: hasActiveCall
                  ? null
                  : (value) => setState(() => _callType = value ?? 'group_voice'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _callIdController,
              enabled: !hasActiveCall,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Existing call ID',
                hintText: 'Share the ID with group members',
              ),
            ),
            const SizedBox(height: 16),
            if (!hasActiveCall) ...[
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _startCall,
                icon: const Icon(Icons.add_call),
                label: const Text('Start group call'),
              ),
              OutlinedButton.icon(
                onPressed: _isBusy ? null : _joinCall,
                icon: const Icon(Icons.phone_in_talk),
                label: const Text('Join group call'),
              ),
            ] else ...[
              Text('Active call #$_activeCallId', textAlign: TextAlign.center),
              OutlinedButton.icon(
                onPressed: _isBusy ? null : _leaveCall,
                icon: const Icon(Icons.call_end),
                label: const Text('Leave call'),
              ),
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _endCall,
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('End call'),
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}