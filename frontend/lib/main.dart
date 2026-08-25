import 'package:flutter/material.dart';
import 'routes/auth_routes.dart';
import 'routes/admin_routes.dart';
import 'routes/broadcast_routes.dart';
import 'routes/call_routes.dart';
import 'routes/group_routes.dart';
import 'routes/media_routes.dart';
import 'routes/user_routes.dart';
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
    const navy = Color(0xFF0A1A2F);
    const surface = Color(0xFF102844);
    const surfaceBright = Color(0xFF17395D);
    const gold = Color(0xFFD4AF37);
    const blue = Color(0xFF3D8BFF);

    return MaterialApp(
      title: 'J_ME',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navy,
        colorScheme: const ColorScheme.dark(
          primary: blue,
          secondary: gold,
          surface: surface,
          onPrimary: Colors.white,
          onSecondary: navy,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 3,
          shadowColor: Colors.black54,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0x223D8BFF)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0x443D8BFF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: gold, width: 1.5),
          ),
          labelStyle: const TextStyle(color: Color(0xFFB8C8DB)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navy,
            elevation: 2,
            minimumSize: const Size.fromHeight(50),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? gold : Colors.white70,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? blue : Colors.white24,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        ...authRoutes,
        ...adminRoutes,
        ...broadcastRoutes,
        ...callRoutes,
        ...groupRoutes,
        ...mediaRoutes,
        ...userRoutes,
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
      {"title": "Calls", "route": "/calls"},
      {"title": "Groups", "route": "/groups"},
      {"title": "Media", "route": "/media"},
      {"title": "Admin", "route": "/admin"},
      {"title": "Broadcast", "route": "/broadcast"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("J_ME Frontend")),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) {
          final item = items[i];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              leading: CircleAvatar(
                backgroundColor: blue.withValues(alpha: 0.18),
                child: Icon(Icons.grid_view_rounded, color: gold),
              ),
              title: Text(
                item["title"]!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: gold),
              onTap: () => Navigator.pushNamed(context, item["route"]!),
            ),
          );
        },
      ),
    );
  }
}
