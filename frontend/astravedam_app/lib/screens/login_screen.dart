import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/identity_service.dart';
import 'dashboard_screen.dart';
import 'package:flutter/services.dart';  // ADD THIS LINE FOR Clipboard
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import for web only
import 'dart:html' as html if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final String? redirectMessage;
  
  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.redirectMessage,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkForAuthCallback();
  }

  // Check if we're returning from OAuth callback
  void _checkForAuthCallback() async {
    // This would check URL parameters in real implementation
    // For now, we'll handle callback in a separate screen
  }

void _loginWithGoogle() async {
  setState(() {
    _isLoading = true;
  });
  
  // Simple direct URL
  final googleAuthUrl = 'https://astravedam.onrender.com/api/auth/google';
  
  print('🔗 Opening Google login: $googleAuthUrl');
  
  // For web, open in same tab
  if (kIsWeb) {
    html.window.location.href = googleAuthUrl;
  } else {
    // For mobile (future)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Login'),
        content: Text('Open this URL in your browser:\n\n$googleAuthUrl'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  setState(() {
    _isLoading = false;
  });
}

  void _showOAuthInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Login Instructions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A new window/tab has opened for Google login.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'After logging in with Google:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInstructionStep(1, 'Complete the Google login process'),
            _buildInstructionStep(2, 'You will be redirected back to Astravedam'),
            _buildInstructionStep(3, 'Your account will be automatically created'),
            const SizedBox(height: 16),
            Text(
              'Note: If the popup was blocked, check your browser\'s address bar for popup blockers.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _handleManualToken() async {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Auth Token'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Paste JWT token here',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = controller.text.trim();
              if (token.isNotEmpty) {
                Navigator.pop(context);
                await _testToken(token);
              }
            },
            child: const Text('Test Token'),
          ),
        ],
      ),
    );
  }

  Future<void> _testToken(String token) async {
    setState(() { _isLoading = true; });
    
    try {
      // Validate token with backend
      final response = await AuthService.validateToken();
      
      if (response) {
        _onLoginSuccess();
      } else {
        setState(() {
          _errorMessage = 'Invalid token. Please login again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _onLoginSuccess() async {

    
    // Clear anonymous ID since we're now registered
    await IdentityService.clearAnonymousId();
    
    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Successfully logged in!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Call callback if provided
    widget.onLoginSuccess?.call();
    
    // Navigate to dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(
          userChart: {}, // We'll need to fetch this
        ),
      ),
    );
  }

  void _skipForNow() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              // Logo/Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple[600]!, Colors.purple[600]!],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.self_improvement,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Title
              Text(
                'Welcome to Astravedam',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Login to access all features',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepPurple[600],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Redirect message (if any)
              if (widget.redirectMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.amber[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.redirectMessage!,
                          style: TextStyle(
                            color: Colors.amber[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Google Login Button
              _buildGoogleLoginButton(),
              
              const SizedBox(height: 20),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Continue without login
              OutlinedButton(
                onPressed: _skipForNow,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  side: BorderSide(color: Colors.deepPurple[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue without login',
                  style: TextStyle(
                    color: Colors.deepPurple[600],
                    fontSize: 16,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Features list
              _buildFeaturesList(),
              
              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Loading indicator
              if (_isLoading) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

Widget _buildGoogleLoginButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _loginWithGoogle,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 1,
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google icon
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Continue with Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildFeaturesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'With an account you can:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple[800],
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureItem('🌙 Access "Ask Gods" feature'),
        _buildFeatureItem('💰 Purchase and use credits'),
        _buildFeatureItem('📱 Access your charts from any device'),
        _buildFeatureItem('💾 Never lose your birth charts'),
        _buildFeatureItem('🎁 Get free credits on signup'),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}