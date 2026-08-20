import 'package:flutter/material.dart';

class ReplyBubble extends StatelessWidget {
  final String repliedText;
  final String replyText;
  const ReplyBubble({super.key, required this.repliedText, required this.replyText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(repliedText,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          const SizedBox(height: 6),
          Text(replyText, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
