import 'package:flutter/material.dart';

import 'Drawers.dart';

class SozlamalarPage extends StatelessWidget {
  final TextEditingController _nomiController = TextEditingController();
  final TextEditingController _manzilController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();

  SozlamalarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text("Sozlamalar"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Sozlamalar",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nomiController,
                  decoration: const InputDecoration(
                    labelText: "Kompaniya nomi",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _manzilController,
                  decoration: const InputDecoration(
                    labelText: "Kompaniya manzili",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _telefonController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Telefon raqami",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Saqlash logikasi bu yerga yoziladi
                      final nom = _nomiController.text;
                      final manzil = _manzilController.text;
                      final telefon = _telefonController.text;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saqlandi: $nom, $manzil, $telefon')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Saqlash",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
