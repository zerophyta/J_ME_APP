// lib/routes/settings_routes.dart
import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/privacy_settings_screen.dart';
import '../screens/advanced_privacy_screen.dart';

final Map<String, WidgetBuilder> settingsRoutes = {
  '/settings': (context) => const SettingsScreen(),
  '/privacy': (context) => const PrivacyScreen(),
  '/privacy_settings': (context) => const PrivacySettingsScreen(),
  '/advanced_privacy': (context) => const AdvancedPrivacyScreen(),
};
