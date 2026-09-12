import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SentinelApp());
}

class SentinelApp extends StatefulWidget {
  const SentinelApp({super.key});
  @override
  State<SentinelApp> createState() => _SentinelAppState();
}

class _SentinelAppState extends State<SentinelApp> {
  bool _loading = true, _signedIn = false;
  @override
  void initState() {
    super.initState();
    ApiService.instance.expired.addListener(_expired);
    _restore();
  }

  Future<void> _restore() async {
    final signedIn = await AuthService.instance.restore();
    if (mounted) {
      setState(() {
        _signedIn = signedIn;
        _loading = false;
      });
    }
  }

  void _expired() {
    if (ApiService.instance.expired.value && mounted) {
      setState(() => _signedIn = false);
    }
  }

  @override
  void dispose() {
    ApiService.instance.expired.removeListener(_expired);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sentinel • Investigation Workspace',
    debugShowCheckedModeBanner: false,
    theme: AppConfig.theme,
    home: _loading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : _signedIn
        ? DashboardScreen(
            onLogout: () async {
              try {
                await AuthService.instance.logout();
              } finally {
                if (mounted) setState(() => _signedIn = false);
              }
            },
          )
        : LoginScreen(onSignedIn: () => setState(() => _signedIn = true)),
  );
}
