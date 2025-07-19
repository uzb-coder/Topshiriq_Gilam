import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/Admin.dart';

class ApiService {
  static const String baseUrl = 'https://gilam-b.vercel.app/api';

  // Bu yerga tokeningizni to'liq va haqiqiy ko'rinishda yozing:
  static const String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MzNlMTdjODcyNzZmMDA5NTcwNDI4ZiIsImxvZ2luIjoiYWRtaW4zMjEiLCJpYXQiOjE3NTI5MjA5OTd9.QrUs95OGlRUlL_Yvm6dds6zmd1L48nCROFuAmPx4HDo';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  /// 1. Adminlar ro‘yxati
  static Future<List<Admin>> getAllAdmins() async {
    final url = Uri.parse('$baseUrl/admin/all');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> adminList = jsonResponse['innerData'] ?? [];
      return adminList.map((json) => Admin.fromJson(json)).toList();
    } else {
      throw Exception('Adminlarni olishda xatolik: ${response.statusCode}');
    }
  }

  /// 2. Yangi admin qo‘shish
  static Future<http.Response> addAdmin(String name, String username, String password) async {
    final url = Uri.parse('$baseUrl/admin/create');
    return await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'name': name, 'username': username, 'password': password}),
    );
  }

  /// 3. Admin o‘chirish
  static Future<http.Response> deleteAdmin(String id) async {
    final url = Uri.parse('$baseUrl/admin/delete/$id');
    return await http.delete(url, headers: _headers);
  }

  /// 4. Buyurtmalar
  static Future<http.Response> getOrders() async {
    final url = Uri.parse('$baseUrl/order');
    return await http.get(url, headers: _headers);
  }

  /// 5. Buyurtma yaratish
  static Future<http.Response> createOrder(Map<String, dynamic> orderData) async {
    final url = Uri.parse('$baseUrl/order');
    return await http.post(url, headers: _headers, body: jsonEncode(orderData));
  }

  /// 6. Buyurtma o‘chirish
  static Future<http.Response> deleteOrder(String id) async {
    final url = Uri.parse('$baseUrl/order/delete/$id');
    return await http.delete(url, headers: _headers);
  }

  /// 7. Harajatlar
  static Future<http.Response> getExpenses() async {
    final url = Uri.parse('$baseUrl/expense/all');
    return await http.get(url, headers: _headers);
  }

  static Future<http.Response> addExpense(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/expense/create');
    return await http.post(url, headers: _headers, body: jsonEncode(data));
  }

  static Future<http.Response> deleteExpense(String id) async {
    final url = Uri.parse('$baseUrl/expense/delete/$id');
    return await http.delete(url, headers: _headers);
  }

  /// 8. Foydalanuvchilar
  static Future<http.Response> getUsers() async {
    final url = Uri.parse('$baseUrl/user/all');
    return await http.get(url, headers: _headers);
  }

  static Future<http.Response> createUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/user/create');
    return await http.post(url, headers: _headers, body: jsonEncode(userData));
  }

  static Future<http.Response> deleteUser(String id) async {
    final url = Uri.parse('$baseUrl/user/delete/$id');
    return await http.delete(url, headers: _headers);
  }

  /// 9. Mahsulotlar
  static Future<http.Response> getProducts() async {
    final url = Uri.parse('$baseUrl/product/all');
    return await http.get(url, headers: _headers);
  }

  static Future<http.Response> addProduct(Map<String, dynamic> productData) async {
    final url = Uri.parse('$baseUrl/product/create');
    return await http.post(url, headers: _headers, body: jsonEncode(productData));
  }

  static Future<http.Response> deleteProduct(String id) async {
    final url = Uri.parse('$baseUrl/product/delete/$id');
    return await http.delete(url, headers: _headers);
  }

  /// 10. Statistika
  static Future<http.Response> getStatistics() async {
    final url = Uri.parse('$baseUrl/statistics');
    return await http.get(url, headers: _headers);
  }

  /// 11. Sozlamalar
  static Future<http.Response> getSettings() async {
    final url = Uri.parse('$baseUrl/settings');
    return await http.get(url, headers: _headers);
  }

  static Future<http.Response> updateSettings(Map<String, dynamic> settingsData) async {
    final url = Uri.parse('$baseUrl/settings/update');
    return await http.put(url, headers: _headers, body: jsonEncode(settingsData));
  }

  /// 12. Parolni o‘zgartirish
  static Future<http.Response> changeAdminPassword(String id, String newPassword) async {
    final url = Uri.parse('$baseUrl/admin/password/$id');
    return await http.put(url, headers: _headers, body: jsonEncode({'password': newPassword}));
  }
}
