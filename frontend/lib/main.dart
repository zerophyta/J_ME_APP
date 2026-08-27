import 'package:flutter/material.dart';
import 'routes/auth_routes.dart';
import 'routes/admin_routes.dart';
import 'routes/broadcast_routes.dart';
import 'routes/call_routes.dart';
import 'routes/group_routes.dart';
import 'routes/media_routes.dart';
import 'routes/user_routes.dart';
import 'routes/settings_routes.dart';
import 'routes/chat_routes.dart';
import 'routes/status_routes.dart';

const gold = Color(0xFFD4AF37);
const blue = Color(0xFF3D8BFF);

void main() {
  runApp(const JMeApp());
}

/// Simple in-memory auth service for demo purposes.
/// Replace with your real auth provider (secure storage, token checks, API).
class AuthService extends ChangeNotifier {
  bool _loggedIn = false;
  String? _username;
  int? _userId;

  bool get isLoggedIn => _loggedIn;
  String get username => _username ?? 'User';
  int get userId => _userId ?? 1;

  Future<void> login({required String username, required int userId}) async {
    // simulate network/auth delay
    await Future.delayed(const Duration(milliseconds: 400));
    _loggedIn = true;
    _username = username;
    _userId = userId;
    notifyListeners();
  }

  Future<void> logout() async {
    _loggedIn = false;
    _username = null;
    _userId = null;
    notifyListeners();
  }
}

class JMeApp extends StatefulWidget {
  const JMeApp({super.key});

  @override
  State<JMeApp> createState() => _JMeAppState();
}

class _JMeAppState extends State<JMeApp> {
  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0A1A2F);
    const surface = Color(0xFF102844);
    const surfaceBright = Color(0xFF17395D);

    // Classify routes
    // publicRoutes: login, signup, password reset, etc.
    final Map<String, WidgetBuilder> publicRoutes = {
      ...authRoutes, // keep your auth routes here
      // If your authRoutes map uses '/login' and '/signup', they will be available publicly.
    };

    // protectedRoutes: everything that requires authentication (home + features)
    final Map<String, WidgetBuilder> protectedRoutes = {
      '/home': (ctx) => HomeScreenWrapper(auth: auth),
      ...adminRoutes,
      ...broadcastRoutes,
      ...callRoutes,
      ...groupRoutes,
      ...mediaRoutes,
      ...userRoutes,
      ...settingsRoutes,
      ...chatRoutes,
      ...statusRoutes,
    };

    // Combined routes for MaterialApp (we still register public routes explicitly)
    final Map<String, WidgetBuilder> appRoutes = {
      '/': (ctx) => AuthGate(auth: auth),
      ...publicRoutes,
      // Note: protected routes are not added directly to routes map to allow guard via onGenerateRoute.
    };

    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        return MaterialApp(
          title: 'J_ME',
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: navy,
            colorScheme: const ColorScheme.dark(
              primary: blue,
              secondary: gold,
              surface: surface,
              onPrimary: Colors.white,
              onSecondary: navy,
              onSurface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: navy,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            cardTheme: CardThemeData(
              color: surface,
              elevation: 3,
              shadowColor: Colors.black54,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0x223D8BFF)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x443D8BFF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: gold, width: 1.5),
              ),
              labelStyle: const TextStyle(color: Color(0xFFB8C8DB)),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: navy,
                elevation: 2,
                minimumSize: const Size.fromHeight(50),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: MaterialStateProperty.resolveWith(
                (states) =>
                    states.contains(MaterialState.selected) ? gold : Colors.white70,
              ),
              trackColor: MaterialStateProperty.resolveWith(
                (states) =>
                    states.contains(MaterialState.selected) ? blue : Colors.white24,
              ),
            ),
          ),
          initialRoute: '/',
          routes: appRoutes,
          // Use onGenerateRoute to guard protected routes
          onGenerateRoute: (settings) {
            final name = settings.name ?? '';
            // If route is in protectedRoutes, ensure user is authenticated
            if (protectedRoutes.containsKey(name)) {
              if (!auth.isLoggedIn) {
                // redirect to login and preserve intended route in arguments
                return MaterialPageRoute(
                  builder: (ctx) => LoginScreen(
                    onLogin: (username, userId) async {
                      await auth.login(username: username, userId: userId);
                      // after login navigate to intended route
                      Navigator.of(ctx).pushReplacementNamed(name);
                    },
                  ),
                  settings: const RouteSettings(name: '/login'),
                );
              } else {
                // user is authenticated, build the protected route
                final builder = protectedRoutes[name]!;
                return MaterialPageRoute(builder: builder, settings: settings);
              }
            }

            // fallback: if route is public and registered, let MaterialApp handle it
            return null;
          },
          // Optional: show debug banner only in debug mode
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// Root gate that decides whether to show login or home
class AuthGate extends StatelessWidget {
  final AuthService auth;
  const AuthGate({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    // If already logged in, go to home
    if (auth.isLoggedIn) {
      // Use pushReplacement to avoid stacking
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Not logged in -> show login screen
    return LoginScreen(
      onLogin: (username, userId) async {
        await auth.login(username: username, userId: userId);
        Navigator.of(context).pushReplacementNamed('/home');
      },
    );
  }
}

/// A small wrapper that injects user info into the HomeScreen you designed earlier.
/// Replace with your actual HomeScreen import if different.
class HomeScreenWrapper extends StatelessWidget {
  final AuthService auth;
  const HomeScreenWrapper({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    // If you have a HomeScreen widget that expects username/avatar, pass them here.
    return HomeScreen(
      currentUserId: auth.userId,
      username: auth.username,
      avatarUrl: null,
    );
  }
}

/// Simple login screen placeholder. Replace with your real login UI and logic.
/// The `onLogin` callback should call your backend and then call the provided callback
/// with the authenticated username and userId.
class LoginScreen extends StatefulWidget {
  final Future<void> Function(String username, int userId) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController(text: 'jaram');
  bool _loading = false;

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    // In a real app, validate credentials and call your auth API.
    await widget.onLogin(_userController.text.trim(), 1);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SignupScreen(
                    onSignup: (username, userId) async {
                      await widget.onLogin(username, userId);
                    },
                  ),
                ));
              },
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple signup placeholder
class SignupScreen extends StatefulWidget {
  final Future<void> Function(String username, int userId) onSignup;
  const SignupScreen({super.key, required this.onSignup});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _userController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    // Replace with real signup flow
    await widget.onSignup(_userController.text.trim(), 2);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loading ? null : _submit, child: const Text('Sign up')),
          ],
        ),
      ),
    );
  }
}

