import 'package:flutter/material.dart';
import '../screens/media_screen.dart';

final Map<String, WidgetBuilder> mediaRoutes = {
  '/media': (context) => const MediaScreen(chatId: 1, senderId: 1),
};
