import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/auth_callback_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const AstravedamApp());
}

class AstravedamApp extends StatelessWidget {
  const AstravedamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astravedam',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Georgia',
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isCheckingAuth = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Check if user is logged in
    final isLoggedIn = await AuthService.isLoggedIn();
    
    // If logged in, validate token
    if (isLoggedIn) {
      final isValid = await AuthService.validateToken();
      if (!isValid) {
        await AuthService.logout();
      }
    }
    
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // For now, always show welcome screen
    // In future, you can check _isLoggedIn and show different screens
    return const WelcomeScreen();
  }
}