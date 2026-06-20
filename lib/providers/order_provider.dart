import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import 'auth_provider.dart';

final orderProvider =
StateNotifierProvider<OrderNotifier, List<OrderModel>>(
      (ref) => OrderNotifier(ref),
);

class OrderNotifier extends StateNotifier<List<OrderModel>> {
  final Ref _ref;
  final _db = FirebaseFirestore.instance;

  OrderNotifier(this._ref) : super([]) {
    _loadOrders();
  }

  void _loadOrders() {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return;

    _db
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<OrderModel> placeOrder({
    required String userName,
    required String phone,
    required String address,
    required String city,
    required List<OrderItem> items,
    required double totalAmount,
  }) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) throw Exception('Not logged in');

    final orderId = const Uuid().v4().substring(0, 8).toUpperCase();
    final order = OrderModel(
      id: orderId,
      userId: user.uid,
      userEmail: user.email ?? '',
      userName: userName,
      phone: phone,
      address: address,
      city: city,
      items: items,
      totalAmount: totalAmount,
      status: 'confirmed',
      createdAt: DateTime.now(),
      estimatedDays: 5,
    );

    await _db.collection('orders').doc(orderId).set(order.toMap());
    return order;
  }
}

final userOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
      snap.docs.map((d) => OrderModel.fromMap(d.data())).toList());
});