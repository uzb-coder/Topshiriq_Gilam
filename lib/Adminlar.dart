import 'package:flutter/material.dart';
import 'Drawers.dart';
import '../Model/Admin.dart';
import '../Servis/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  bool _buyurtmaQabuli = false;
  bool _adminlar = false;
  bool _servislar = false;
  bool _yangiBuyurtmalar = false;
  bool _tayyorBuyurtmalar = false;
  bool _harajatlar = false;
  bool _sozlamalar = false;

  List<Admin> adminList = [];
  bool _loading = true;
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
        style: const TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w500),
        children: const [
          TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildPermissionsCheckboxRow(
      String title, {
        required bool value1,
        required ValueChanged<bool?> onChanged1,
        String? title2,
        bool? value2,
        ValueChanged<bool?>? onChanged2,
        String? title3,
        bool? value3,
        ValueChanged<bool?>? onChanged3,
      }) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Checkbox(value: value1, onChanged: onChanged1, activeColor: Colors.blue),
              Text(title),
            ],
          ),
        ),
        if (title2 != null && value2 != null && onChanged2 != null)
          Expanded(
            child: Row(
              children: [
                Checkbox(value: value2, onChanged: onChanged2, activeColor: Colors.blue),
                Text(title2),
              ],
            ),
          ),
        if (title3 != null && value3 != null && onChanged3 != null)
          Expanded(
            child: Row(
              children: [
                Checkbox(value: value3, onChanged: onChanged3, activeColor: Colors.blue),
                Text(title3),
              ],
            ),
          ),
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
          _buildInfoRow('Parol:', '******'),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    print('Yangilash bosildi: ${admin.firstName}');
                    // Yangilash uchun API chaqiruvi qo'shish mumkin
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Yangilash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Adminni o'chirishni API orqali qilish mumkin
                    // Misol uchun:
                    // await ApiService.deleteAdmin(admin.id);
                    setState(() {
                      adminList.remove(admin);
                    });
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('O\'chirish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addAdmin() async {
    final String ism = _nameController.text.trim();
    final String familiya = _surnameController.text.trim();
    final String login = _loginController.text.trim();
    final String parol = _passwordController.text.trim();
    final String role = _roleController.text.trim();

    if (ism.isEmpty || familiya.isEmpty || login.isEmpty || parol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Barcha majburiy maydonlarni to‘ldiring!'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      // API orqali yangi admin qo'shish
      // Misol uchun:
      final newAdmin = await ApiService.createAdmin(
        firstName: ism,
        lastName: familiya,
        login: login,
        password: parol,
        role: role,
        permissions: {
          'buyurtmaQabuli': _buyurtmaQabuli,
          'adminlar': _adminlar,
          'servislar': _servislar,
          'yangiBuyurtmalar': _yangiBuyurtmalar,
          'tayyorBuyurtmalar': _tayyorBuyurtmalar,
          'harajatlar': _harajatlar,
          'sozlamalar': _sozlamalar,
        },
      );

      setState(() {
        adminList.add(newAdmin);
        _nameController.clear();
        _surnameController.clear();
        _loginController.clear();
        _passwordController.clear();
        _roleController.clear();
        _buyurtmaQabuli = false;
        _adminlar = false;
        _servislar = false;
        _yangiBuyurtmalar = false;
        _tayyorBuyurtmalar = false;
        _harajatlar = false;
        _sozlamalar = false;
        _tabController.index = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Yangi admin qo‘shildi!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Xatolik yuz berdi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _roleController.dispose();
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
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
            child: Text(
              '❌ Xatolik: $_error',
              style: const TextStyle(color: Colors.red),
            ),
          )
              : ListView.builder(
            itemCount: adminList.length,
            itemBuilder: (context, index) {
              return _buildAdminCard(adminList[index]);
            },
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(label: 'Ism', hintText: 'Ismni kiriting', controller: _nameController),
                _buildTextField(label: 'Familiya', hintText: 'Familiyani kiriting', controller: _surnameController),
                _buildTextField(label: 'Login', hintText: 'Loginni kiriting', controller: _loginController),
                _buildTextField(label: 'Parol', hintText: 'Parolni kiriting', controller: _passwordController, obscureText: true),
                _buildTextField(label: 'Lavozim (Role)', hintText: 'Masalan: Super Admin yoki Operator', controller: _roleController),

                _buildRequiredLabel('Ruxsatlar'),
                const SizedBox(height: 8.0),
                _buildPermissionsCheckboxRow(
                  'Buyurtma qabuli',
                  value1: _buyurtmaQabuli,
                  onChanged1: (val) => setState(() => _buyurtmaQabuli = val ?? false),
                  title2: 'Adminlar',
                  value2: _adminlar,
                  onChanged2: (val) => setState(() => _adminlar = val ?? false),
                ),
                _buildPermissionsCheckboxRow(
                  'Servislar',
                  value1: _servislar,
                  onChanged1: (val) => setState(() => _servislar = val ?? false),
                  title2: 'Yangi buyurtmalar',
                  value2: _yangiBuyurtmalar,
                  onChanged2: (val) => setState(() => _yangiBuyurtmalar = val ?? false),
                ),
                _buildPermissionsCheckboxRow(
                  'Tayyor buyurtmalar',
                  value1: _tayyorBuyurtmalar,
                  onChanged1: (val) => setState(() => _tayyorBuyurtmalar = val ?? false),
                  title2: 'Harajatlar',
                  value2: _harajatlar,
                  onChanged2: (val) => setState(() => _harajatlar = val ?? false),
                ),
                _buildPermissionsCheckboxRow(
                  'Sozlamalar',
                  value1: _sozlamalar,
                  onChanged1: (val) => setState(() => _sozlamalar = val ?? false),
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  height: 48.0,
                  child: ElevatedButton(
                    onPressed: _addAdmin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                      elevation: 2,
                    ),
                    child: const Text('Admin qo\'shish', style: TextStyle(fontSize: 18.0)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
