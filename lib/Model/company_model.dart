class CompanyModel {
  final String name;
  final String address;
  final String phone;

  CompanyModel({
    required this.name,
    required this.address,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'phone': phone,
  };
}
