import 'package:flutter/material.dart';

class ReactionRow extends StatelessWidget {
  final Map<String, int> reactions;
  const ReactionRow({super.key, required this.reactions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: reactions.entries.map((e) {
        return Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text("${e.key} ${e.value}",
              style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }
}
