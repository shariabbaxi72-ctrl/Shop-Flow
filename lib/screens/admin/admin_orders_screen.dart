import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        title: const Text('All Orders',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF6C63FF)));
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey.shade700),
                  const SizedBox(height: 12),
                  Text('No orders yet',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data =
              orders[index].data() as Map<String, dynamic>;
              final docId = orders[index].id;
              return _AdminOrderCard(
                  data: data, docId: docId);
            },
          );
        },
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const _AdminOrderCard(
      {required this.data, required this.docId});

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
    final status = data['status'] ?? 'pending';
    final items =
        (data['items'] as List?)?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _statusColor(status).withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${data['id'] ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _infoRow(Icons.phone_outlined,
                    data['phone'] ?? ''),
                const SizedBox(height: 6),
                _infoRow(Icons.location_on_outlined,
                    '${data['address']}, ${data['city']}'),
                const SizedBox(height: 6),
                _infoRow(Icons.shopping_bag_outlined,
                    '$items items'),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs ${(data['totalAmount'] ?? 0).toInt()}',
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    // Status update dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F1A),
                        borderRadius:
                        BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white
                                .withOpacity(0.1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: status,
                          dropdownColor:
                          const Color(0xFF1A1A2E),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12),
                          isDense: true,
                          items: [
                            'confirmed',
                            'shipped',
                            'delivered',
                            'cancelled'
                          ]
                              .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s
                                .toUpperCase()),
                          ))
                              .toList(),
                          onChanged: (val) async {
                            await FirebaseFirestore
                                .instance
                                .collection('orders')
                                .doc(docId)
                                .update({'status': val});
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Status updated to $val'),
                                backgroundColor:
                                _statusColor(val!),
                                behavior:
                                SnackBarBehavior
                                    .floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        10)),
                                margin:
                                const EdgeInsets.all(16),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                color: Colors.grey.shade400, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}