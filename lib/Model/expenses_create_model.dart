class Expenses_Create {
  final String name;
  final int amount;
  final String paymentType;
  final String description;

  Expenses_Create({
    required this.name,
    required this.amount,
    required this.paymentType,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount': amount,
    'paymentType': paymentType, // 🔴 oldingi 'type' emas
    'description': description,
  };
}
