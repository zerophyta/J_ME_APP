// lib/routes/status_routes.dart
import 'package:flutter/material.dart';
import '../screens/status_screen.dart';
import '../screens/status_upload_screen.dart';
import '../screens/status_viewer_screen.dart';
import '../screens/status_archive_screen.dart';

final Map<String, WidgetBuilder> statusRoutes = {
  '/status': (context) => const StatusScreen(),
  '/status_upload': (context) => const StatusUploadScreen(),
  '/status_viewer': (context) => const StatusViewerScreen(),
  '/status_archive': (context) => const StatusArchiveScreen(),
};
