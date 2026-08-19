import 'package:flutter/material.dart';
import 'routes/auth_routes.dart';
import 'routes/settings_routes.dart';
import 'routes/chat_routes.dart';
import 'routes/status_routes.dart';

void main() {
  runApp(const JMeApp());
}

class JMeApp extends StatelessWidget {
  const JMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'J_ME',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0A1A2F),
        scaffoldBackgroundColor: const Color(0xFF0A1A2F),
        colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark)
            .copyWith(secondary: const Color(0xFFD4AF37)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        ...authRoutes,
        ...settingsRoutes,
        ...chatRoutes,
        ...statusRoutes,
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {"title": "Login", "route": "/login"},
      {"title": "Signup", "route": "/signup"},
      {"title": "Settings", "route": "/settings"},
      {"title": "Chat", "route": "/chat"},
      {"title": "Status", "route": "/status"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("J_ME Frontend")),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return ListTile(
            title: Text(item["title"]!),
            trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37)),
            onTap: () => Navigator.pushNamed(context, item["route"]!),
          );
        },
      ),
    );
  }
}
