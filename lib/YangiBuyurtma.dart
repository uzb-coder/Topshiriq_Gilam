import 'package:flutter/material.dart';

import 'Drawers.dart';

class Client {
  final String name;
  final String phoneNumber;
  final String address;
  final String description;
  final String date;

  Client({
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.description,
    required this.date,
  });
}

class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  final List<Client> clients = [
    Client(
      name: 'Alixon Ibo',
      phoneNumber: '+998900990700',
      address: 'Waxxar',
      description: '',
      date: '01-06-2025',
    ),
    Client(
      name: 'Alixon Ibodullayev',
      phoneNumber: '+998900990700',
      address: 'Qarasuv',
      description: 'Srochni',
      date: '02-06-2025',
    ),
    Client(
      name: 'wdqafd dqwd',
      phoneNumber: '32312311212',
      address: '12122e11',
      description: '',
      date: '02-06-2025',
    ),
    Client(
      name: 'Asss Asss',
      phoneNumber: '996272212',
      address: 'Shaxar',
      description: 'Toza',
      date: '03-06-2025',
    ),
    Client(
      name: 'Sard Sardor',
      phoneNumber: '+998976179737',
      address: 'Example Address',
      description: 'Example Description',
      date: '04-06-2025',
    ),
  ];

  void _showServislarDialog(BuildContext context, Client client) {
    TextEditingController eniController = TextEditingController();
    TextEditingController boyiController = TextEditingController();
    ValueNotifier<double> kvValue = ValueNotifier<double>(0.0);

    eniController.addListener(() => _calculateKv(eniController.text, boyiController.text, kvValue));
    boyiController.addListener(() => _calculateKv(eniController.text, boyiController.text, kvValue));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 16.0, 0.0),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          actionsPadding: const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 8.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Servislar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1.5),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1),
                  },
                  children: [
                    const TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Servis nomi', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Eni (m)', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Bo\'yi (m)', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Kv', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Gilam'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: SizedBox(
                            width: 70,
                            child: TextField(
                              controller: eniController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.blue),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: SizedBox(
                            width: 70,
                            child: TextField(
                              controller: boyiController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.blue),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ValueListenableBuilder<double>(
                            valueListenable: kvValue,
                            builder: (context, value, child) {
                              return Text(value.toStringAsFixed(2));
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                print('Eni: ${eniController.text}');
                print('Boyi: ${boyiController.text}');
                print('Kv: ${kvValue.value}');
                Navigator.of(context).pop();
              },
              child: const Text('Saqlash', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _calculateKv(String eniText, String boyiText, ValueNotifier<double> kvValue) {
    double eni = double.tryParse(eniText) ?? 0.0;
    double boyi = double.tryParse(boyiText) ?? 0.0;
    kvValue.value = eni * boyi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Mijozlar'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow('Mijoz:', client.name),
                  _buildRow('Telefon:', client.phoneNumber),
                  _buildRow('Manzil:', client.address),
                  _buildRow('Tavsif:', client.description),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () => _showServislarDialog(context, client),
                        child: const Text('Servislar', style: TextStyle(color: Colors.white)),
                      ),
                      Text(
                        client.date,
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Flexible(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
