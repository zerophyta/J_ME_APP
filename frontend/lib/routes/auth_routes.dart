// lib/routes/auth_routes.dart
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';

final Map<String, WidgetBuilder> authRoutes = {
  '/login': (context) => const LoginScreen(),
  '/signup': (context) => const SignupScreen(),
};
