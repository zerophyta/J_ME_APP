import 'package:flutter/material.dart';
import '../api/api_client.dart';

class StatusArchiveScreen extends StatefulWidget {
  const StatusArchiveScreen({super.key});

  @override
  State<StatusArchiveScreen> createState() => _StatusArchiveScreenState();
}

class _StatusArchiveScreenState extends State<StatusArchiveScreen> {
  final ApiClient api = ApiClient();
  List<dynamic> archivedStatuses = [];

  @override
  void initState() {
    super.initState();
    _loadArchivedStatuses();
  }

  Future<void> _loadArchivedStatuses() async {
    final data = await api.getArchivedStatuses();
    setState(() {
      archivedStatuses = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F), // dark blue
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1A2F),
        elevation: 0,
        title: const Text("Status Archive", style: TextStyle(color: Colors.white)),
      ),
      body: archivedStatuses.isEmpty
          ? const Center(child: Text("No archived statuses yet", style: TextStyle(color: Colors.white70)))
          : ListView.builder(
              itemCount: archivedStatuses.length,
              itemBuilder: (_, i) {
                final status = archivedStatuses[i];
                return Card(
                  color: const Color(0xFFD4AF37), // gold accent
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(status["user"], style: const TextStyle(color: Colors.white)),
                    subtitle: Text(status["content"], style: const TextStyle(color: Colors.white70)),
                    trailing: Text("Expired: ${status["expiredAt"]}", style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
    );
  }
}
