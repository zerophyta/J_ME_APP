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
    if (mounted) {
      setState(() => statuses = data);
    }
  }

  Future<void> _openUpload() async {
    await Navigator.pushNamed(context, "/status_upload");
    _loadStatuses();
  }

  Widget _statusRing(Map<String, dynamic> status) {
    final isMine = status["isMine"] == true;
    final ringColor = isMine ? const Color(0xFF0A1A2F) : const Color(0xFFD4AF37);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/status_viewer", arguments: status),
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ringColor,
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF17395D)),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF102844),
                  child: Icon(
                    isMine ? Icons.person_rounded : Icons.person_outline_rounded,
                    size: 30,
                    color: isMine ? const Color(0xFFD4AF37) : Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status["user"]?.toString() ?? "Status",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isMine ? const Color(0xFFD4AF37) : Colors.white,
                fontWeight: isMine ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Status")),
      body: RefreshIndicator(
        onRefresh: _loadStatuses,
        color: const Color(0xFFD4AF37),
        backgroundColor: const Color(0xFF102844),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            const Text(
              "Your cycle",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              "Share a moment and see what is new",
              style: TextStyle(color: Color(0xFFB8C8DB)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 132,
              child: statuses.isEmpty
                  ? const Center(child: Text("No active statuses yet"))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: statuses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (_, index) => _statusRing(statuses[index]),
                    ),
            ),
            const SizedBox(height: 18),
            ...statuses.map(
              (status) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(status["user"]?.toString() ?? "Status"),
                  subtitle: Text(
                    status["content"]?.toString() ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFD4AF37)),
                  onTap: () => Navigator.pushNamed(context, "/status_viewer", arguments: status),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: const Color(0xFF0A1A2F),
        onPressed: _openUpload,
        child: const Icon(Icons.add),
      ),
    );
  }
}
