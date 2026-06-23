import 'package:flutter/material.dart';

class ThreadPreview extends StatelessWidget {
  final String parentText;
  final String replyText;
  const ThreadPreview({super.key, required this.parentText, required this.replyText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(parentText, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(replyText, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
