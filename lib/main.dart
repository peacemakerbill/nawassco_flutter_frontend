import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';

import 'features/public/auth/providers/auth_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file at app startup
  // await dotenv.load(fileName: ".env");

  final container = ProviderContainer();

  // Restore session on web BEFORE app starts
  if (kIsWeb) {
    await _restoreWebSession(container.read(authProvider.notifier));
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: NawasscoApp(scaffoldMessengerKey: scaffoldMessengerKey),
    ),
  );
}

// Restore JWT from SharedPreferences and validate via /auth/me
Future<void> _restoreWebSession(AuthProvider auth) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');
    if (jwt == null || jwt.isEmpty) return;

    // Set token in Dio
    auth.dio.options.headers['Authorization'] = 'Bearer $jwt';

    // Validate token
    final response = await auth.dio.get('/auth/me');
    if (response.data['success'] == true) {
      final user = response.data['user'] as Map<String, dynamic>;
      final roles = (user['roles'] as List).cast<String>();

      auth.state = AuthState(
        isAuthenticated: true,
        isAdmin: roles.contains('Admin'),
        isSalesAgent: roles.contains('SalesAgent'),
        user: user,
      );
    } else {
      throw Exception('Invalid session');
    }
  } catch (e) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    auth.dio.options.headers.remove('Authorization');
  }
}