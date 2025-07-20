import 'package:flutter/material.dart';

import 'Controller/api_service.dart';
import 'Model/expenses_create_model.dart';

class CreateExpensePage extends StatefulWidget {
  const CreateExpensePage({super.key});

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedPaymentType = 'Naqd'; // default qiymat

  final List<String> _paymentTypes = ['Naqd', 'Plastik', 'Bank'];

  bool _isLoading = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final newExpense = Expenses_Create(
      name: _nameController.text,
      amount: int.tryParse(_amountController.text) ?? 0,
      paymentType: _selectedPaymentType,
      description: _descriptionController.text,
    );

    setState(() => _isLoading = true);

    final result = await ApiService.createExpense(newExpense.toJson());

    setState(() => _isLoading = false);

    if (result.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Muvaffaqiyatli saqlandi!')),
      );
      _formKey.currentState!.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Xatolik: ${result.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yangi xarajat qo\'shish')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nomi'),
                validator: (value) => value!.isEmpty ? 'Nomini kiriting' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Summa'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Summani kiriting' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedPaymentType,
                items: _paymentTypes
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                decoration: const InputDecoration(labelText: 'To\'lov turi'),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentType = value!;
                  });
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Izoh'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                )
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Yuborilmoqda...' : 'Saqlash'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
