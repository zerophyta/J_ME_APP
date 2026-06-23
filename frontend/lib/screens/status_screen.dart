import 'package:flutter/material.dart';
import '../api/api_client.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final ApiClient api = ApiClient();
  List<dynamic> statuses = [];

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    final data = await api.getStatuses();
    setState(() {
      statuses = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Status")),
      body: ListView.builder(
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: status["isMine"] ? const Color(0xFFD4AF37) : const Color(0xFF0A1A2F),
              child: const Icon(Icons.circle, color: Colors.white),
            ),
            title: Text(status["user"]),
            subtitle: Text(status["content"]),
            onTap: () => Navigator.pushNamed(context, "/status_viewer", arguments: status),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, "/status_upload"),
        child: const Icon(Icons.add),
      ),
    );
  }
}
