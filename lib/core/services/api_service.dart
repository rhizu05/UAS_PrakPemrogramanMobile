import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uas_prakpemrogramanmobile/core/constants/api_constants.dart';
import 'package:uas_prakpemrogramanmobile/core/services/storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = ApiConstants.baseUrl;

  // Build headers automatically, attaching JWT token if available
  static Map<String, String> _getHeaders({bool requireAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = StorageService.getToken();
      print('ApiService: Token retrieved from storage: "$token"');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        print('ApiService: WARNING! Token is empty or null!');
      }
    }

    print('ApiService: Request Headers: $headers');
    return headers;
  }

  // Handle http response, parse JSON, and throw ApiException on error
  static dynamic _processResponse(http.Response response) {
    final int statusCode = response.statusCode;
    dynamic responseBody;

    try {
      responseBody = jsonDecode(response.body);
    } catch (_) {
      throw ApiException(
        'Format response tidak valid dari server (Status $statusCode)',
        statusCode: statusCode,
      );
    }

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else {
      String errorMessage = 'Terjadi kesalahan sistem';
      if (responseBody is Map<String, dynamic>) {
        errorMessage = responseBody['message'] ?? responseBody['error'] ?? errorMessage;
      }
      throw ApiException(errorMessage, statusCode: statusCode);
    }
  }

  // HTTP GET Helper
  static Future<dynamic> get(String endpoint, {bool requireAuth = true, Map<String, String>? queryParams}) async {
    try {
      Uri uri = Uri.parse('$_baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      print('ApiService: GET Request to: $_baseUrl$endpoint');
      final response = await http.get(
        uri,
        headers: _getHeaders(requireAuth: requireAuth),
      );
      print('ApiService: GET Response Status: ${response.statusCode}');
      print('ApiService: GET Response Body: ${response.body}');
      
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal terhubung ke server. Silakan periksa koneksi internet Anda.');
    }
  }

  // HTTP POST Helper
  static Future<dynamic> post(String endpoint, {dynamic body, bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: _getHeaders(requireAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal terhubung ke server. Silakan periksa koneksi internet Anda.');
    }
  }

  // HTTP PUT Helper
  static Future<dynamic> put(String endpoint, {dynamic body, bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: _getHeaders(requireAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal terhubung ke server. Silakan periksa koneksi internet Anda.');
    }
  }

  // HTTP DELETE Helper
  static Future<dynamic> delete(String endpoint, {bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.delete(
        uri,
        headers: _getHeaders(requireAuth: requireAuth),
      );
      
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal terhubung ke server. Silakan periksa koneksi internet Anda.');
    }
  }
}
