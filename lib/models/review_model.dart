class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userEmail;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'productId': productId,
    'userId': userId,
    'userEmail': userEmail,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ReviewModel.fromMap(Map<String, dynamic> map) => ReviewModel(
    id: map['id'] ?? '',
    productId: map['productId'] ?? '',
    userId: map['userId'] ?? '',
    userEmail: map['userEmail'] ?? '',
    userName: map['userName'] ?? '',
    rating: (map['rating'] ?? 0).toDouble(),
    comment: map['comment'] ?? '',
    createdAt: DateTime.parse(map['createdAt']),
  );
}