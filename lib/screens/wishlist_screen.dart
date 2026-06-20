import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import 'customer/product_detail_screen.dart';


class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Wishlist (${wishlist.length})',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          if (wishlist.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: const Text('Clear Wishlist'),
                    content: const Text(
                        'Remove all items from wishlist?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          for (final p in wishlist) {
                            ref
                                .read(wishlistProvider.notifier)
                                .removeFromWishlist(p.id);
                          }
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
      body: wishlist.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Wishlist is empty!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save products you love',
              style: TextStyle(
                  color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final product = wishlist[index];
                return _WishlistCard(product: product);
              },
            ),
          ),

          // Add all to cart button
          Container(
            padding: const EdgeInsets.all(16),
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
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    for (final p in wishlist) {
                      ref
                          .read(cartProvider.notifier)
                          .addToCart(p);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('All items added to cart!'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF6C63FF),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white),
                  label: const Text(
                    'Add All to Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistCard extends ConsumerWidget {
  final Product product;
  const _WishlistCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
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
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product.images.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: product.images[0],
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade100,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_outlined,
                      color: Colors.grey),
                ),
              )
                  : Container(
                width: 90,
                height: 90,
                color: Colors.grey.shade100,
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFF6C63FF).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Rs ${product.price.toInt()}',
                        style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Rs ${product.originalPrice!.toInt()}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      if (product.discountPercent != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6584)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${product.discountPercent}%',
                            style: const TextStyle(
                              color: Color(0xFFFF6584),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Add to cart
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(cartProvider.notifier)
                                .addToCart(product);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: const Text('Added to cart!'),
                                backgroundColor:
                                const Color(0xFF6C63FF),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Add to Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Remove from wishlist
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(wishlistProvider.notifier)
                              .removeFromWishlist(product.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.red.shade100),
                          ),
                          child: Icon(Icons.delete_outline,
                              color: Colors.red.shade400, size: 18),
                        ),
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
}