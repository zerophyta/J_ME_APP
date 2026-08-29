// lib/routes/chat_routes.dart
import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';
import '../screens/group_chat_screen.dart';
import '../screens/secret_chat_screen.dart';
import '../screens/message_editing_screen.dart';
import '../screens/message_deletion_screen.dart';
import '../screens/forward_message_screen.dart';

final Map<String, WidgetBuilder> chatRoutes = {
  '/chat': (context) => const ChatScreen(
        chatId: 1,
        receiverId: 1,
        senderId: 2,
  ),
  '/group_chat': (context) => const GroupChatScreen(
        groupId: 1,
        userId: 1,
        members: [1],
      ),
  '/secret_chat': (context) => const SecretChatScreen(chatId: 1, userId: 1),
  '/message_editing': (context) => const MessageEditingScreen(
        chatId: 1,
        messageId: 44,
        originalText: "Hello team!",
      ),
  '/message_deletion': (context) =>
      const MessageDeletionScreen(chatId: 1, messageId: 44),
  '/forward_message': (context) => const ForwardMessageScreen(messageId: 44),
};
