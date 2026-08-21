import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';

final Map<String, WidgetBuilder> userRoutes = {
  '/user': (context) => const SettingsScreen(),
};
