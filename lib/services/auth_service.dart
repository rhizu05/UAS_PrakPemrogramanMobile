import 'package:uas_prakpemrogramanmobile/core/constants/api_constants.dart';
import 'package:uas_prakpemrogramanmobile/core/services/api_service.dart';
import 'package:uas_prakpemrogramanmobile/models/user_model.dart';

class AuthService {
  // Register user new customer
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await ApiService.post(
      ApiConstants.register,
      body: {
        'email': email,
        'password': password,
        'full_name': fullName,
      },
      requireAuth: false,
    );
    return response;
  }

  // Login user (admin / customer)
  // Returns Map with: success, message, data (access_token, refresh_token, user object)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
      requireAuth: false,
    );
    return response;
  }

  // Get current logged-in user profile
  Future<UserModel> getProfile() async {
    final response = await ApiService.get(
      ApiConstants.profile,
      requireAuth: true,
    );
    // Response data structure: {"success": true, "message": "...", "data": {...}}
    return UserModel.fromJson(response['data']);
  }

  // Update user profile
  Future<UserModel> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final response = await ApiService.put(
      ApiConstants.profile,
      body: {
        'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
      requireAuth: true,
    );
    return UserModel.fromJson(response['data']);
  }

  // Logout from server
  Future<void> logout() async {
    try {
      await ApiService.post(
        ApiConstants.logout,
        requireAuth: true,
      );
    } catch (_) {
      // Ignore exceptions on logout endpoint, we will clear local state anyway
    }
  }
}
