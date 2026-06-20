import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // User ka role check karo
  Future<String> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['role'] ?? 'customer';
    }
    // Agar document nahi hai to customer banao
    await _db.collection('users').doc(uid).set({
      'role': 'customer',
      'createdAt': DateTime.now(),
    });
    return 'customer';
  }


  // Saare products lao
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Category se products filter karo
  Stream<List<Product>> getProductsByCategory(String category) {
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Product.fromMap(doc.data(), doc.id))
        .toList());
  }
}