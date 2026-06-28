import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/core/constants/app_constants.dart';
import 'package:uas_prakpemrogramanmobile/core/services/storage_service.dart';
import 'package:uas_prakpemrogramanmobile/models/user_model.dart';
import 'package:uas_prakpemrogramanmobile/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isAdmin => _user?.role.toLowerCase() == 'admin';

  // Set loading helper
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Clear errors helper
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Register Method
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    clearError();
    try {
      await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Login Method
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    clearError();
    try {
      final response = await _authService.login(email: email, password: password);
      
      final data = response['data'];
      final accessToken = data['access_token'] ?? '';
      
      // Save token in Memory & SharedPreferences
      _token = accessToken;
      await StorageService.saveToken(accessToken);

      // Parse user details from response
      if (data['user'] != null) {
        _user = UserModel.fromJson(data['user']);
        await StorageService.saveString(AppConstants.userRoleKey, _user!.role);
      } else {
        // Fallback: If login payload does not contain user model, fetch it
        await _fetchProfileData();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _token = null;
      _user = null;
      await StorageService.deleteToken();
      await StorageService.remove(AppConstants.userRoleKey);
      _setLoading(false);
      return false;
    }
  }

  // Fetch profile details from server
  Future<bool> fetchProfile() async {
    _setLoading(true);
    clearError();
    try {
      await _fetchProfileData();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Helper method for profile retrieval
  Future<void> _fetchProfileData() async {
    final userProfile = await _authService.getProfile();
    _user = userProfile;
    await StorageService.saveString(AppConstants.userRoleKey, _user!.role);
    notifyListeners();
  }

  // Auto-login check (e.g. called from Splash Screen)
  Future<bool> tryAutoLogin() async {
    clearError();
    final savedToken = StorageService.getToken();
    if (savedToken == null || savedToken.isEmpty) {
      return false;
    }

    _token = savedToken;
    try {
      // Validate token by fetching the profile
      await _fetchProfileData();
      return true;
    } catch (e) {
      // Token is expired or invalid
      _token = null;
      _user = null;
      await StorageService.deleteToken();
      await StorageService.remove(AppConstants.userRoleKey);
      return false;
    }
  }

  // Update profile Method
  Future<bool> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    _setLoading(true);
    clearError();
    try {
      final updatedUser = await _authService.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      _user = updatedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Logout Method
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
    } catch (_) {
      // Proceed even if network request fails
    }

    // Reset Memory & SharedPreferences state
    _token = null;
    _user = null;
    await StorageService.deleteToken();
    await StorageService.remove(AppConstants.userRoleKey);
    _setLoading(false);
  }
}
