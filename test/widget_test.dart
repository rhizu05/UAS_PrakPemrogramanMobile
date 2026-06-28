// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  test('Test API Admin', () async {
    final baseUrl = 'https://api-tb-f2wk.onrender.com/api';
    
    final loginRes = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'admin@admin.com',
        'password': 'admin123',
      }),
    );
    
    final token = jsonDecode(loginRes.body)['data']['access_token'];
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    
    final statsRes = await http.get(Uri.parse('$baseUrl/dashboard/stats'), headers: headers);
    print('STATS: ${statsRes.body}');
    
    final topRes = await http.get(Uri.parse('$baseUrl/dashboard/top-products'), headers: headers);
    print('TOP: ${topRes.body}');
    
    final ordersRes = await http.get(Uri.parse('$baseUrl/orders/admin/all'), headers: headers);
    print('ORDERS: ${ordersRes.body}');
  });
}
