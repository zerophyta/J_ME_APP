import 'package:flutter/material.dart';
import '../api/api_client.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiClient _api = ApiClient();
  final _broadcastController = TextEditingController();
  final _userIdController = TextEditingController();
  final _notificationController = TextEditingController();
  List<dynamic> _users = [];
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _api.getAdminUsers();
      if (mounted) setState(() => _users = users);
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    }
  }

  Future<void> _broadcast() async {
    final content = _broadcastController.text.trim();
    if (content.isEmpty) return;
    try {
      final result = await _api.adminBroadcast(content);
      if (mounted) {
        setState(
            () => _message = result['status']?.toString() ?? 'Broadcast sent');
      }
      _broadcastController.clear();
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    }
  }

  Future<void> _notifyUser() async {
    final userId = int.tryParse(_userIdController.text.trim());
    final content = _notificationController.text.trim();
    if (userId == null || content.isEmpty) return;
    try {
      final result = await _api.notifyUser(userId, content);
      if (mounted) {
        setState(() =>
            _message = result['message']?.toString() ?? 'Notification sent');
      }
      _notificationController.clear();
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    }
  }

  @override
  void dispose() {
    _broadcastController.dispose();
    _userIdController.dispose();
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              controller: _broadcastController,
              decoration:
                  const InputDecoration(labelText: 'Broadcast message')),
          ElevatedButton(
              onPressed: _broadcast, child: const Text('Broadcast to users')),
          const SizedBox(height: 16),
          TextField(
              controller: _userIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'User ID')),
          TextField(
              controller: _notificationController,
              decoration: const InputDecoration(labelText: 'Notification')),
          ElevatedButton(
              onPressed: _notifyUser, child: const Text('Notify user')),
          if (_message != null)
            Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_message!)),
          const SizedBox(height: 16),
          const Text('Users'),
          ..._users.map((user) => ListTile(
              title: Text('${user['username']}'),
              trailing: Text('#${user['id']}'))),
        ],
      ),
    );
  }
}
