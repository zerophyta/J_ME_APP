import 'package:flutter/material.dart';
import '../api/api_client.dart';

class StatusViewerScreen extends StatefulWidget {
  final Map<String, dynamic> status;
  const StatusViewerScreen({super.key, required this.status});

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen> {
  final ApiClient api = ApiClient();
  List<dynamic> viewers = [];

  @override
  void initState() {
    super.initState();
    _loadViewers();
  }

  Future<void> _loadViewers() async {
    final data = await api.getStatusViewers(widget.status["id"]);
    setState(() {
      viewers = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F), // dark blue
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1A2F),
        elevation: 0,
        title: Text(
          "Viewed by ${viewers.length}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: viewers.length,
        itemBuilder: (_, i) {
          final v = viewers[i];
          return ListTile(
            leading: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(v["avatar"]),
            ),
            title: Text(v["name"], style: const TextStyle(color: Colors.white)),
            subtitle: Text("@${v["username"]} • Viewed at ${v["viewedAt"]}",
                style: const TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.visibility, color: Color(0xFFD4AF37)), // gold accent
          );
        },
      ),
    );
  }
}
