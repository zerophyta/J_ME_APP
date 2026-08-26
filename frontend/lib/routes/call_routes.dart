import 'package:flutter/material.dart';
import '../screens/call_screen.dart';
import '../screens/group_call_screen.dart';

final Map<String, WidgetBuilder> callRoutes = {
  '/calls': (context) => const CallScreen(),
  '/group_call': (context) => const GroupCallScreen(groupId: 1, userId: 1),
};