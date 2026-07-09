import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_prakpemrogramanmobile/core/constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management
  static Future<bool> saveToken(String token) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(AppConstants.tokenKey, token);
  }

  static String? getToken() {
    return _prefs?.getString(AppConstants.tokenKey);
  }

  static Future<bool> deleteToken() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(AppConstants.tokenKey);
  }

  // Generic String Storage (e.g. for user role, profile cache, etc.)
  static Future<bool> saveString(String key, String value) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<bool> remove(String key) async {
    if (_prefs == null) await init();
    return await _prefs!.remove(key);
  }

  // Onboarding Status
  static Future<bool> saveOnboardingCompleted(bool completed) async {
    if (_prefs == null) await init();
    return await _prefs!.setBool('onboarding_completed', completed);
  }

  static bool isOnboardingCompleted() {
    return _prefs?.getBool('onboarding_completed') ?? false;
  }

  static Future<bool> clear() async {
    if (_prefs == null) await init();
    return await _prefs!.clear();
  }
}
