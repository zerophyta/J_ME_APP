// lib/routes/status_routes.dart
import 'package:flutter/material.dart';
import '../screens/status_screen.dart';
import '../screens/status_upload_screen.dart';
import '../screens/status_viewer_screen.dart';
import '../screens/status_archive_screen.dart';

final Map<String, WidgetBuilder> statusRoutes = {
  '/status': (context) => const StatusScreen(),
  '/status_upload': (context) => const StatusUploadScreen(),
  '/status_viewer': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final status = args is Map<String, dynamic>
        ? args
        : {'id': 1, 'user': 'Unknown', 'content': '', 'isMine': false};
    return StatusViewerScreen(status: status);
  },
  '/status_archive': (context) => const StatusArchiveScreen(),
};
