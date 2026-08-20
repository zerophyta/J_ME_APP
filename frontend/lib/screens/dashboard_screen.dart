import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("J_ME Dashboard"),
        backgroundColor: const Color(0xFF0A1A2F), // dark blue
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(context, "Chats", Icons.chat, "/chats"),
          _buildCard(context, "Groups", Icons.group, "/groups"),
          _buildCard(context, "Profile", Icons.person, "/profile"),
          _buildCard(context, "Calls", Icons.call, "/calls"),
          _buildCard(context, "Broadcast", Icons.campaign, "/broadcast"),
          _buildCard(context, "Status", Icons.circle, "/media"),
          _buildCard(context, "Privacy", Icons.lock, "/privacy"),
          _buildCard(context, "Secret Chat", Icons.shield, "/secret"),
          _buildCard(context, "Settings", Icons.settings, "/settings"),
          _buildCard(context, "Appearance", Icons.color_lens, "/appearance"),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        color: const Color(0xFFD4AF37), // gold
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
