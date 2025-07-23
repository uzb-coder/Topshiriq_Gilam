import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controller/api_service.dart';
import '../Model/order_model.dart';
import 'Drawers.dart';
import 'Model/orderwashed_model.dart';

class Client {
  final String id;
  final String name;
  final String phoneNumber;
  final String address;
  final String description;
  final String date;
  final int totalSum;
  final List<ServiceModel> services; // ✅ Bu yerda services qo‘shamiz
  Client({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.description,
    required this.date,
    required this.totalSum,
    required this.services,
  });
}

class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  late Future<List<Client>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _clientsFuture = _loadClientsFromApi();
  }

  Future<List<Client>> _loadClientsFromApi() async {
    final response =
        await ApiService.getNewOrders(); // ⬅️ faqat yangi buyurtmalar
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> orderList = jsonResponse['innerData'] ?? [];
      return orderList.map((json) {
        final order = Order.fromJson(json);
        return Client(
          id: order.id,
          name: order.fullName,
          phoneNumber: order.phone,
          address: order.address,
          description: order.description,
          date: formatDate(order.createdAt),
          totalSum: order.totalSum,
          services:(json['services'] as List<dynamic>?)
                  ?.map((e) => ServiceModel.fromJson(e))
                  .toList() ??
              [], // ✅ parse qilish
        );
      }).toList();
    } else {
      throw Exception('Yangi buyurtmalarni olishda xatolik: ${response.body}');
    }
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (_) {
      return '';
    }
  }

  void _showServislarDialog(BuildContext context, Client client) {
    TextEditingController eniController = TextEditingController();
    TextEditingController boyiController = TextEditingController();
    ValueNotifier<double> kvValue = ValueNotifier<double>(0.0);

    eniController.addListener(
      () => _calculateKv(eniController.text, boyiController.text, kvValue),
    );
    boyiController.addListener(
      () => _calculateKv(eniController.text, boyiController.text, kvValue),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 8,
          ), // almost full width
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: screenWidth,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title & Close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Servislar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Table Header
                Row(
                  children: const [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Servis nomi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Eni (m)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Bo\'yi (m)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Kv',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Table Row
                Row(
                  children: [
                    const Expanded(flex: 3, child: Text('Gilam')),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: eniController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Eni',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: boyiController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Boyi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ValueListenableBuilder<double>(
                        valueListenable: kvValue,
                        builder:
                            (context, value, child) =>
                                Text(value.toStringAsFixed(2)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Bekor qilish'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                        double eni = double.tryParse(eniController.text) ?? 0.0;
                        double boyi = double.tryParse(boyiController.text) ?? 0.0;
                        double kv = kvValue.value;
                        double price = kv * 1000;
                        int quantity = 3;
                        double totalSum = price * quantity;

                        final data = {
                          'firstName': client.name.split(" ").first,
                          'lastName': client.name.split(" ").length > 1
                              ? client.name.split(" ").sublist(1).join(" ")
                              : '',
                          'phone': client.phoneNumber,
                          'addressText': client.address,
                          'totalSum': totalSum, // ✅ asosiy summa
                          'services': [
                            {
                              'title': client.description,
                              'width': eni,
                              'height': boyi,
                              'area': kv,
                              'quantity': quantity,
                              'pricePerSquareMeter': price,
                              'totalSum': totalSum,
                            },
                          ],
                          'deliveryDate': DateFormat("yyyy-MM-dd").format(DateTime.now()),
                          'status': 'washed',
                        };


                        final response = await ApiService.updateOrder(
                          client.id,
                          data,
                        );

                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Maʼlumotlar saqlandi'),
                            ),
                          );
                          Navigator.of(context).pop();
                          setState(() {
                            _clientsFuture =
                                _loadClientsFromApi(); // ro‘yxatni yangilash
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "❌ Xatolik: ${response.statusCode}",
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Saqlash',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _calculateKv(
    String eniText,
    String boyiText,
    ValueNotifier<double> kvValue,
  ) {
    double eni = double.tryParse(eniText) ?? 0.0;
    double boyi = double.tryParse(boyiText) ?? 0.0;
    kvValue.value = eni * boyi;
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Flexible(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Yangi Buyurtmalar'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: FutureBuilder<List<Client>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Xatolik: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Mijozlar yo'q"));
          }

          final clients = snapshot.data!;
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow('Mijoz:', client.name),
                      _buildRow('Tavsif:', client.description),
                      _buildRow('Telefon:', client.phoneNumber),
                      _buildRow('Manzil:', client.address),
                      _buildRow('Ummumiy summa:', client.totalSum.toString()),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed:
                                () => _showServislarDialog(context, client),
                            child: const Text(
                              'Servislar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Text(
                            client.date,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
