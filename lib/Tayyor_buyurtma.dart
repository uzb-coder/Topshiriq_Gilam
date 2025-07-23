import 'package:flutter/material.dart';
import 'package:gilam/Model/order_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../Model/orderwashed_model.dart';
import 'Controller/api_service.dart';
import 'Drawers.dart';
import 'Model/order_create_model.dart';

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
    final Uri mapUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    if (!await launchUrl(mapUrl, mode: LaunchMode.externalApplication)) {
      print('❌ Xarita ochilmadi');
    }
  }


  void _showServislarDetailsDialog(
    BuildContext context,
    OrderwashedModel order,
  ) {
    if (order.services == null || order.services!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Bu buyurtmada xizmatlar mavjud emas."),
        ),
      );
      return;
    }

    ValueNotifier<List<bool>> selectedList = ValueNotifier(
      List.filled(order.services.length, false),
    );

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
              const Text(
                'Servislar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: ValueListenableBuilder<List<bool>>(
                valueListenable: selectedList,
                builder: (context, isCheckedList, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(order.services.length, (index) {
                      final service = order.services[index];
                      double eni = (service.width ?? 0).toDouble();
                      double boyi = (service.height ?? 0).toDouble();
                      double pricePerSquareMeter = (service.pricePerSquareMeter ?? 0).toDouble();
                      double kvadrat = eni * boyi;
                      int miqdori = service.quantity ?? 1;
                      double birlikNarx = (service.price ?? 0).toDouble();
                      double umumiyNarx = (kvadrat * pricePerSquareMeter) * miqdori;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isCheckedList[index],
                                  onChanged: (bool? newValue) {
                                    selectedList.value = [...isCheckedList]
                                      ..[index] = newValue ?? false;
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    service.title ?? 'Noma\'lum servis',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildServiceDetailRow(
                              'O\'lchov:',
                              '${eni.toInt()} × ${boyi.toInt()} = ${kvadrat.toStringAsFixed(1)}',
                            ),
                            _buildServiceDetailRow('Miqdori:', '$miqdori'),
                            _buildServiceDetailRow(
                              'Birlik narxi:',
                              '${_formatPrice(pricePerSquareMeter)} so\'m',
                            ),
                            const Divider(height: 16),
                            _buildServiceDetailRow(
                              'Umumiy narxi:',
                              '${_formatPrice(umumiyNarx)} so\'m',
                              isTotal: true,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Hisob-kitob: (${kvadrat.toStringAsFixed(1)} × ${_formatPrice(pricePerSquareMeter)}) × $miqdori = ${_formatPrice(umumiyNarx)} so\'m',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () async {
                // order.id null yoki bo'sh bo'lsa, foydalanuvchiga ogohlantirish chiqadi
                if (order.id == null || order.id!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "❌ Buyurtma ID topilmadi! Yangilash mumkin emas.",
                      ),
                    ),
                  );
                  return;
                }

                try {
                  // Buyurtma holatini yangilash
                  final response = await ApiService.updateOrder(order.id!, {
                    'status': 'delivered',
                  });

                  // API javobini tekshirib chiqamiz
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✅ Buyurtma muvaffaqiyatli yakunlandi."),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop(); // Dialogni yopish
                    setState(() {
                      orders.removeWhere((element) => element.id == order.id);
                    }); // Ekranni yangilash
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "❌ Xatolik: ${response.statusCode} - ${response.body}",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("❌ Xatolik yuz berdi: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Topshirish'),
            ),
          ],
        );
      },
    );
  }

  // Servis tafsilotlari uchun widget

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

  String? _lastFormattedPrice; // klass ichida global o'zgaruvchi

  // Narxni formatlash funksiyasi
  String _formatPrice(double price) {
    final formatted = price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ');

    _lastFormattedPrice = formatted; // oxirgi qiymatni saqlab qo'yamiz
    return formatted;
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
        elevation: 2,
      ),
      body:
          orders.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Buyurtmalar yuklanmoqda...'),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: fetchOrder,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: Colors.black26,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Tayyor',
                                      style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    order.createdAt?.substring(0, 10) ?? '',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildRow('Mijoz:', '${order.clientName}'),
                              _buildRow('Telefon:', order.phone ?? ''),
                              _buildRow('Manzil:', order.address ?? ''),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Umumiy summa:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${_formatPrice(order.totalSum.toDouble())} so\'m',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              _buildRow(
                                'Yetkazish sanasi:',
                                order.deliveryDate?.split('T')[0] ?? '',
                              ),
                              _buildRow(
                                'Yangilanish sanasi:',
                                order.createdAt?.split('T')[0] ?? '',
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          () => _showServislarDetailsDialog(
                                            context,
                                            order,
                                          ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      icon: const Icon(Icons.check_circle),
                                      label: const Text(
                                        'Topshirish',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      // onPressed: () {
                                      //   final loc = order.location;
                                      //   if (loc != null) {
                                      //     openMapUniversal(
                                      //       loc.latitude,
                                      //       loc.longitude,
                                      //     );
                                      //   } else {
                                      //     ScaffoldMessenger.of(
                                      //       context,
                                      //     ).showSnackBar(
                                      //       const SnackBar(
                                      //         content: Text(
                                      //           "❌ Manzil koordinatalari mavjud emas.",
                                      //         ),
                                      //         backgroundColor: Colors.orange,
                                      //       ),
                                      //     );
                                      //   }
                                      // },
                                      onPressed: () async {
                                        if (order.id == null ||
                                            order.id!.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "❌ Buyurtma ID topilmadi! Yangilash mumkin emas.",
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        try {
                                          final response =
                                              await ApiService.updateOrder(
                                                order.id!,
                                                {
                                                  'status': 'delivered',
                                                },
                                              );

                                          if (response.statusCode == 200) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "✅ Buyurtma muvaffaqiyatli yakunlandi.",
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            Navigator.of(context).pop();
                                            setState(() {
                                              orders.removeWhere(
                                                (element) =>
                                                    element.id == order.id,
                                              );
                                            });
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "❌ Xatolik: ${response.statusCode} - ${response.body}",
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "❌ Xatolik yuz berdi: $e",
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.map_outlined),
                                      label: const Text(
                                        "Xaritada ko'rish",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        side: const BorderSide(
                                          color: Colors.blue,
                                        ),
                                        foregroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
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
              ),
    );
  }
  Widget _buildServiceDetailRow(
      String label,
      String value, {
        bool isTotal = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? Colors.green.shade700 : Colors.grey.shade700,
                fontSize: isTotal ? 14 : 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.green.shade800 : Colors.black87,
                fontSize: isTotal ? 14 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
