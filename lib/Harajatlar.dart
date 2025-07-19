import 'package:flutter/material.dart';

import 'Drawers.dart';

// Data model for an expense
class Expense {
  final String name;
  final double amount;
  final String paymentType;
  final String description;
  final DateTime date; // To store when the expense was added

  Expense({
    required this.name,
    required this.amount,
    required this.paymentType,
    this.description = '',
    required this.date,
  });
}

class HarajatlarPage extends StatefulWidget {
  const HarajatlarPage({super.key});

  @override
  State<HarajatlarPage> createState() => _ExpenseManagementPageState();
}

class _ExpenseManagementPageState extends State<HarajatlarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Expense> _expenses = []; // List to store all added expenses

  // Controllers for the form fields
  final TextEditingController _harajatNomiController = TextEditingController();
  final TextEditingController _pulMiqdoriController = TextEditingController();
  String? _selectedTolovTuri; // For the dropdown
  final TextEditingController _tavsifController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Key for form validation

  // Sample payment types for the dropdown
  final List<String> _tolovTurlari = [
    'Naqd',
    'Bank o\'tkazmasi',
    'Karta',
    'Boshqa',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _harajatNomiController.dispose();
    _pulMiqdoriController.dispose();
    _tavsifController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final String name = _harajatNomiController.text;
      final double amount = double.parse(_pulMiqdoriController.text);
      final String paymentType = _selectedTolovTuri!;
      final String description = _tavsifController.text;

      setState(() {
        _expenses.add(
          Expense(
            name: name,
            amount: amount,
            paymentType: paymentType,
            description: description,
            date: DateTime.now(), // Record the current date/time
          ),
        );
      });

      // Clear form fields
      _harajatNomiController.clear();
      _pulMiqdoriController.clear();
      _tavsifController.clear();
      _selectedTolovTuri = null; // Clear selected dropdown value

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harajat muvaffaqiyatli saqlandi!')),
      );

      // Optionally, switch to the Harajatlar tab to see the new entry
      _tabController.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('Harajatlar boshqaruvi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Harajatlar'), Tab(text: 'Harajat yozish')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpenseListView(), // Harajatlar tab content
          _buildExpenseForm(), // Harajat yozish tab content
        ],
      ),
    );
  }

  Widget _buildExpenseForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Harajat nomi
              const Text(
                '* Harajat nomi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _harajatNomiController,
                decoration: const InputDecoration(
                  hintText: 'Masalan: kommunal to\'lov',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harajat nomi kiritilishi shart';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Pul miqdori
              const Text(
                '* Pul miqdori',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _pulMiqdoriController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Masalan: 500000',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pul miqdori kiritilishi shart';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Noto\'g\'ri miqdor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // To'lov turi
              const Text(
                '* To\'lov turi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                value: _selectedTolovTuri,
                hint: const Text('To\'lov turini tanlang'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items:
                    _tolovTurlari.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTolovTuri = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'To\'lov turi tanlanishi shart';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Tavsif
              const Text(
                'Tavsif',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _tavsifController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Qo\'shimcha ma\'lumot',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Aligns hint text at the top
                ),
              ),
              const SizedBox(height: 24.0),

              // Saqlash button
              SizedBox(
                width: double.infinity, // Makes the button fill width
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        8.0,
                      ), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Saqlash',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseListView() {
    if (_expenses.isEmpty) {
      return const Center(child: Text('Hali harajatlar qo\'shilmagan.'));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2.0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // For wider tables
            child: DataTable(
              columnSpacing: 16.0, // Space between columns
              headingRowColor: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                return Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1); // Light blue header
              }),
              columns: const [
                DataColumn(
                  label: Text(
                    'Nomi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Miqdori',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'To\'lov turi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Tavsif',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Sana',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows:
                  _expenses.map((expense) {
                    return DataRow(
                      cells: [
                        DataCell(Text(expense.name)),
                        DataCell(
                          Text('${expense.amount.toStringAsFixed(0)} UZS'),
                        ), // Format amount
                        DataCell(Text(expense.paymentType)),
                        DataCell(
                          Text(
                            expense.description.isNotEmpty
                                ? expense.description
                                : '-',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${expense.date.day.toString().padLeft(2, '0')}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.year}',
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
