import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/identity_service.dart';
import 'dashboard_screen.dart';
import 'package:http/http.dart' as http;  // ADD THIS LINE
import 'package:flutter/foundation.dart' show kIsWeb; // ADD THIS
// Conditional import for web only
import 'dart:html' as html if (dart.library.io) 'dart:io'; // ADD THIS

class AuthCallbackScreen extends StatefulWidget {
  final String? token;
  final String? userId;
  
  const AuthCallbackScreen({
    super.key,
    this.token,
    this.userId,
  });

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  bool _isProcessing = true;
  String _statusMessage = 'Processing login...';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _processAuthCallback();
  }
// In auth_callback_screen.dart, replace the _processAuthCallback method:

Future<void> _processAuthCallback() async {
  try {
    print('🎯 Starting auth callback processing');
    print('🔍 STEP 1: Checking all storage for anonymous ID...');
    
    // ✅ Get ALL possible anonymous IDs
    final prefs = await SharedPreferences.getInstance();
    
    // Get all keys to see what's in storage
    final allKeys = prefs.getKeys();
    print('📋 All SharedPreferences keys: $allKeys');
    
    // Try every possible key name
    final possibleKeys = [
      'astravedam_user_id',
      'flutter.astravedam_user_id',
      'user_id',
      'anonymous_id',
      'astravedam_anon_id'
    ];
    
    String? foundId;
    for (var key in possibleKeys) {
      final value = prefs.getString(key);
      if (value != null && value.isNotEmpty) {
        print('✅ Found ID at key "$key": $value');
        foundId = value;
        break;
      }
    }
    
    // If still not found, check if we have any key containing 'anon' or 'user'
    if (foundId == null) {
      for (var key in allKeys) {
        if (key.toLowerCase().contains('anon') || key.toLowerCase().contains('user')) {
          final value = prefs.getString(key);
          if (value != null && value.isNotEmpty && value.startsWith('anon_')) {
            print('✅ Found potential anonymous ID at key "$key": $value');
            foundId = value;
            break;
          }
        }
      }
    }
    
    print('👤 FINAL anonymous ID to link: $foundId');
    
    // Get token from URL
    String? token = widget.token;
    String? userId = widget.userId;
    
    print('🎯 Token from widget: ${token != null}');
    print('🎯 UserId from widget: $userId');
    
    if ((token == null || token.isEmpty) && kIsWeb) {
      final uri = Uri.base;
      final fragment = uri.fragment;
      print('🔗 Checking URL fragment: $fragment');
      
      if (fragment.isNotEmpty && fragment.contains('token=')) {
        final params = Uri.splitQueryString(fragment);
        token = params['token'];
        userId = params['userId'];
        
        print('🎯 Found in URL - Token exists: ${token != null}');
      }
    }
    
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token received');
    }
    
    setState(() {
      _statusMessage = 'Validating token...';
    });
    
    // Save token
    print('💾 Saving initial auth data...');
    await AuthService.saveAuthData(token, {
      '_id': userId,
      'email': 'Loading...',
      'name': 'User',
      'credits': 5,
    });
    
    // Fetch user data
    print('📡 Fetching user data from backend...');
    final response = await http.get(
      Uri.parse('https://astravedam.onrender.com/api/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        print('✅ User data received: ${data['user']['email']}');
        await AuthService.saveAuthData(token, data['user']);
        
        if (kIsWeb) {
          html.window.history.replaceState({}, '', '/');
          print('🧹 Cleared URL parameters');
        }
        

        setState(() {
           _statusMessage = 'Login successful!';
        });
    
        
        // Navigate to dashboard
        await Future.delayed(const Duration(seconds: 1));
        
        if (!mounted) return;
        
        print('🚀 Navigating to dashboard with force refresh');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(
              userChart: {},
              forceRefresh: true,
            ),
          ),
          (route) => false,
        );
        
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
    
  } catch (e) {
    print('❌ Auth callback error: $e');
    setState(() {
      _isProcessing = false;
      _errorMessage = e.toString();
      _statusMessage = 'Login failed';
    });
  }
}

  Future<void> _extractTokenFromUrl() async {
    // This method would extract token from URL parameters in web
    // For now, we rely on widget parameters
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading/Status animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isProcessing ? Colors.deepPurple[100] : 
                       _errorMessage != null ? Colors.red[100] : Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _isProcessing 
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    )
                  : Icon(
                      _errorMessage != null ? Icons.error : Icons.check_circle,
                      size: 40,
                      color: _errorMessage != null ? Colors.red : Colors.green,
                    ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Status message
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _errorMessage != null ? Colors.red[600] : Colors.deepPurple[800],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Details
            if (_errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ] else if (!_isProcessing) ...[
              const Text(
                'Redirecting to dashboard...',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
            
            // Manual button for debugging
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(
                        userChart: {},
                      ),
                    ),
                  );
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}