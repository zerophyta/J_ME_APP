import 'package:flutter/material.dart';
<<<<<<< HEAD

// Screens
import 'screens/login_history_screen.dart';
import 'screens/privacy_settings_screen.dart';
import 'screens/advanced_privacy_screen.dart';
import 'screens/secret_chat_screen.dart';
import 'screens/self_destruct_timer_screen.dart';
import 'screens/view_once_screen.dart';
import 'screens/disappearing_messages_screen.dart';
import 'screens/message_editing_screen.dart';
import 'screens/message_deletion_screen.dart';
import 'screens/forward_message_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/group_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/call_screen.dart';
import 'screens/broadcast_screen.dart';
=======
import 'routes/auth_routes.dart';
import 'routes/settings_routes.dart';
import 'routes/chat_routes.dart';
import 'routes/status_routes.dart';
>>>>>>> cbb6e9a07df2e223400bfb0f1d261ea30811cd7c

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
<<<<<<< HEAD
        '/login_history': (context) => const LoginHistoryScreen(),
        '/privacy_settings': (context) => const PrivacySettingsScreen(),
        '/advanced_privacy': (context) => const AdvancedPrivacyScreen(),
        '/secret_chat': (context) => const SecretChatScreen(chatId: 1, userId: 1),
        '/self_destruct_timer': (context) => const SelfDestructTimerScreen(chatId: 1),
        '/view_once': (context) => const ViewOnceScreen(chatId: 1),
        '/disappearing_messages': (context) => const DisappearingMessagesScreen(chatId: 1),
        '/message_editing': (context) => const MessageEditingScreen(
          chatId: 1,
          messageId: 44,
          originalText: "Hello team!",
        ),
        '/message_deletion': (context) => const MessageDeletionScreen(chatId: 1, messageId: 44),
        '/forward_message': (context) => const ForwardMessageScreen(messageId: 44),
        '/chats': (context) => const ChatListScreen(),
        '/groups': (context) => const GroupListScreen(),
        '/profile': (context) => const ProfileScreen(userId: 1),
        '/calls': (context) => const CallScreen(userId: 1),
        '/broadcast': (context) => const BroadcastScreen(senderId: 1),
=======
        ...authRoutes,
        ...settingsRoutes,
        ...chatRoutes,
        ...statusRoutes,
>>>>>>> cbb6e9a07df2e223400bfb0f1d261ea30811cd7c
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
<<<<<<< HEAD
      {"title": "Login History", "route": "/login_history"},
      {"title": "Privacy Settings", "route": "/privacy_settings"},
      {"title": "Advanced Privacy", "route": "/advanced_privacy"},
      {"title": "Secret Chat", "route": "/secret_chat"},
      {"title": "Self-Destruct Timer", "route": "/self_destruct_timer"},
      {"title": "View Once", "route": "/view_once"},
      {"title": "Disappearing Messages", "route": "/disappearing_messages"},
      {"title": "Message Editing", "route": "/message_editing"},
      {"title": "Message Deletion", "route": "/message_deletion"},
      {"title": "Forward Message", "route": "/forward_message"},
      {"title": "Chats", "route": "/chats"},
      {"title": "Groups", "route": "/groups"},
      {"title": "Profile", "route": "/profile"},
      {"title": "Calls", "route": "/calls"},
      {"title": "Broadcast", "route": "/broadcast"},
=======
      {"title": "Login", "route": "/login"},
      {"title": "Signup", "route": "/signup"},
      {"title": "Settings", "route": "/settings"},
      {"title": "Chat", "route": "/chat"},
      {"title": "Status", "route": "/status"},
>>>>>>> cbb6e9a07df2e223400bfb0f1d261ea30811cd7c
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
