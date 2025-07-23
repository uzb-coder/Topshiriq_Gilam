import 'package:flutter/material.dart';
import 'Controller/api_service.dart';
import 'Drawers.dart';
import 'Model/orderwashed_model.dart';

class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({super.key});

  @override
  State<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends State<AllOrdersPage> {
  late Future<List<OrderwashedModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiService.getAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('📦 Barcha Buyurtmalar'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<OrderwashedModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Xatolik: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('🚫 Buyurtmalar mavjud emas.'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 💬 Mijoz ma'lumotlari
                      Text(
                        '👤 ${order.clientName}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text('📞 Telefon: ${order.phone}'),
                      Text('📍 Manzil: ${order.address}'),
                      Text('📅 Yetkazish sanasi: ${order.deliveryDate}'),
                      Text('💰 Umumiy summa: ${order.totalSum} so‘m'),
                      if (order.location != null)
                        Text(
                          '📌 Joylashuv: (${order.location!.latitude}, ${order.location!.longitude})',
                          style: const TextStyle(color: Colors.blueGrey),
                        ),

                      const Divider(height: 20, thickness: 1),

                      const Text(
                        '🧾 Xizmatlar:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      ...order.services.map((service) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blueAccent),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📦 ${service.title}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                  '📐 O‘lcham: ${service.width} x ${service.height} sm (${service.area} sm²)'),
                              Text('🔢 Miqdor: ${service.quantity} ta'),
                              Text('💵 Narx: ${service.pricePerSquareMeter} so‘m'),
                              Text(
                                  '💸 1 m² uchun: ${service.pricePerSquareMeter} so‘m'),
                              Text('📊 Status: ${service.status}'),
                            ],
                          ),
                        );
                      }).toList(),
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
