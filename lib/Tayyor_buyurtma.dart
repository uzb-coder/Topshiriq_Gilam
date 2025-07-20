import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:convert';
import '../Model/orderwashed_model.dart';
import 'Controller/api_service.dart';
import 'Drawers.dart';

class ClientOrderCardPage extends StatefulWidget {
  const ClientOrderCardPage({super.key});

  @override
  State<ClientOrderCardPage> createState() => _ClientOrderCardPageState();
}

class _ClientOrderCardPageState extends State<ClientOrderCardPage> {
  List<OrderwashedModel> orders = [];




  @override
  void initState() {
    super.initState();
    fetchOrder();
  }

  Future<void> fetchOrder() async {
    final response = await ApiService.getWashedOrders();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['innerData'] as List;
      setState(() {
        orders = data.map((e) => OrderwashedModel.fromJson(e)).toList();
      });
    } else {
      print('❌ Ma\'lumotlarni olishda xatolik');
    }
  }

  Future<void> openMapUniversal(double lat, double lng) async {
    final Uri mapUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (!await launchUrl(mapUrl, mode: LaunchMode.externalApplication)) {
      print('❌ Xarita ochilmadi');
    }
  }


  void _showServislarDetailsDialog(BuildContext context, OrderwashedModel order) {
    if (order.services.isEmpty) return;

    final service = order.services.first;
    double eni = service.width.toDouble();
    double boyi = service.height.toDouble();
    double kvadrat = eni * boyi;
    int miqdori = service.quantity;
    double birlikNarx = service.pricePerSquareMeter.toDouble();
    double umumiyNarx = (kvadrat * birlikNarx) * miqdori;

    ValueNotifier<bool> isSelected = ValueNotifier(false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 16.0, 0.0),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          actionsPadding: const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 8.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Servislar'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: isSelected,
                  builder: (context, isChecked, _) {
                    return Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (bool? newValue) =>
                          isSelected.value = newValue ?? false,
                        ),
                        Text(service.title),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8.0),
                Text('Eni: ${eni.toInt()} × Bo\'yi: ${boyi.toInt()} = Kvadrat: ${kvadrat.toInt()}'),
                Text('Miqdori: $miqdori'),
                Text('Birlik narx: ${birlikNarx.toStringAsFixed(0)}'),
                Text(
                  'Umumiy narx: (${kvadrat.toInt()} × ${birlikNarx.toStringAsFixed(0)}) × $miqdori = ${umumiyNarx.toStringAsFixed(0)}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Saqlash
                Navigator.of(context).pop();
              },
              child: const Text('Saqlash'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.isNotEmpty ? value : '—')),
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
        title: const Text('Tayyor Buyurtmalar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        order.createdAt?.substring(0, 10) ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildRow('Mijoz:', '${order.clientName}'),
                    _buildRow('Telefon:', order.phone),
                    _buildRow('Manzil:', order.address),
                    _buildRow('Tavsif:', ''),
                    _buildRow(
                        'Umumiy summa:',
                        '${order.totalSum.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ')} so\'m'),
                    _buildRow('Yetkazish:', order.deliveryDate.split('T')[0]),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showServislarDetailsDialog(context, order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text(
                            'Topshirish',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            final loc = order.location;
                            if (loc != null) {
                              openMapUniversal(loc.latitude, loc.longitude);
                            } else {
                              print("❌ Lokatsiya mavjud emas");
                            }                          },
                          icon: const Icon(Icons.map_outlined),
                          label: const Text("Haritaga o'tish"),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(color: Colors.blue),
                            foregroundColor: Colors.blue,
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
