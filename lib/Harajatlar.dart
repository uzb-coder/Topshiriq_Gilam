import 'package:flutter/material.dart';
import '../controller/api_service.dart';
import '../Model/expense_Model.dart';
import 'Drawers.dart';
import 'Model/expenses_create_model.dart';

class HarajatlarPage extends StatefulWidget {
  const HarajatlarPage({super.key});

  @override
  State<HarajatlarPage> createState() => _HarajatlarPageState();
}

class _HarajatlarPageState extends State<HarajatlarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Expenses>> _expensesFuture;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _harajatNomiController = TextEditingController();
  final TextEditingController _pulMiqdoriController = TextEditingController();
  final TextEditingController _tavsifController = TextEditingController();
  String? _selectedTolovTuri;

  final List<String> _tolovTurlari = [
    'Naqd',
    'Karta',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _expensesFuture = ApiService.getAllExpenses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _harajatNomiController.dispose();
    _pulMiqdoriController.dispose();
    _tavsifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('Harajatlar boshqaruvi',style: TextStyle(color: Colors.white),),
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.white,  // Tanlanmagan tab yozuvi rangi
          indicatorColor: Colors.white,        // Pastki chiziq rangi (indicator)
          tabs: const [Tab(text: 'Harajatlar'), Tab(text: 'Harajat yozish')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStyledExpenseList(),
          _buildExpenseForm(),
        ],
      ),
    );
  }

  Widget _buildStyledExpenseList() {
    return FutureBuilder<List<Expenses>>(
      future: _expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("❌ Xatolik: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("⚠️ Xarajatlar topilmadi"));
        }

        final expenses = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final e = expenses[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blue.shade200, width: 1),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("💰 Summasi: ${e.amount} so'm"),
                    Text("💳 To'lov turi: ${e.paymentType}"),
                    Text("📝 Tavsif: ${e.description.isEmpty ? '-' : e.description}"),
                    Text("📅 Sana: ${e.createdAt.toLocal().toString().substring(0, 16)}"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpenseForm() {
    bool _isLoading = false;

    void _submitExpenseForm() async {
      if (!_formKey.currentState!.validate()) return;

      final newExpense = Expenses_Create(
        name: _harajatNomiController.text,
        amount: int.tryParse(_pulMiqdoriController.text) ?? 0,
        paymentType: _selectedTolovTuri ?? '',
        description: _tavsifController.text,
      );

      setState(() => _isLoading = true);

      final result = await ApiService.createExpense(newExpense.toJson());

      setState(() => _isLoading = false);

      if (result.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Harajat muvaffaqiyatli saqlandi!')),
        );

        // Formani tozalash
        _formKey.currentState!.reset();
        _harajatNomiController.clear();
        _pulMiqdoriController.clear();
        _tavsifController.clear();
        _selectedTolovTuri = null;

        // Ro'yxatni yangilash
        setState(() {
          _expensesFuture = ApiService.getAllExpenses();
        });

        // Harajatlar tabiga qaytish
        _tabController.animateTo(0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Xatolik: ${result.body}')),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRequiredLabel('Harajat nomi'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _harajatNomiController,
                decoration: const InputDecoration(
                  hintText: 'Masalan: Kommunal to‘lov',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Harajat nomi kiritilishi shart' : null,
              ),
              const SizedBox(height: 16),

              _buildRequiredLabel('Pul miqdori'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pulMiqdoriController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Masalan: 500000',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Pul miqdori kiritilishi shart';
                  if (double.tryParse(value) == null) return 'Noto‘g‘ri raqam';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildRequiredLabel('To‘lov turi'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTolovTuri,
                hint: const Text('To‘lov turini tanlang'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _tolovTurlari
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedTolovTuri = val),
                validator: (value) =>
                value == null || value.isEmpty ? 'To‘lov turi tanlanishi shart' : null,
              ),
              const SizedBox(height: 16),

              const Text('Tavsif', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tavsifController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Qo‘shimcha ma‘lumot',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitExpenseForm,
                  icon: _isLoading
                      ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Yuborilmoqda...' : 'Saqlash', style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
