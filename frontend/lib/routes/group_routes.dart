import 'package:flutter/material.dart';
import '../screens/group_chat_screen.dart';

final Map<String, WidgetBuilder> groupRoutes = {
  '/groups': (context) => const GroupChatScreen(
        groupId: 1,
        userId: 1,
        members: [1],
      ),
};
