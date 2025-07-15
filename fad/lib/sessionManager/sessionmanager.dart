import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  ///
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserMobNumber = '';
  static const String _keyUserName = '';
  static const String _keyUserCartId = '';
  static const String _accessToken = '12345';

  /// Set Access Token
  Future<void> setAccessToken(String token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(_accessToken, token);
  }

  /// Get Access Token
  Future<String?> getAccessToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    return pref.getString(_accessToken);
  }

  /// Set Log In Status
  Future<void> setLoginStatus(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  /// Get Log In Status
  Future<bool> getLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Set User Mobile number
  Future<void> setUserMobNumber(String number) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyUserMobNumber, number);
  }

  /// Get User Mobile number
  Future<String?> getUserMobNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserMobNumber);
  }

  /// Set User Id
  Future<void> setUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyUserId, userId);
  }

  /// Get User Id
  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// Set User Name
  Future<void> setUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyUserName, userName);
  }

  /// Get User Name
  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// Set User Cart ID
  Future<void> setUserCartId(String userCartId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyUserCartId, userCartId);
  }

  /// Get User Cart ID
  Future<String?> getUserCartId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserCartId);
  }

  /// Clear Session LogIn, UserID, UserName, UserCartID,
  Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserMobNumber);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserCartId);
  }
}
