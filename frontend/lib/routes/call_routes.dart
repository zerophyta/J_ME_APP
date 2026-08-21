import 'package:flutter/material.dart';
import '../screens/call_screen.dart';

final Map<String, WidgetBuilder> callRoutes = {
  '/calls': (context) => const CallScreen(),
};