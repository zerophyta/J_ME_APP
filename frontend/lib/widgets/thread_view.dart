import 'package:flutter/material.dart';

class ThreadView extends StatelessWidget {
  final String threadTitle;
  final List<Map<String, String>> replies;
  const ThreadView({super.key, required this.threadTitle, required this.replies});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      color: Colors.black.withOpacity(0.85),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(threadTitle,
                style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: replies.length,
              itemBuilder: (_, i) {
                final reply = replies[i];
                return ListTile(
                  title: Text(reply["user"]!, style: const TextStyle(color: Colors.white70)),
                  subtitle: Text(reply["text"]!, style: const TextStyle(color: Colors.white)),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Reply in thread...",
                hintStyle: TextStyle(color: Colors.white54),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
