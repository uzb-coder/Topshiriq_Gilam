class OrderCreateModel {
  final String firstName;
  final String lastName;
  final String phone;
  final String addressText;
  final String description;
  final String deliveryDate;
  final List<Map<String, dynamic>> services;
  final Map<String, double>? location;

  OrderCreateModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.addressText,
    required this.description,
    required this.deliveryDate,
    required this.services,
    this.location,
  });

  factory OrderCreateModel.fromJson(Map<String, dynamic> json) {
    return OrderCreateModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      addressText: json['addressText'] ?? '',
      description: json['description'] ?? '',
      deliveryDate: json['deliveryDate'] ?? '',
      services: List<Map<String, dynamic>>.from(json['services'] ?? []),
      location: json['location'] != null
          ? Map<String, double>.from(json['location'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'addressText': addressText,
      'description': description,
      'deliveryDate': deliveryDate,
      'services': services,
      if (location != null) 'location': location,
    };
  }

}
