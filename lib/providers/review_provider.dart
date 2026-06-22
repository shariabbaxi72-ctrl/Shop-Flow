import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/review_model.dart';
import '../models/order_model.dart';
import 'auth_provider.dart';
import 'order_provider.dart';

// Product ke reviews
final reviewsProvider =
StreamProvider.family<List<ReviewModel>, String>((ref, productId) {
  return FirebaseFirestore.instance
      .collection('reviews')
      .where('productId', isEqualTo: productId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
      snap.docs.map((d) => ReviewModel.fromMap(d.data())).toList());
});

// Product ki average rating
final productRatingProvider =
StreamProvider.family<Map<String, dynamic>, String>((ref, productId) {
  return FirebaseFirestore.instance
      .collection('reviews')
      .where('productId', isEqualTo: productId)
      .snapshots()
      .map((snap) {
    if (snap.docs.isEmpty) return {'average': 0.0, 'count': 0};
    final total = snap.docs
        .map((d) => (d.data()['rating'] as num).toDouble())
        .reduce((a, b) => a + b);
    return {
      'average': total / snap.docs.length,
      'count': snap.docs.length,
    };
  });
});

// Check: user ne already rate kiya hai?
final userReviewProvider =
FutureProvider.family<ReviewModel?, String>((ref, productId) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  final snap = await FirebaseFirestore.instance
      .collection('reviews')
      .where('productId', isEqualTo: productId)
      .where('userId', isEqualTo: user.uid)
      .limit(1)
      .get();

  if (snap.docs.isEmpty) return null;
  return ReviewModel.fromMap(snap.docs.first.data());
});

// Check: user ka is product ka order delivered hai?
final canReviewProvider =
FutureProvider.family<bool, String>((ref, productId) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return false;

  // User ke delivered orders mein yeh product hai?
  final ordersSnap = await FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: user.uid)
      .where('status', isEqualTo: 'delivered')
      .get();

  for (final doc in ordersSnap.docs) {
    final data = doc.data();
    final items = data['items'] as List? ?? [];
    final hasProduct =
    items.any((item) => item['productId'] == productId);
    if (hasProduct) return true;
  }
  return false;
});

// Review submit karo + Firestore average update karo
Future<void> submitReview({
  required String productId,
  required String userId,
  required String userEmail,
  required String userName,
  required double rating,
  required String comment,
}) async {
  final db = FirebaseFirestore.instance;

  // Check: user ne pehle se review diya hua hai ya nahi
  final existingReview = await db
      .collection('reviews')
      .where('productId', isEqualTo: productId)
      .where('userId', isEqualTo: userId)
      .limit(1)
      .get();

  if (existingReview.docs.isNotEmpty) {
    throw Exception('You have already reviewed this product');
  }

  final id = const Uuid().v4();

  // Review save karo
  await db.collection('reviews').doc(id).set(
    ReviewModel(
      id: id,
      productId: productId,
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    ).toMap(),
  );

  // Product ka average rating update karo
  final reviewsSnap = await db
      .collection('reviews')
      .where('productId', isEqualTo: productId)
      .get();

  final total = reviewsSnap.docs
      .map((d) => (d.data()['rating'] as num).toDouble())
      .reduce((a, b) => a + b);

  final average = total / reviewsSnap.docs.length;

  await db.collection('products').doc(productId).update({
    'rating': double.parse(average.toStringAsFixed(1)),
    'reviewCount': reviewsSnap.docs.length,
  });
}