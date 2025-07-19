import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _token;
  String? _error;

  Future<void> login() async {
    final url = Uri.parse('https://gilam-b.vercel.app/api/admin/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': _loginController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      print('🔁 StatusCode: ${response.statusCode}');
      print('📥 Javob body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['state'] == true) {
        setState(() {
          _token = data['innerData']['token']; // 🔑 Token bu yerda
          _error = null;
        });
        print('✅ Token: $_token');
      } else {
        setState(() {
          _error = data['message'] ?? 'Xatolik yuz berdi';
          _token = null;
        });
        print('❌ Xato: $_error');
      }
    } catch (e) {
      setState(() {
        _error = 'Internet yoki server xatosi: $e';
        _token = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(labelText: 'Login'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Parol'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text("Kirish")),
            const SizedBox(height: 20),
            if (_token != null)
              Text("Token:\n$_token", style: const TextStyle(color: Colors.green)),
            if (_error != null)
              Text("Xatolik: $_error", style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
