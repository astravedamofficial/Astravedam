import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/identity_service.dart';
import 'dashboard_screen.dart';
import 'package:http/http.dart' as http;  // ADD THIS LINE

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

Future<void> _processAuthCallback() async {
  try {
    // Extract token from URL
    final uri = Uri.base;
    final token = uri.queryParameters['token'];
    final userId = uri.queryParameters['userId'];
    
    print('🔐 Auth callback received - Token: ${token?.substring(0, 20)}...');
    
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token received');
    }
    
    setState(() {
      _statusMessage = 'Validating token...';
    });
    
    // Save token immediately
    await AuthService.saveAuthData(token, {
      '_id': userId,
      'email': 'Loading...',
      'name': 'User',
      'credits': 5,
    });
    
    // Fetch actual user data from backend
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
        // Update with real user data
        await AuthService.saveAuthData(token, data['user']);
        
        // Link anonymous charts
        setState(() {
          _statusMessage = 'Linking your data...';
        });
        
        final identity = await IdentityService.getIdentity();
        final anonId = identity['id'];
        await AuthService.linkAnonymousCharts(anonId);
        await IdentityService.clearAnonymousId();
        
        // Success!
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Login successful!';
        });
        
        // Navigate to dashboard
        await Future.delayed(const Duration(seconds: 1));
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(
              userChart: {},
            ),
          ),
          (route) => false, // Remove all previous routes
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