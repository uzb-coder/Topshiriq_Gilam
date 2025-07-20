class Order {
  final String id;
  final String fullName;
  final String phone;
  final String address;
  final String description;
  final String createdAt;
  final int totalAmount;
  final String deliveryDate;

  Order({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.description,
    required this.createdAt,
    required this.totalAmount,
    required this.deliveryDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      fullName: '${json['firstName']} ${json['lastName']}',
      phone: json['phone'] ?? '',
      address: json['addressText'] ?? '',
      description: (json['services'] != null && json['services'].isNotEmpty)
          ? json['services'][0]['title']
          : '',
      createdAt: json['createdAt'] ?? '',
      totalAmount: int.tryParse(json['totalAmount'].toString()) ?? 0,
      deliveryDate: json['deliveryDate'] ?? '',
    );
  }
}
