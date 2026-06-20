class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String phone;
  final String address;
  final String city;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final int estimatedDays;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.phone,
    required this.address,
    required this.city,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.estimatedDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'phone': phone,
      'address': address,
      'city': city,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'estimatedDays': estimatedDays,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      items: (map['items'] as List)
          .map((e) => OrderItem.fromMap(e))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
      estimatedDays: map['estimatedDays'] ?? 5,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String? selectedSize;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.selectedSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'selectedSize': selectedSize,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      selectedSize: map['selectedSize'],
    );
  }
}