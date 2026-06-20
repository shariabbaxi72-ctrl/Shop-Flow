import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No orders yet!',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 8),
                  Text('Your orders will appear here',
                      style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(
                order: order,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OrderDetailScreen(order: order),
                  ),
                ),
              );
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

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed': return const Color(0xFF6C63FF);
      case 'shipped': return Colors.orange;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'confirmed': return Icons.check_circle_outline;
      case 'shipped': return Icons.local_shipping_outlined;
      case 'delivered': return Icons.done_all;
      case 'cancelled': return Icons.cancel_outlined;
      default: return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withOpacity(0.06),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${order.id}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                              fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(_formatDate(order.createdAt),
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(_statusIcon(order.status),
                            size: 14,
                            color: _statusColor(order.status)),
                        const SizedBox(width: 4),
                        Text(order.status.toUpperCase(),
                            style: TextStyle(
                                color:
                                _statusColor(order.status),
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...order.items.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                          BorderRadius.circular(10),
                          child: item.productImage.isNotEmpty
                              ? CachedNetworkImage(
                            imageUrl: item.productImage,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                Container(
                                  width: 50,
                                  height: 50,
                                  color:
                                  Colors.grey.shade100,
                                ),
                          )
                              : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey.shade100),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(item.productName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Color(0xFF1A1A2E)),
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(
                                'Qty: ${item.quantity}${item.selectedSize != null ? ' • Size: ${item.selectedSize}' : ''}',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rs ${(item.price * item.quantity).toInt()}',
                          style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  )),

                  if (order.items.length > 2)
                    Text('+${order.items.length - 2} more items',
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12)),

                  const Divider(height: 20),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text('Total Amount',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12)),
                          Text(
                            'Rs ${order.totalAmount.toInt()}',
                            style: const TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Cancel button — sirf confirmed orders pe
                          if (order.status == 'confirmed')
                            GestureDetector(
                              onTap: () =>
                                  _cancelOrder(context, order),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.red.shade200),
                                ),
                                child: Text('Cancel',
                                    style: TextStyle(
                                        color: Colors.red.shade400,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF)
                                  .withOpacity(0.08),
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Text('Details',
                                    style: TextStyle(
                                        color: Color(0xFF6C63FF),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios,
                                    size: 12,
                                    color: Color(0xFF6C63FF)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cancelOrder(BuildContext context, OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle),
                child: Icon(Icons.cancel_outlined,
                    color: Colors.red.shade400, size: 30),
              ),
              const SizedBox(height: 16),
              const Text('Cancel Order?',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 8),
              Text('Cancel order #${order.id}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                      ),
                      child: const Text('No',
                          style:
                          TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                      ),
                      child: const Text('Yes, Cancel',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .update({'status': 'cancelled'});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Order #${order.id} cancelled'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ============ ORDER DETAIL SCREEN ============
class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed': return const Color(0xFF6C63FF);
      case 'shipped': return Colors.orange;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Order #${order.id}',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                _statusColor(order.status).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _statusColor(order.status)
                        .withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    order.status == 'delivered'
                        ? Icons.check_circle_rounded
                        : order.status == 'cancelled'
                        ? Icons.cancel_rounded
                        : Icons.local_shipping_rounded,
                    color: _statusColor(order.status),
                    size: 48,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    order.status == 'confirmed'
                        ? 'Order Confirmed! 🎉'
                        : order.status == 'shipped'
                        ? 'Order Shipped! 📦'
                        : order.status == 'delivered'
                        ? 'Order Delivered! ✅'
                        : 'Order Cancelled ❌',
                    style: TextStyle(
                        color: _statusColor(order.status),
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  if (order.status != 'cancelled')
                    Text(
                      'Estimated: ${order.estimatedDays} business days',
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Progress Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Tracking',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 20),
                  _OrderProgressBar(status: order.status),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Order Info
            _buildSection(
              title: 'Order Information',
              child: Column(children: [
                _infoRow('Order ID', '#${order.id}'),
                _infoRow('Date', _formatDate(order.createdAt)),
                _infoRow('Payment', 'Cash on Delivery'),
                _infoRow('Status', order.status.toUpperCase(),
                    valueColor: _statusColor(order.status)),
              ]),
            ),

            const SizedBox(height: 12),

            // Delivery
            _buildSection(
              title: 'Delivery Details',
              child: Column(children: [
                _infoRow('Name', order.userName),
                _infoRow('Phone', order.phone),
                _infoRow('Address', order.address),
                _infoRow('City', order.city),
              ]),
            ),

            const SizedBox(height: 12),

            // Items
            _buildSection(
              title: 'Items (${order.items.length})',
              child: Column(
                children: order.items
                    .map((item) => Padding(
                  padding:
                  const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(10),
                        child: item.productImage.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl:
                          item.productImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorWidget:
                              (_, __, ___) =>
                              Container(
                                width: 60,
                                height: 60,
                                color:
                                Colors.grey.shade100,
                              ),
                        )
                            : Container(
                            width: 60,
                            height: 60,
                            color:
                            Colors.grey.shade100),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(item.productName,
                                style: const TextStyle(
                                    fontWeight:
                                    FontWeight.w600,
                                    fontSize: 14,
                                    color:
                                    Color(0xFF1A1A2E))),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              children: [
                                _chip(
                                    'Qty: ${item.quantity}',
                                    Colors.grey.shade100,
                                    Colors.grey.shade600),
                                if (item.selectedSize !=
                                    null)
                                  _chip(
                                      'Size: ${item.selectedSize}',
                                      const Color(0xFF6C63FF)
                                          .withOpacity(0.08),
                                      const Color(
                                          0xFF6C63FF)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs ${(item.price * item.quantity).toInt()}',
                        style: const TextStyle(
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 12),

            // Price Summary
            _buildSection(
              title: 'Price Summary',
              child: Column(children: [
                _infoRow('Subtotal',
                    'Rs ${order.totalAmount.toInt()}'),
                _infoRow('Delivery', 'Free',
                    valueColor: Colors.green),
                const Divider(height: 16),
                _infoRow('Total',
                    'Rs ${order.totalAmount.toInt()}',
                    isBold: true,
                    valueColor: const Color(0xFF6C63FF)),
              ]),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(6)),
    child:
    Text(text, style: TextStyle(color: fg, fontSize: 11)),
  );

  Widget _buildSection(
      {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 13)),
          Flexible(
            child: Text(value,
                style: TextStyle(
                    color: valueColor ?? const Color(0xFF1A1A2E),
                    fontSize: 13,
                    fontWeight: isBold
                        ? FontWeight.w700
                        : FontWeight.w500),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Progress Bar Widget
class _OrderProgressBar extends StatelessWidget {
  final String status;
  const _OrderProgressBar({required this.status});

  int get _step {
    switch (status) {
      case 'confirmed': return 0;
      case 'shipped': return 1;
      case 'delivered': return 2;
      default: return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined,
                color: Colors.red.shade400),
            const SizedBox(width: 10),
            Text('Order Cancelled',
                style: TextStyle(
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    final steps = [
      {'label': 'Confirmed', 'icon': Icons.check_circle_outline},
      {'label': 'Shipped', 'icon': Icons.local_shipping_outlined},
      {'label': 'Delivered', 'icon': Icons.done_all},
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final done = _step > stepIndex;
          return Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: done
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }

        final stepIndex = i ~/ 2;
        final done = _step >= stepIndex;
        final current = _step == stepIndex;
        final step = steps[stepIndex];

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: done
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: current
                    ? Border.all(
                    color: const Color(0xFF6C63FF), width: 2)
                    : null,
                boxShadow: current
                    ? [
                  BoxShadow(
                      color: const Color(0xFF6C63FF)
                          .withOpacity(0.3),
                      blurRadius: 10)
                ]
                    : null,
              ),
              child: Icon(step['icon'] as IconData,
                  color: done ? Colors.white : Colors.grey,
                  size: 20),
            ),
            const SizedBox(height: 6),
            Text(step['label'] as String,
                style: TextStyle(
                    color: done
                        ? const Color(0xFF6C63FF)
                        : Colors.grey.shade400,
                    fontSize: 10,
                    fontWeight: done
                        ? FontWeight.w600
                        : FontWeight.w400)),
          ],
        );
      }),
    );
  }
}