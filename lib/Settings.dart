import 'package:flutter/material.dart';
import 'Drawers.dart';
import 'Model/company_model.dart';
import 'Controller/api_service.dart';

class SozlamalarPage extends StatelessWidget {
  final TextEditingController _nomiController = TextEditingController();
  final TextEditingController _manzilController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();

  SozlamalarPage({super.key});

  void _saqlash(BuildContext context) async {
    final nom = _nomiController.text.trim();
    final manzil = _manzilController.text.trim();
    final telefon = _telefonController.text.trim();

    if (nom.isEmpty || manzil.isEmpty || telefon.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, barcha maydonlarni to\'ldiring')),
      );
      return;
    }

    CompanyModel company = CompanyModel(
      name: nom,
      address: manzil,
      phone: telefon,
    );

    final response = await ApiService.createCompany(company.toJson());

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Kompaniya muvaffaqiyatli saqlandi')),
      );
      _nomiController.clear();
      _manzilController.clear();
      _telefonController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Xatolik: ${response.statusCode}')),
      );
    }
  }

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
                    onPressed: () => _saqlash(context),
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
