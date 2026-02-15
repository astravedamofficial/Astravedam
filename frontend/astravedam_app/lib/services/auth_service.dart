import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

// Web-only imports
import 'dart:html' as html if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  try {
    // Try shared_preferences first
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);
    
    print('🔍 Checking login - SharedPrefs token: ${token != null ? "Found" : "Not found"}');
    
    // If not found in shared_preferences, check localStorage (web only)
    if ((token == null || token.isEmpty) && kIsWeb) {
      try {
        // Access localStorage directly
        final storage = html.window.localStorage;
        token = storage[_tokenKey];
        print('🔍 Checking login - localStorage token: ${token != null ? "Found" : "Not found"}');
        
        // If found in localStorage, save to shared_preferences for consistency
        if (token != null && token.isNotEmpty) {
          await prefs.setString(_tokenKey, token);
          print('✅ Copied token from localStorage to SharedPreferences');
        }
      } catch (e) {
        print('⚠️ localStorage access error: $e');
      }
    }
    
    final hasToken = token != null && token.isNotEmpty;
    print('🔐 Login check result: $hasToken');
    
    // If we have a token, validate it
    if (hasToken) {
      final isValid = await validateToken();
      if (!isValid) {
        print('❌ Token invalid, clearing');
        await logout();
        return false;
      }
    }
    
    return hasToken;
  } catch (e) {
    print('❌ Error in isLoggedIn: $e');
    return false;
  }
}
  // DEBUG METHOD - Check all storage locations
static Future<void> debugStorage() async {
  print('🔍 DEBUG: Checking all storage locations');
  
  try {
    // Check SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final spToken = prefs.getString(_tokenKey);
    final spUser = prefs.getString(_userKey);
    
    print('📁 SharedPreferences:');
    print('   Token: ${spToken != null ? "✓ Found (${spToken.substring(0, 20)}...)" : "✗ Not found"}');
    print('   User: ${spUser != null ? "✓ Found" : "✗ Not found"}');
    
    // Check localStorage (web only)
    if (kIsWeb) {
      try {
        final storage = html.window.localStorage;
        final lsToken = storage[_tokenKey];
        final lsUser = storage[_userKey];
        
        print('🌐 localStorage:');
        print('   Token: ${lsToken != null ? "✓ Found (${lsToken.substring(0, 20)}...)" : "✗ Not found"}');
        print('   User: ${lsUser != null ? "✓ Found" : "✗ Not found"}');
        
        // List all localStorage keys
        print('   All keys: ${storage.keys.toList()}');
      } catch (e) {
        print('⚠️ localStorage access error: $e');
      }
    }
  } catch (e) {
    print('❌ Debug error: $e');
  }
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
    print('💾 Saving auth data - Token length: ${token.length}');
    
    // Save to shared preferences (works on web)
    final prefs = await SharedPreferences.getInstance();
    
    // Save token
    await prefs.setString(_tokenKey, token);
    print('✅ Token saved to SharedPreferences');
    
    // Save user data
    await prefs.setString(_userKey, json.encode(userData));
    print('✅ User data saved: ${userData['email'] ?? "No email"}');
    
    // Also save to localStorage directly (for web compatibility)
    if (kIsWeb) {
      try {
        final storage = html.window.localStorage;
        storage[_tokenKey] = token;
        storage[_userKey] = json.encode(userData);
        print('✅ Token saved to localStorage');
      } catch (e) {
        print('⚠️ localStorage error: $e');
      }
    }
    
    // Verify save was successful
    final savedToken = prefs.getString(_tokenKey);
    print('🔍 Verification - Saved token matches: ${savedToken == token}');
    
  } catch (e) {
    print('❌ Error saving auth data: $e');
    rethrow;
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
  
// Logout
static Future<void> logout() async {
  try {
    print('🚪 Starting logout process...');
    
    // Get current user data before clearing
    final userData = await getUserData();
    final wasLoggedIn = userData != null;
    
    if (wasLoggedIn) {
      print('👤 User was logged in as: ${userData?['email']}');
    }
    
    // Clear secure storage
    await _secureStorage.delete(key: _tokenKey);
    
    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    
    // Also clear localStorage for web
    if (kIsWeb) {
      try {
        final storage = html.window.localStorage;
        storage.remove(_tokenKey);
        storage.remove(_userKey);
      } catch (e) {
        print('⚠️ localStorage clear error: $e');
      }
    }
    
    // Regenerate anonymous ID for fresh anonymous session
    if (wasLoggedIn) {
      print('🔄 Regenerating anonymous ID for new session');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Simple random string generator
      String getRandomString(int length) {
        const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
        final random = Random();
        return String.fromCharCodes(
          Iterable.generate(
            length,
            (_) => chars.codeUnitAt(random.nextInt(chars.length)),
          ),
        );
      }
      
      final random = getRandomString(6);
      final newAnonId = 'anon_${timestamp}_$random';
      
      await prefs.setString('astravedam_user_id', newAnonId);
      print('✅ New anonymous ID created: $newAnonId');
    }
    
    print('✅ Logout completed successfully');
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