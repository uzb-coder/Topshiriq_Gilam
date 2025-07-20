class OrderCreateModel {
  final String firstName;
  final String lastName;
  final String phone;
  final String addressText;
  final String description;
  final String deliveryDate;
  final List<Map<String, dynamic>> services;

  OrderCreateModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.addressText,
    required this.description,
    required this.deliveryDate,
    required this.services,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'addressText': addressText,
      'description': description,
      'deliveryDate': deliveryDate,
      'services': services,
    };
  }
}
