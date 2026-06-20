import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel 👑',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email?.split('@')[0] ?? 'Admin',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.admin_panel_settings,
                        color: Color(0xFF6C63FF)),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Stats Cards
              const Text(
                'Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),

              // Total Products
              productsAsync.when(
                data: (products) => Column(
                  children: [
                    Row(
                      children: [
                        _StatCard(
                          title: 'Total Products',
                          value: '${products.length}',
                          icon: Icons.inventory_2_outlined,
                          color: const Color(0xFF6C63FF),
                        ),
                        const SizedBox(width: 12),
                        // Total Orders
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('orders')
                              .snapshots(),
                          builder: (context, snapshot) {
                            final count =
                                snapshot.data?.docs.length ?? 0;
                            return _StatCard(
                              title: 'Total Orders',
                              value: '$count',
                              icon: Icons.receipt_long_outlined,
                              color: const Color(0xFFFF6584),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Total Revenue
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('orders')
                              .snapshots(),
                          builder: (context, snapshot) {
                            double revenue = 0;
                            if (snapshot.data != null) {
                              for (final doc in snapshot.data!.docs) {
                                revenue += (doc.data()
                                as Map)['totalAmount'] ??
                                    0;
                              }
                            }
                            return _StatCard(
                              title: 'Revenue',
                              value: 'Rs ${revenue.toInt()}',
                              icon: Icons.attach_money,
                              color: const Color(0xFF43C6AC),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          title: 'Categories',
                          value: '5',
                          icon: Icons.category_outlined,
                          color: const Color(0xFFFFB347),
                        ),
                      ],
                    ),
                  ],
                ),
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF))),
                error: (e, _) =>
                    Center(child: Text('Error: $e')),
              ),

              const SizedBox(height: 28),

              // Recent Orders
              const Text(
                'Recent Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .orderBy('createdAt', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6C63FF)));
                  }

                  final orders = snapshot.data!.docs;

                  if (orders.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'No orders yet',
                          style: TextStyle(
                              color: Colors.grey.shade500),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: orders.map((doc) {
                      final data =
                      doc.data() as Map<String, dynamic>;
                      return _RecentOrderTile(data: data);
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border:
          Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RecentOrderTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';
    Color statusColor;
    switch (status) {
      case 'confirmed': statusColor = const Color(0xFF6C63FF); break;
      case 'shipped': statusColor = Colors.orange; break;
      case 'delivered': statusColor = Colors.green; break;
      default: statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_outlined,
                color: Color(0xFF6C63FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${data['id'] ?? ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data['userName'] ?? '',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs ${(data['totalAmount'] ?? 0).toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}