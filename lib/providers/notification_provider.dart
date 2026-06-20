import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../models/order_model.dart';
import 'auth_provider.dart';
import 'order_provider.dart';

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
      .map((d) => NotificationModel.fromMap(d.data()))
      .toList());
});

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).value
      ?.where((n) => !n.isRead)
      .length ?? 0;
});

// Order status change detect karo
final orderStatusWatcherProvider = StreamProvider<void>((ref) {
  final user = ref.watch(authStateProvider).value;
  print('Watcher started for user: ${user?.uid}'); // Debug 1

  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .asyncMap((snap) async {
    print('Snapshot received, docs: ${snap.docs.length}, changes: ${snap.docChanges.length}'); // Debug 2

    for (final change in snap.docChanges) {
      print('Change type: ${change.type}, doc: ${change.doc.id}'); // Debug 3

      if (change.type == DocumentChangeType.modified) {
        final data = change.doc.data()!;
        final status = data['status'];
        final orderId = data['id'];

        String title = '';
        String body = '';

        switch (status) {
          case 'shipped':
            title = '📦 Order Shipped!';
            body = 'Your order #$orderId has been shipped. On the way!';
            break;
          case 'delivered':
            title = '✅ Order Delivered!';
            body = 'Your order #$orderId has been delivered. Enjoy!';
            break;
          case 'cancelled':
            title = '❌ Order Cancelled';
            body = 'Your order #$orderId has been cancelled.';
            break;
        }

        if (title.isNotEmpty) {
          final notifId = DateTime.now().millisecondsSinceEpoch.toString();
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(notifId)
              .set({
            'id': notifId,
            'userId': user.uid,
            'title': title,
            'body': body,
            'type': 'order_update',
            'orderId': orderId,
            'createdAt': DateTime.now().toIso8601String(),
            'isRead': false,
          });
        }
      }
    }
  });
});

// Mark all as read
Future<void> markAllRead(String userId) async {
  final batch = FirebaseFirestore.instance.batch();
  final snap = await FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('isRead', isEqualTo: false)
      .get();

  for (final doc in snap.docs) {
    batch.update(doc.reference, {'isRead': true});
  }
  await batch.commit();
}