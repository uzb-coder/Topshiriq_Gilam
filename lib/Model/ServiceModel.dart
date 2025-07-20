class Services {
  final String id;
  final String name;
  final int price;
  final String unit;
  final String description;

  Services({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.description,
  });

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      id: json['_id'] ?? '',
      name: json['title'] ?? '',
      price: json['price'] ?? 0,
      unit: json['unit'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
