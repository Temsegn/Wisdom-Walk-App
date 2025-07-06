import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // Keys
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id'; // New key for user ID
  static const _darkModeKey = 'dark_mode';

  // Existing methods remain exactly the same
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> setDarkModePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDarkMode);
  }

  Future<bool> getDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  // New methods for user ID management
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  // Combined methods for convenience
  Future<void> saveAuthData(String token, String userId) async {
    await saveAuthToken(token);
    await saveUserId(userId);
  }

  Future<void> clearAuthData() async {
    await clearAuthToken();
    await clearUserId();
  }

 
 Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey); // Returns null if not found
  }

  // Helper method to check if a message is from current user
  Future<bool> isCurrentUser(String senderId) async {
    final currentUserId = await getCurrentUserId();
    return senderId == currentUserId;
  }
}
