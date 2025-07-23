class CompanyModel {
  final String name;
  final String address;
  final String phone;

  CompanyModel({
    required this.name,
    required this.address,
    required this.phone,
  });


  // Bu yerda toJson metodini qo‘shamiz
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
    };
  }

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
