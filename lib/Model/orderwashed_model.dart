class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    final location = Location(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
    return location;
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
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
    print("🛠️ Service JSON: $json");
    print("🔥 boshqa: ${json['price']}");

    final service = ServiceModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      width: int.tryParse(json['width']?.toString() ?? '') ?? 0,
      height: int.tryParse(json['height']?.toString() ?? '') ?? 0,
      area: int.tryParse(json['area']?.toString() ?? '') ?? 0,
      status: json['status'] ?? '',
      price: int.tryParse(json['price']?.toString() ?? '') ?? 0,
      pricePerSquareMeter: int.tryParse(json['pricePerSquareMeter']?.toString() ?? '') ?? 0,
    );

    return service;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'quantity': quantity,
      'width': width,
      'height': height,
      'area': area,
      'status': status,
      'price': price,
      'pricePerSquareMeter': pricePerSquareMeter,
    };
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
    print("🚀 KELGAN JSON: $json");
    // JSON ning har bir kalitini alohida chiqarish
    json.forEach((key, value) {
      print("🔑 $key: $value (${value.runtimeType})");
    });
    print("═══════════════════════════════════════");

    final serviceList = (json['services'] as List?);
    print("📋 Services List: $serviceList");
    print("📋 Services Count: ${serviceList?.length ?? 0}");

    final parsedServices = serviceList?.map((e) {
      print("🔄 Processing service: $e");
      return ServiceModel.fromJson(e);
    }).toList() ?? [];

    print("🔥 jami sum: ${json['totalSum']}");
    print("🔥 totalPrice: ${json['totalSum']}");
    print("🔥 Yetkazish sanan: ${json['createdAt']}");
    print("🔥 deliveryDate: ${json['deliveryDate']}");
    print("🔥 firstName: ${json['firstName']}");
    print("🔥 lastName: ${json['lastName']}");
    print("🔥 phone: ${json['phone']}");
    print("🔥 addressText: ${json['addressText']}");
    print("🔥 location: ${json['location']}");

    final order = OrderwashedModel(
      id: json['id'] ?? json['_id'] ?? '',
      clientName: "${json['firstName'] ?? ''} ${json['lastName'] ?? ''}".trim(),
      phone: json['phone'] ?? '',
      address: json['addressText'] ?? '',
      deliveryDate: json['deliveryDate']?.toString().substring(0, 10) ?? '',
      totalSum: int.tryParse(json['totalSum']?.toString() ?? '') ?? 0,
      services: parsedServices,
      createdAt: json['createdAt'] ?? '',
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
    );

    order.printDetails();
    return order;
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'firstName': clientName.split(" ").first,
      'lastName': clientName.split(" ").length > 1 ? clientName.split(" ")[1] : '',
      'phone': phone,
      'addressText': address,
      'deliveryDate': deliveryDate,
      'totalPrice': totalSum,
      'services': services.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'location': location?.toJson(),
    };
    return json;
  }

  void printDetails() {
    print("📦 ORDER DETAILS:");
    print("═══════════════════════════════════════");
    print("🆔 ID: $id");
    print("👤 Client Name: $clientName");
    print("📞 Phone: $phone");
    print("📍 Address: $address");
    print("📅 Delivery Date: $deliveryDate");
    print("💰 Total Sum: $totalSum");
    print("📋 Services Count: ${services.length}");
    print("🕐 Created At: $createdAt");
    print("🗺️ Location: ${location != null ? 'Available' : 'Not Available'}");

    if (services.isNotEmpty) {
      print("📋 SERVICES LIST:");
      for (int i = 0; i < services.length; i++) {
        print("   ${i + 1}. ${services[i].title} - ${services[i].price} so'm");
      }
    }
    print("═══════════════════════════════════════");
  }
}
