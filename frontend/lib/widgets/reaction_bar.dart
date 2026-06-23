import 'package:flutter/material.dart';

class ReactionBar extends StatelessWidget {
  final Function(String) onReact;
  const ReactionBar({super.key, required this.onReact});

  @override
  Widget build(BuildContext context) {
    final reactions = ["🔥", "❤️", "😂", "👍", "👎", "⭐", "⭐⭐"];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.map((r) {
          return GestureDetector(
            onTap: () => onReact(r),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(r, style: const TextStyle(fontSize: 26)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
