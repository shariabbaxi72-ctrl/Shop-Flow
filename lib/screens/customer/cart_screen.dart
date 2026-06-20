import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'My Cart (${cartItems.length})',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: const Text('Clear Cart'),
                    content: const Text('Remove all items from cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clearCart();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear',
                  style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Cart is empty!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add products to get started',
              style: TextStyle(
                  color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                // Har item ka total
                final itemTotal =
                    item.product.price * item.quantity;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(12),
                            child: item.product.images.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl:
                              item.product.images[0],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade100,
                                  ),
                              errorWidget: (_, __, ___) =>
                                  Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade100,
                                    child: const Icon(
                                        Icons.image_outlined),
                                  ),
                            )
                                : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade100,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Product info
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontWeight:
                                          FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                        maxLines: 1,
                                        overflow:
                                        TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Delete button
                                    GestureDetector(
                                      onTap: () => ref
                                          .read(
                                          cartProvider.notifier)
                                          .removeFromCart(index),
                                      child: Container(
                                        padding:
                                        const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius:
                                          BorderRadius.circular(
                                              8),
                                        ),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red.shade400,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                if (item.selectedSize != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C63FF)
                                          .withOpacity(0.08),
                                      borderRadius:
                                      BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Size: ${item.selectedSize}',
                                      style: const TextStyle(
                                        color: Color(0xFF6C63FF),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 10),

                                // Price + Quantity row
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Unit price
                                    Text(
                                      'Rs ${item.product.price.toInt()} x ${item.quantity}',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),

                                    // Quantity +/-
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6C63FF)
                                            .withOpacity(0.08),
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => ref
                                                .read(cartProvider
                                                .notifier)
                                                .decreaseQuantity(
                                                index),
                                            child: Container(
                                              padding:
                                              const EdgeInsets
                                                  .all(6),
                                              child: const Icon(
                                                Icons.remove,
                                                size: 16,
                                                color:
                                                Color(0xFF6C63FF),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 28,
                                            alignment:
                                            Alignment.center,
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontWeight:
                                                FontWeight.w700,
                                                color: Color(
                                                    0xFF1A1A2E),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => ref
                                                .read(cartProvider
                                                .notifier)
                                                .increaseQuantity(
                                                index),
                                            child: Container(
                                              padding:
                                              const EdgeInsets
                                                  .all(6),
                                              child: const Icon(
                                                Icons.add,
                                                size: 16,
                                                color:
                                                Color(0xFF6C63FF),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Item total
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Item Total',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Rs ${itemTotal.toInt()}',
                              style: const TextStyle(
                                color: Color(0xFF6C63FF),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Each product summary
                  ...cartItems.map((item) => Padding(
                    padding:
                    const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.product.name} x${item.quantity}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Rs ${(item.product.price * item.quantity).toInt()}',
                          style: const TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )),

                  const Divider(height: 20),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delivery',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13)),
                      const Text('Free',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Rs ${total.toInt()}',
                        style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderSuccess(BuildContext context, WidgetRef ref) {
    ref.read(cartProvider.notifier).clearCart();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEBFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF6C63FF), size: 44),
              ),
              const SizedBox(height: 20),
              const Text('Order Placed! 🎉',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 8),
              const Text(
                'Your order has been placed!\nDelivery in 3-5 business days.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Continue Shopping',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}