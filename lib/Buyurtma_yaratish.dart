import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'Drawers.dart';
import 'db_helper.dart';

class YangiBuyurtmalarPage extends StatefulWidget {
  const YangiBuyurtmalarPage({super.key});

  @override
  State<YangiBuyurtmalarPage> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<YangiBuyurtmalarPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();

  String? _selectedService;
  final List<String> _services = ['Xizmat 1', 'Xizmat 2', 'Xizmat 3'];
  final List<Map<String, dynamic>> _addedServices = [];

  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  InputDecoration _commonInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _deliveryDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _addressController.text = "${position.latitude}, ${position.longitude}";
    });

    // ✅ Snackbar ko‘rsatish
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("📍 Geolokatsiya olindi!")));
  }

  Future<void> _saveOrder() async {
    try {
      final orderData = {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'description': _descriptionController.text,
        'mainService': _selectedService,
        'mainQuantity': _quantityController.text,
        'deliveryDate': _deliveryDateController.text,
      };

      int id = await DBHelper.insertOrder(orderData);
      await DBHelper.insertAddedServices(id, _addedServices);

      // ✅ Buyurtma muvaffaqiyatli saqlandi
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Buyurtma saqlandi!")));

      // 🔁 Barcha inputlarni tozalash
      _nameController.clear();
      _surnameController.clear();
      _phoneController.clear();
      _addressController.clear();
      _descriptionController.clear();
      _quantityController.clear();
      _deliveryDateController.clear();
      setState(() {
        _selectedService = null;
        _addedServices.clear();
      });
    } catch (e) {
      // ❌ Xatolik yuz berdi
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Xatolik: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Yangi buyurtma'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ism va familiya
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel('Ism'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _commonInputDecoration('Ismni kiriting'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel('Familiya'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _surnameController,
                        decoration: _commonInputDecoration(
                          'Familiyani kiriting',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Telefon va manzil
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel('Telefon'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _commonInputDecoration('Telefon raqam'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel('Manzil'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        decoration: _commonInputDecoration('Manzil'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _getLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Geolokatsiyani olish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _commonInputDecoration('Tavsif kiriting'),
            ),
            const SizedBox(height: 16),
            // Asosiy xizmat va miqdor
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedService,
                    decoration: _commonInputDecoration('Xizmat turi'),
                    items:
                        _services
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _selectedService = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: _commonInputDecoration('Miqdor'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._addedServices.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> item = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: item['service'],
                      decoration: _commonInputDecoration('Servisni tanlang'),
                      items:
                          _services
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      onChanged:
                          (val) => setState(
                            () => _addedServices[index]['service'] = val,
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: item['quantity'],
                      keyboardType: TextInputType.number,
                      onChanged:
                          (val) => _addedServices[index]['quantity'] = val,
                      decoration: _commonInputDecoration('Miqdor').copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed:
                              () => setState(
                                () => _addedServices.removeAt(index),
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 8),
            GestureDetector(
              onTap:
                  () => setState(
                    () => _addedServices.add({'service': null, 'quantity': ''}),
                  ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.blue),
                    Text(' Servis qo\'shish'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deliveryDateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: _commonInputDecoration(
                'Yetkazib berish vaqti',
              ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.only(right: 30,left: 30,top: 13,bottom: 13),
              ),
              child: const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _deliveryDateController.dispose();
    super.dispose();
  }
}
