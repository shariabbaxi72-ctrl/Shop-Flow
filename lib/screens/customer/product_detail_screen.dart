import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  String _selectedSize = '';

  final List<String> _sizes = ['38', '39', '40', '41', '42', '43', '44'];

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // Provider se real wishlist state
    final isWishlisted = ref
        .watch(wishlistProvider.notifier)
        .isWishlisted(product.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: Color(0xFF1A1A2E)),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  ref
                      .read(wishlistProvider.notifier)
                      .toggleWishlist(product);
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    isWishlisted
                        ? Icons.favorite_rounded
                        : Icons.favorite_border,
                    size: 20,
                    color: isWishlisted
                        ? const Color(0xFFFF6584)
                        : Colors.grey,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  product.images.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: product.images[_selectedImageIndex],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6C63FF)),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_outlined,
                          color: Colors.grey, size: 64),
                    ),
                  )
                      : Container(color: Colors.grey.shade100),

                  if (product.discountPercent != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6584),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '-${product.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFF6C63FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        if (i < product.rating.floor()) {
                          return const Icon(Icons.star_rounded,
                              size: 18, color: Color(0xFFFFC107));
                        } else if (i < product.rating) {
                          return const Icon(Icons.star_half_rounded,
                              size: 18, color: Color(0xFFFFC107));
                        } else {
                          return const Icon(Icons.star_outline_rounded,
                              size: 18, color: Color(0xFFFFC107));
                        }
                      }),
                      const SizedBox(width: 6),
                      Text(
                        '${product.rating} (${product.reviewCount} reviews)',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price
                  Row(
                    children: [
                      Text(
                        'Rs ${product.price.toInt()}',
                        style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          'Rs ${product.originalPrice!.toInt()}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Size selector
                  if (product.category == 'Shoes') ...[
                    const Text(
                      'Select Size',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sizes.map((size) {
                        final isSelected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedSize = size),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6C63FF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF6C63FF)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                size,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Delivery info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined,
                            color: Color(0xFF6C63FF), size: 22),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Free Delivery',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Delivery in 3-5 business days',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom bar
      bottomNavigationBar: Container(
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
          child: Row(
            children: [
              // Wishlist button
              GestureDetector(
                onTap: () {
                  ref
                      .read(wishlistProvider.notifier)
                      .toggleWishlist(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isWishlisted
                            ? 'Removed from wishlist'
                            : 'Added to wishlist! ❤️',
                      ),
                      backgroundColor: isWishlisted
                          ? Colors.grey
                          : const Color(0xFFFF6584),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isWishlisted
                        ? const Color(0xFFFF6584).withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isWishlisted
                          ? const Color(0xFFFF6584)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Icon(
                    isWishlisted
                        ? Icons.favorite_rounded
                        : Icons.favorite_border,
                    color: isWishlisted
                        ? const Color(0xFFFF6584)
                        : Colors.grey,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Add to cart
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (product.category == 'Shoes' &&
                        _selectedSize.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          const Text('Please select a size first!'),
                          backgroundColor: Colors.red.shade400,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                      return;
                    }
                    ref.read(cartProvider.notifier).addToCart(
                      product,
                      selectedSize: _selectedSize.isEmpty
                          ? null
                          : _selectedSize,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Added to cart!'),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add to Cart',
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
    );
  }
}