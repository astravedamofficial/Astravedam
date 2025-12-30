import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _tokenKey = 'auth_jwt_token';
  static const String _userKey = 'auth_user_data';
  static const String _storageKey = 'astravedam_auth';
  
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final SharedPreferences? _prefs = null;
  
  // Initialize shared preferences
  static Future<void> _initPrefs() async {
    if (_prefs == null) {
      await SharedPreferences.getInstance();
    }
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    await _initPrefs();
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // Get JWT token
  static Future<String?> getToken() async {
    try {
      // Try secure storage first
      String? token = await _secureStorage.read(key: _tokenKey);
      
      // Fallback to shared preferences (for web)
      if (token == null || token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString(_tokenKey);
      }
      
      return token;
    } catch (e) {
      print('⚠️ Error getting token: $e');
      return null;
    }
  }
  
  // Save authentication data
  static Future<void> saveAuthData(String token, Map<String, dynamic> userData) async {
    try {
      await _initPrefs();
      
      // Save token to secure storage
      await _secureStorage.write(key: _tokenKey, value: token);
      
      // Also save to shared preferences for web compatibility
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      
      // Save user data
      await prefs.setString(_userKey, json.encode(userData));
      
      print('✅ Auth data saved successfully');
    } catch (e) {
      print('❌ Error saving auth data: $e');
    }
  }
  
  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      await _initPrefs();
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null && userJson.isNotEmpty) {
        return json.decode(userJson);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }
  
  // Get current user ID
  static Future<String?> getUserId() async {
    final userData = await getUserData();
    return userData?['_id']?.toString();
  }
  
  // Get current user email
  static Future<String?> getUserEmail() async {
    final userData = await getUserData();
    return userData?['email'];
  }
  
  // Get current user name
  static Future<String?> getUserName() async {
    final userData = await getUserData();
    return userData?['name'];
  }
  
  // Get current user credits
  static Future<int> getUserCredits() async {
    final userData = await getUserData();
    return userData?['credits'] ?? 0;
  }
  
  // Login with Google (opens in new window/tab)
  static Future<bool> loginWithGoogle() async {
    try {
      // This will open Google login in a new window
      // The backend will redirect back to our app with token
      final backendUrl = 'https://astravedam.onrender.com/api/auth/google';
      
      // For web, we need to open in new window
      // This is handled by the LoginScreen widget
      return true;
    } catch (e) {
      print('❌ Google login error: $e');
      return false;
    }
  }
  
  // Validate token with backend
  static Future<bool> validateToken() async {
    try {
      final token = await getToken();
      
      if (token == null) return false;
      
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
          // Update user data
          await saveAuthData(token, data['user']);
          return true;
        }
      }
      
      // Token invalid, clear it
      await logout();
      return false;
    } catch (e) {
      print('❌ Token validation error: $e');
      return false;
    }
  }
  
  // Link anonymous charts to registered account
  static Future<bool> linkAnonymousCharts(String anonymousUserId) async {
    try {
      final token = await getToken();
      
      if (token == null) return false;
      
      final response = await http.post(
        Uri.parse('https://astravedam.onrender.com/api/auth/link-charts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'anonymousUserId': anonymousUserId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Charts linked: ${data['linkedCount']} charts');
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error linking charts: $e');
      return false;
    }
  }
  
  // Logout
  static Future<void> logout() async {
    try {
      await _initPrefs();
      
      // Clear secure storage
      await _secureStorage.delete(key: _tokenKey);
      
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      
      print('✅ Logged out successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }
  
  // Generate PKCE code verifier and challenge
  static String _generateCodeVerifier() {
    const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(128, (_) => charset[random.nextInt(charset.length)]).join();
  }
}