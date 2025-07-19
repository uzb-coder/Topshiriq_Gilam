import 'package:flutter/material.dart';

import 'Drawers.dart';

class ClientOrderCardPage extends StatefulWidget {
  const ClientOrderCardPage({super.key});

  @override
  State<ClientOrderCardPage> createState() => _ClientOrderCardPageState();
}

class _ClientOrderCardPageState extends State<ClientOrderCardPage> {
  final String mijozName = 'Bahromjon Abdulhayev';
  final String telefon = '789598979';
  final String manzil = 'Pop';
  final String tavsif = '';
  final String umumiySumma = '80 000';
  final String yetkazishDate = '11-06-2025';
  final String cardDate = '02-06-2025';

  void _showServislarDetailsDialog(BuildContext context) {
    double eni = 2.0;
    double boyi = 4.0;
    double kvadrat = eni * boyi;
    int miqdori = 1;
    double birlikNarx = 10.000;
    double umumiyNarx = (kvadrat * birlikNarx) * miqdori;

    ValueNotifier<bool> isGilamSelected = ValueNotifier<bool>(false);

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
                  valueListenable: isGilamSelected,
                  builder: (context, isChecked, _) {
                    return Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged:
                              (bool? newValue) =>
                                  isGilamSelected.value = newValue ?? false,
                        ),
                        const Text('Gilam'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Eni: ${eni.toStringAsFixed(0)} × Bo\'yi: ${boyi.toStringAsFixed(0)} = Kvadrat: ${kvadrat.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 4.0),
                Text('Miqdori: $miqdori'),
                const SizedBox(height: 4.0),
                Text('Birlik narx: ${birlikNarx.toStringAsFixed(3)}'),
                const SizedBox(height: 4.0),
                Text(
                  'Umumiy narx: (${kvadrat.toStringAsFixed(0)} × ${birlikNarx.toStringAsFixed(3)}) × $miqdori = ${umumiyNarx.toStringAsFixed(3)}',
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
                print('Saqlash');
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
        title: const Text('Buyurtma tafsilotlari'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                // Sana tepada
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    cardDate,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Ma'lumotlar
                _buildRow('Mijoz:', mijozName),
                _buildRow('Telefon:', telefon),
                _buildRow('Manzil:', manzil),
                _buildRow('Tavsif:', tavsif),
                _buildRow('Umumiy summa:', '$umumiySumma so\'m'),
                _buildRow('Yetkazish:', yetkazishDate),

                const SizedBox(height: 20),

                // Tugmalar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showServislarDetailsDialog(context),
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
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () {
                            print('Haritaga o\'tish bosildi');
                          },
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
