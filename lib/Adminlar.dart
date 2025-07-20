import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Controller/api_service.dart';
import 'Drawers.dart';
import '../Model/Admin_Model.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  Map<String, bool> _permissions = {
    ' Buyurtma qabuli': false,
    'Adminlar': false,
    'Servislar': false,
    'Yangi buyurtmalar': false,
    'Tayyor buyurtmalar': false,
    'Harajatlar': false,
    'Sozlamalar': false,
  };

  List<Admin> adminList = [];
  bool _loading = true;
  bool _addingAdmin = false; // Yangi admin qo'shish jarayoni
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<Admin> admins = await ApiService.getAllAdmins();
      setState(() {
        adminList = admins;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildRequiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(label),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildAdminCard(Admin admin) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Ism:', admin.firstName),
          _buildInfoRow('Familiya:', admin.lastName),
          _buildInfoRow('Login:', admin.login),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    print('Yangilash bosildi: ${admin.login}');
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Yangilash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await ApiService.deleteAdmin(admin.id);
                      setState(() {
                        adminList.remove(admin);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Admin o\'chirildi'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Xatolik: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('O\'chirish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text.rich(
        TextSpan(
          text: label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          children: [
            TextSpan(
              text: ' $value',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addAdmin() async {
    // Inputlarni tekshirish
    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final selectedPermissions = _permissions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (name.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Barcha maydonlarni to\'ldiring'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _addingAdmin = true;
    });

    try {
      // Admin qo'shish uchun API chaqiruvi
      final adminData = {
        'firstName': name,
        'lastName': lastName,
        'login': username,
        'password': password,
        'permissions': selectedPermissions, // <-- YANGI QATOR
      };

      // ApiService metodining to'g'ri nomini ishlatish
      final result = await ApiService.addAdmin(
        name,
        lastName,
        username,
        password,
        selectedPermissions,
      );

      // Muvaffaqiyatli qo'shildi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Admin muvaffaqiyatli qo\'shildi'),
          backgroundColor: Colors.green,
        ),
      );

      // Inputlarni tozalash
      _nameController.clear();
      _lastNameController.clear();
      _usernameController.clear();
      _passwordController.clear();

      // Adminlar ro'yxatini yangilash
      await _fetchAdmins();

      // Birinchi tabga o'tish (adminlar ro'yxati)
      _tabController.animateTo(0);
    } catch (e) {
      print("❌ Xatolik: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Xatolik: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _addingAdmin = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text('Admin Page', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Adminlar ro\'yxati'),
                Tab(text: 'Adminlar qabul qilish'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Adminlar ro'yxatini ko'rsatadigan widget
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '❌ Xatolik: $_error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchAdmins,
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              )
              : adminList.isEmpty
              ? const Center(
                child: Text(
                  'Adminlar topilmadi',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: adminList.length,
                itemBuilder: (context, index) {
                  final admin = adminList[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.blue.shade100,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ism
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Ism: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: admin.firstName,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 4),
                        // Familiya
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Familya: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: admin.lastName,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 4),
                        // Login
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Login: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: admin.login,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Parol (yashirin)
                        const Text(
                          'Parol: *********',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tugmalar: Yangilash va O'chirish
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Yangilash funksiyasi shu yerda bo'ladi
                                  print('Yangilash bosildi: ${admin.login}');
                                },
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Yangilash'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    print(
                                      '🔁 O‘chirish boshlandi: ID = ${admin.id}',
                                    );
                                    await ApiService.deleteAdmin(
                                      admin.id,
                                    ); // ID asosida o‘chirish

                                    setState(() {
                                      adminList.removeAt(
                                        index,
                                      ); // UI ro‘yxatdan o‘chirish
                                    });

                                    print('✅ Admin muvaffaqiyatli o‘chirildi.');

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("✅ Admin o‘chirildi"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    print(
                                      '❌ O‘chirishda xatolik: $e',
                                    ); // <-- Konsolga chiqarish

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('❌ Xatolik: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text("O‘chirish"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

          // Admin qo'shish formi
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'Ism',
                  hintText: 'Ism kiriting',
                  controller: _nameController,
                ),
                _buildTextField(
                  label: 'Familiya',
                  hintText: 'Familiya kiriting',
                  controller: _lastNameController,
                ),
                _buildTextField(
                  label: 'Login',
                  hintText: 'Login kiriting',
                  controller: _usernameController,
                ),
                _buildTextField(
                  label: 'Parol',
                  hintText: 'Parol kiriting',
                  controller: _passwordController,
                  obscureText: true,
                ),
                _buildTextField(
                  label: 'Lavozim (Role)',
                  hintText: 'Masalan super Admin yoki Operator',
                  controller: _roleController,
                  obscureText: false,
                ),
                Text(
                  "Ruxsatlar:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 16, // gorizontal oraliq
                  runSpacing: 8, // vertikal oraliq
                  children: _permissions.entries.map((entry) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 24, // ekran bo'yicha 2ga bo'linadi
                      child: CheckboxListTile(
                        title: Text(entry.key),
                        value: entry.value,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _permissions[entry.key] = newValue ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),


                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addingAdmin ? null : _addAdmin,
                      icon: _addingAdmin
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(Icons.add),
                      label: Text(
                        _addingAdmin ? 'Qo\'shilmoqda...' : 'Admin Qo\'shish',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    ),
                    // Agar kerak bo‘lsa boshqa widgetlar qo‘shish mumkin
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
