
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../models/product.dart';
import 'main_screen.dart';
import 'notifications_screen.dart';
import 'product_detail_screen.dart';

// Home screen category provider
final homeCategoryProvider = StateProvider<String>((ref) => 'All');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final selectedCategory = ref.watch(homeCategoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Good day! 👋',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Consumer(
                          builder: (context, ref, _) {
                            final user =
                                ref.watch(authStateProvider).value;
                            return Text(
                              user?.email?.split('@')[0] ?? 'Shopper',
                              style: const TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        // Order status watcher active karo
                        ref.watch(orderStatusWatcherProvider);
                        final unread = ref.watch(unreadCountProvider);

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotificationsScreen()),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Color(0xFF6C63FF),
                                ),
                              ),
                              if (unread > 0)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF6584),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$unread',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () =>
                  ref.read(currentTabProvider.notifier).state = 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Search products...',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.tune,
                              color: Color(0xFF6C63FF), size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9C94FF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 30,
                        bottom: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '🔥 Limited Offer',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Up to 25% + OFF\non all products!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Shop Now →',
                                  style: TextStyle(
                                    color: Color(0xFF6C63FF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Categories
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _CategoryItem(
                          label: 'All',
                          emoji: '🛍️',
                          color: const Color(0xFF6C63FF),
                          isSelected: selectedCategory == 'All',
                        ),
                        _CategoryItem(
                          label: 'Shoes',
                          emoji: '👟',
                          color: const Color(0xFFFF6584),
                          isSelected: selectedCategory == 'Shoes',
                        ),
                        _CategoryItem(
                          label: 'Clothing',
                          emoji: '👕',
                          color: const Color(0xFF43C6AC),
                          isSelected: selectedCategory == 'Clothing',
                        ),
                        _CategoryItem(
                          label: 'Electronics',
                          emoji: '⌚',
                          color: const Color(0xFFFFB347),
                          isSelected:
                          selectedCategory == 'Electronics',
                        ),
                        _CategoryItem(
                          label: 'Accessories',
                          emoji: '👜',
                          color: const Color(0xFF9C27B0),
                          isSelected:
                          selectedCategory == 'Accessories',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Products heading
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCategory == 'All'
                          ? 'Featured Products'
                          : selectedCategory,
                      style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    productsAsync.when(
                      data: (products) {
                        final count = selectedCategory == 'All'
                            ? products.length
                            : products
                            .where((p) =>
                        p.category == selectedCategory)
                            .length;
                        return Text(
                          '$count items',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Products Grid
            productsAsync.when(
              data: (products) {
                final filtered = selectedCategory == 'All'
                    ? products
                    : products
                    .where((p) => p.category == selectedCategory)
                    .toList();

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Text('😕',
                                style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              'No products in $selectedCategory',
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                          _ProductCard(product: filtered[index]),
                      childCount: filtered.length,
                    ),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF))),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $e')),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }
}

// Beautiful Category Item
class _CategoryItem extends ConsumerWidget {
  final String label;
  final String emoji;
  final Color color;
  final bool isSelected;

  const _CategoryItem({
    required this.label,
    required this.emoji,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
      ref.read(homeCategoryProvider.notifier).state = label,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
                    : [],
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : Colors.grey.shade500,
                fontSize: 11,
                fontWeight: isSelected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref
        .watch(wishlistProvider.notifier)
        .isWishlisted(product.id);

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.images.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: product.images[0],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image_outlined,
                            color: Colors.grey),
                      ),
                    )
                        : Container(color: Colors.grey.shade100),

                    // Discount badge
                    if (product.discountPercent != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6584),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${product.discountPercent}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                    // Wishlist
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => ref
                            .read(wishlistProvider.notifier)
                            .toggleWishlist(product),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isWishlisted
                                ? const Color(0xFFFF6584)
                                .withOpacity(0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
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
                            size: 17,
                            color: isWishlisted
                                ? const Color(0xFFFF6584)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        if (i < product.rating.floor()) {
                          return const Icon(Icons.star_rounded,
                              size: 12, color: Color(0xFFFFC107));
                        } else if (i < product.rating) {
                          return const Icon(Icons.star_half_rounded,
                              size: 12, color: Color(0xFFFFC107));
                        } else {
                          return const Icon(Icons.star_outline_rounded,
                              size: 12, color: Color(0xFFFFC107));
                        }
                      }),
                      const SizedBox(width: 3),
                      Text('${product.rating}',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs ${product.price.toInt()}',
                            style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (product.originalPrice != null)
                            Text(
                              'Rs ${product.originalPrice!.toInt()}',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      // Add to cart mini button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 18),
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