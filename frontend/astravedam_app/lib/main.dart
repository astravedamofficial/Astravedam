import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/auth_callback_screen.dart';
import 'services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
// Conditional import for web only
import 'dart:html' as html if (dart.library.io) 'dart:io';
import 'screens/dashboard_screen.dart';  // ADD THIS LINE
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astravedam_app/services/identity_service.dart'; // ADD THIS LINE
import 'constants.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('🚀 Initializing app...');
    
    // Check if we're coming from OAuth callback (in URL HASH, not query params)
    if (kIsWeb) {
      final uri = Uri.base;
      final fragment = uri.fragment; // Gets everything after #
      
      print('🔗 URL fragment: $fragment');
      
      if (fragment.isNotEmpty && fragment.contains('token=')) {
        // Parse token from hash like: token=abc&userId=123
        final params = Uri.splitQueryString(fragment);
        final token = params['token'];
        final userId = params['userId'];
        
        if (token != null && token.isNotEmpty) {
          print('🎯 OAuth callback detected in URL hash!');
          print('🎯 Token: ${token.substring(0, 20)}...');
          print('🎯 UserId: $userId');
          
          await AuthService.saveAuthData(token, {
            '_id': userId,
            'email': 'Loading...',
            'name': 'User',
            'credits': 5,
          });
          
          // Clear URL hash
          html.window.history.replaceState({}, '', '/');
          
          // Fetch actual user data
          await _fetchUserData(token);
          
          setState(() {
            _isCheckingAuth = false;
          });
          return;
        }
      }
    }
    
    // Normal startup - validate existing token
    final isValid = await _validateExistingToken();
    
    setState(() {
      _isCheckingAuth = false;
    });
  }

  Future<void> _fetchUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.authMeEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await AuthService.saveAuthData(token, data['user']);
          print('✅ User data updated: ${data['user']['email']}');
        }
      }
    } catch (e) {
      print('⚠️ Error fetching user data: $e');
    }
  }

  Future<bool> _validateExistingToken() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    
    if (isLoggedIn) {
      final token = await AuthService.getToken();
      if (token != null) {
        try {
          final response = await http.get(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.authMeEndpoint}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['success'] == true) {
              await AuthService.saveAuthData(token, data['user']);
              return true;
            }
          }
        } catch (e) {
          print('❌ Token validation failed: $e');
        }
      }
      
      // Token invalid, clear it
      await AuthService.logout();
      return false;
    }
    
    return false;
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

    // Also check URL hash in build method (in case initState missed it)
    if (kIsWeb) {
      final uri = Uri.base;
      final fragment = uri.fragment;
      
      if (fragment.isNotEmpty && fragment.contains('token=')) {
        final params = Uri.splitQueryString(fragment);
        final token = params['token'];
        final userId = params['userId'];
        
        if (token != null && token.isNotEmpty) {
          print('🎯 Building AuthCallbackScreen from URL hash');
          return AuthCallbackScreen(
            token: token,
            userId: userId,
          );
        }
      }
    }

    // Normal flow - check if user should go to dashboard
    return FutureBuilder<bool>(
      future: _hasKundalis(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final shouldGoToDashboard = snapshot.data ?? false;
        
        if (shouldGoToDashboard) {
          print('🚀 Going to dashboard');
          return const DashboardScreen(userChart: {});
        } else {
          print('👋 Showing welcome screen');
          return const WelcomeScreen();
        }
      },
    );
  }

  Future<bool> _hasKundalis() async {
    try {
      print('🔍 Checking if user should go to dashboard...');
      
      // First check if user is logged in
      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (isLoggedIn) {
        print('✅ User is logged in, going to dashboard');
        return true;
      }
      
      // Check for anonymous user ID in shared preferences
      final prefs = await SharedPreferences.getInstance();
      final anonId = prefs.getString('astravedam_user_id');
      
      if (anonId != null && anonId.isNotEmpty) {
        print('✅ Found anonymous user ID: $anonId');
        
        // Check if this user actually has kundalis in database
        try {
          final response = await http.get(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.chartsEndpoint}?userId=$anonId')
          );
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final hasKundalis = (data['charts'] as List).isNotEmpty;
            print('📊 Found ${data['charts']?.length ?? 0} kundalis');
            return hasKundalis;
          }
        } catch (e) {
          print('⚠️ Could not check kundalis, but user exists: $e');
          return true; // User exists, go to dashboard
        }
      }
      
      print('❌ No user found, showing welcome screen');
      return false;
    } catch (e) {
      print('❌ Error checking user: $e');
      return false;
    }
  }
}