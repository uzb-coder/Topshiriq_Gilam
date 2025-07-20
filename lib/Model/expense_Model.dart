class Expenses {
  final String id;
  final String name;
  final int amount;
  final String description;
  final String paymentType;
  final DateTime createdAt;

  Expenses({
    required this.id,
    required this.name,
    required this.amount,
    required this.description,
    required this.paymentType,
    required this.createdAt,
  });

  factory Expenses.fromJson(Map<String, dynamic> json) {
    return Expenses(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
      description: json['description'] ?? '',
      paymentType: json['paymentType'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
