import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/group_chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'J_ME Frontend',
      routes: {
        "/": (context) => const LoginScreen(),
        "/signup": (context) => const SignupScreen(),
        "/chat": (context) => const ChatScreen(),
        "/group": (context) => const GroupChatScreen(
              groupId: 1,
              userId: 1,
              members: [1, 2, 3],
            ),
           "/media": (context) => const MediaScreen(chatId: 1, senderId: 1), 
            "/privacy": (context) => const PrivacyScreen(),
            "/secret": (context) => const SecretChatScreen(chatId: 1, userId: 1),
            "/settings": (context) => const SettingsScreen(), 
            "/appearance": (context) => const AppearanceScreen(),
            "/dashboard": (context) => const DashboardScreen(),

      },
      routes: {
  "/": (context) => const OnboardingScreen(),
  "/dashboard": (context) => const DashboardScreen(),
  "/status": (context) => const StatusScreen(),
  "/status_upload": (context) => const StatusUploadScreen(),
  "/status_viewer": (context) => const StatusViewerScreen(),
}
routes: {
  "/status": (context) => const StatusScreen(),
  "/status_upload": (context) => const StatusUploadScreen(),
  "/status_viewer": (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return StatusViewerScreen(status: args);
  },
    "/status_archive": (context) => const StatusArchiveScreen(), 
    "/storage": (context) => const StorageScreen(),
}
routes: {
  "/chat_backup": (context) => const ChatBackupScreen(),
  "/chat_restore": (context) => const ChatRestoreScreen(),
  "/chat_export": (context) => const ChatExportScreen(chatId: 1),
  "/chat_info": (context) => const ChatInfoScreen(chatId: 1),
  "/chat_security": (context) => const ChatSecurityScreen(chatId: 1),
  "/device_security": (context) => const DeviceSecurityScreen(),
  "/account_security": (context) => const AccountSecurityScreen(),
  "/login_history": (context) => const LoginHistoryScreen(),
  "/privacy_settings": (context) => const PrivacySettingsScreen(),  
  "/advanced_privacy": (context) => const AdvancedPrivacyScreen(),
  "/secret_chat": (context) => const SecretChatScreen(chatId: 1, userId: 1),
  "/self_destruct_timer": (context) => const SelfDestructTimerScreen(chatId: 1),
  "/view_once": (context) => const ViewOnceScreen(chatId: 1),
  "/disappearing_messages": (context) => const DisappearingMessagesScreen(chatId: 1),
  "/message_deletion": (context) => const MessageDeletionScreen(chatId: 1, messageId: 44),
  "/forward_message": (context) => const ForwardMessageScreen(messageId: 44),

}
routes: {
  "/message_editing": (context) => const MessageEditingScreen(
        chatId: 1,
        messageId: 44,
        originalText: "Hello team!",
      ),
}

    );
  }
}













