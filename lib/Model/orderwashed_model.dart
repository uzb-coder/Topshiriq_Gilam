class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }
}

class ServiceModel {
  final String id;
  final String title;
  final int quantity;
  final int width;
  final int height;
  final int area;
  final String status;
  final int price;
  final int pricePerSquareMeter;

  ServiceModel({
    required this.id,
    required this.title,
    required this.quantity,
    required this.width,
    required this.height,
    required this.area,
    required this.status,
    required this.price,
    required this.pricePerSquareMeter,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      quantity: json['quantity'] ?? 0,
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      area: json['area'] ?? 0,
      status: json['status'] ?? '',
      price: json['price'] ?? 0,
      pricePerSquareMeter: json['pricePerSquareMeter'] ?? 0,
    );
  }
}

class OrderwashedModel {
  final String id;
  final String clientName;
  final String phone;
  final String address;
  final String deliveryDate;
  final int totalSum;
  final List<ServiceModel> services;
  final String createdAt;
  final Location? location;

  OrderwashedModel({
    required this.id,
    required this.clientName,
    required this.phone,
    required this.address,
    required this.deliveryDate,
    required this.totalSum,
    required this.services,
    required this.createdAt,
    required this.location,
  });

  factory OrderwashedModel.fromJson(Map<String, dynamic> json) {
    return OrderwashedModel(
      clientName: "${json['firstName'] ?? ''} ${json['lastName'] ?? ''}",
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      address: json['addressText'] ?? '',
      deliveryDate: json['deliveryDate']?.substring(0, 10) ?? '',
      totalSum: json['totalPrice'] ?? 0,
      services: (json['services'] as List? ?? [])
          .map((e) => ServiceModel.fromJson(e))
          .toList(),
      createdAt: json['createdAt'] ?? '',
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
    );
  }
}
