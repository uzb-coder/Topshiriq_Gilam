import 'package:flutter/material.dart';
import 'Drawers.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> services = [
    {'Nomi': 'adyolkatta', 'Narxi': '10000 so\'m', 'Birlik': 'kv', 'Tavsifi': ''},
    {'Nomi': 'Gilam', 'Narxi': '10000 so\'m', 'Birlik': 'kv', 'Tavsifi': ''},
    {'Nomi': 'Parda', 'Narxi': '25000 so\'m', 'Birlik': 'kg', 'Tavsifi': ''},
  ];

  final _formKey = GlobalKey<FormState>();
  final _nomiController = TextEditingController();
  final _narxiController = TextEditingController();
  final _birlikController = TextEditingController();
  final _tavsifiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomiController.dispose();
    _narxiController.dispose();
    _birlikController.dispose();
    _tavsifiController.dispose();
    super.dispose();
  }

  void _addService() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        services.add({
          'Nomi': _nomiController.text,
          'Narxi': _narxiController.text,
          'Birlik': _birlikController.text,
          'Tavsifi': _tavsifiController.text,
        });

        _nomiController.clear();
        _narxiController.clear();
        _birlikController.clear();
        _tavsifiController.clear();

        _tabController.animateTo(0);
      });
    }
  }

  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w500),
        children: const [
          TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text("Xizmatlar", style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Xizmatlar ro\'yxati'),
            Tab(text: 'Yangi qo\'shish'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Ro'yxat
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 24.0,
              headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.grey[200]),
              columns: const [
                DataColumn(label: Text('Nomi')),
                DataColumn(label: Text('Narxi')),
                DataColumn(label: Text('Birlik')),
                DataColumn(label: Text('Tavsifi')),
              ],
              rows: services.map((service) {
                return DataRow(cells: [
                  DataCell(Text(service['Nomi']!)),
                  DataCell(Text(service['Narxi']!)),
                  DataCell(Text(service['Birlik']!)),
                  DataCell(Text(service['Tavsifi']!)),
                ]);
              }).toList(),
            ),
          ),

          // 2. Yangi qo'shish formasi
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildRequiredLabel('Xizmat nomi'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nomiController,
                    decoration: const InputDecoration(
                      hintText: 'Masalan: Gilam',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Xizmat nomini kiriting' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredLabel('O\'lchov birligi'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _birlikController,
                    decoration: const InputDecoration(
                      hintText: 'Birlikni tanlang',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'O\'lchov birligini kiriting' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredLabel('Narxi (so\'m)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _narxiController,
                    decoration: const InputDecoration(
                      hintText: 'Masalan: 10000',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Narxni kiriting' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Tavsifi'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _tavsifiController,
                    decoration: const InputDecoration(
                      hintText: 'Qo‘shimcha ma\'lumot...(majburiy emas)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _addService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Saqlash'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
