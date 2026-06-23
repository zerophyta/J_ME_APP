import 'package:flutter/material.dart';

class ReplyPreview extends StatelessWidget {
  final String repliedText;
  const ReplyPreview({super.key, required this.repliedText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        repliedText,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
