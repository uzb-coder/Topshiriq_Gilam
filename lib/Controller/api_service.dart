import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/Admin_Model.dart';
import '../Model/company_model.dart';
import '../Model/expense_Model.dart';
import '../Model/ServiceModel.dart';
import '../Model/order_create_model.dart';
import '../Model/order_model.dart';
import '../Model/orderwashed_model.dart';

class ApiService {
  static const String baseUrl = 'https://gilam-b.vercel.app/api';

  static const String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MzNlMTdjODcyNzZmMDA5NTcwNDI4ZiIsImxvZ2luIjoiYWRtaW4zMjEiLCJpYXQiOjE3NTI5MjA5OTd9.QrUs95OGlRUlL_Yvm6dds6zmd1L48nCROFuAmPx4HDo';

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
  static Future<Admin> addAdmin(
    String firstName,
    String lastName,
    String login,
    String password,
    List<String> selectedPermissions,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'login': login,
        'password': password,
        'permissions': ['admin_add'], // ✅ BU SHART
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Admin.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Xatolik: ${response.statusCode} - ${response.body}');
    }
  }

  /// 3. Admin o‘chirish
  static Future<void> deleteAdmin(String id) async {
    final url = Uri.parse('$baseUrl/admin/delete/$id');
    print("🌐 DELETE so‘rov: $url");

    final response = await http.delete(url, headers: _headers);

    print("📥 StatusCode: ${response.statusCode}");
    print("📥 Javob: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Admin o‘chirishda xatolik: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// 4. Adminni yangilash (ID orqali)
  static Future<http.Response> updateAdmin(
    String id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/admin/update/$id');
    return await http.put(url, headers: _headers, body: jsonEncode(data));
  }

  /// 5. Buyurtmalar
  static Future<List<Order>> getOrders() async {
    final url = Uri.parse('$baseUrl/order');
    final response = await http.get(url, headers: _headers);
    print('📦 Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> orderList = jsonResponse['innerData'] ?? [];
      return orderList.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Buyurtmalarni olishda xatolik: ${response.statusCode}');
    }
  }

  /// 6. Barcha companionably olish
  static Future<CompanyModel> getCompany() async {
    final url = Uri.parse('$baseUrl/company/all');

    final response = await http.get(url, headers: _headers);
    print("📡 Status code: ${response.statusCode}");
    print("📦 Body: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CompanyModel.fromJson(data);
    } else {
      throw Exception('Company maʼlumotlari olinmadi: ${response.statusCode}');
    }
  }

  /// 7. Yangi kompaniya yaratish
  static Future<http.Response> createCompany(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/company/create');
    return await http.post(url, headers: _headers, body: jsonEncode(data));
  }

  /// 8. Kompaniyani o‘chirish (ID orqali)
  static Future<http.Response> deleteCompany(String id) async {
    final url = Uri.parse('$baseUrl/company/delete/$id');
    return await http.delete(url, headers: _headers);
  }

  /// 9. Yangi service qo‘shish (service)
  static Future<http.Response> createService(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/service');
    return await http.post(url, headers: _headers, body: jsonEncode(data));
  }

  /// 10. Barcha service olish
  static Future<List<Services>> getAllServices() async {
    final url = Uri.parse('$baseUrl/service');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> serviceList = jsonResponse['innerData'] ?? [];
      return serviceList.map((json) => Services.fromJson(json)).toList();
    } else {
      throw Exception('Servislarni olishda xatolik: ${response.body}');
    }
  }

  /// 11. service yangilash (ID orqali)
  static Future<http.Response> updateService(
    String id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/service/$id');
    return await http.put(url, headers: _headers, body: jsonEncode(data));
  }

  /// 12. service o‘chirish (ID orqali)
  static Future<http.Response> deleteService(String id) async {
    final url = Uri.parse('$baseUrl/service/$id');
    return await http.delete(url, headers: _headers);
  }

  /// 13. Yangi buyurtma yaratish
  static Future<http.Response> createOrder(OrderCreateModel order) async {
    final url = Uri.parse('$baseUrl/order');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(order.toJson()),
    );
    print(">>> API manzili: $url");
    print(">>> Jo‘natilayotgan JSON: ${jsonEncode(order.toJson())}");

    return response;
  }

  /// 14. Barcha buyurtmalarni olish
  static Future<List<OrderwashedModel>> getAllOrders() async {
    final url = Uri.parse('$baseUrl/order');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> orderList = jsonResponse['innerData'] ?? [];

      return orderList.map((json) => OrderwashedModel.fromJson(json)).toList();
    } else {
      throw Exception('Buyurtmalarni olishda xatolik: ${response.body}');
    }
  }

  /// 15. Buyurtmani yangilash (ID orqali)
  static Future<http.Response> updateOrder(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (id.isEmpty) {
      throw ArgumentError("❌ Order ID bo'sh bo'lishi mumkin emas!");
    }

    final url = Uri.parse('$baseUrl/order/$id/'); // ✅ Oxirida / bo‘lishi kerak

    try {
      final response = await http.patch(
        url,
        headers: _headers,
        body: jsonEncode(data),
      );

      // 🧾 Loglar
      print('📦 Yuborilayotgan ma\'lumotlar: $data');
      print('🔗 So\'rov URL: $url');
      print('📬 Javob status code: ${response.statusCode}');
      print('📨 Javob body: ${response.body}');

      return response;
    } catch (e) {
      print("🚨 PATCH so‘rovda xatolik: $e");
      rethrow; // Xatolikni tashqariga chiqarish
    }
  }

  /// 16. Yangi kelgan buyurtmalarni olish
  static Future<http.Response> getNewOrders() async {
    final url = Uri.parse('$baseUrl/ordernew');
    return await http.get(url, headers: _headers);
  }

  /// 17. Yuvilgan buyurtmalarni olish
  static Future<http.Response> getWashedOrders() async {
    final url = Uri.parse('$baseUrl/orderwashed');
    final response = await http.get(url, headers: _headers);

    /// print('📦 Body: ${response.body}');
    return response; // Bitta response qaytaryapmiz
  }

  /// 18. Dashboard ma'lumotlarini olish
  static Future<http.Response> getDashboardData() async {
    final url = Uri.parse('$baseUrl/dashboard');
    return await http.get(url, headers: _headers);
  }

  /// 19. Yangi xarajat (expense) yaratish
  static Future<http.Response> createExpense(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/expense/create');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(data),
    );
    print('📦 Body: ${response.body}');
    return response;
  }

  /// 20. Barcha xarajatlarni olish
  static Future<List<Expenses>> getAllExpenses() async {
    final url = Uri.parse('$baseUrl/expense/all');
    final response = await http.get(url, headers: _headers);

    print('📦 Status code: ${response.statusCode}');
    print('📦 Body: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['state'] == true && body['innerData'] != null) {
        return List<Expenses>.from(
          body['innerData'].map((item) => Expenses.fromJson(item)),
        );
      } else {
        return [];
      }
    } else {
      throw Exception("Xarajatlarni olishda xatolik");
    }
  }
}
