class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.category,
    required this.rating,
    required this.reviewCount,
    this.isAvailable = true,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['originalPrice']?.toDouble(),
      images: List<String>.from(map['images'] ?? []),
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'images': images,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
    };
  }

  int? get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }
}