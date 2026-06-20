import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationsProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E))),
        actions: [
          TextButton(
            onPressed: () async {
              if (user != null) await markAllRead(user.uid);
            },
            child: const Text('Mark all read',
                style: TextStyle(color: Color(0xFF6C63FF))),
          ),
        ],
      ),
      body: notifAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No notifications yet',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 8),
                  Text('Order updates will appear here',
                      style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _NotifCard(notif: notif, userId: user?.uid ?? '');
            },
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(
                color: Color(0xFF6C63FF))),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationModel notif;
  final String userId;
  const _NotifCard({required this.notif, required this.userId});

  Color _color() {
    if (notif.title.contains('Shipped')) return Colors.orange;
    if (notif.title.contains('Delivered')) return Colors.green;
    if (notif.title.contains('Cancelled')) return Colors.red;
    return const Color(0xFF6C63FF);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(notif.id)
            .update({'isRead': true});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead
              ? Colors.white
              : _color().withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead
                ? Colors.grey.shade200
                : _color().withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _color().withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  notif.title.split(' ')[0],
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            color: const Color(0xFF1A1A2E),
                            fontWeight: notif.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _color(),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notif.createdAt),
                    style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}