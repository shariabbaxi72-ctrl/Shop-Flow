import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shopflow/screens/customer/product_detail_screen.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final categories = [
      'All', 'Shoes', 'Clothing', 'Electronics', 'Accessories'
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Explore',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref
                      .read(searchQueryProvider.notifier)
                      .state =
                      val.toLowerCase().trim();
                },
                decoration: InputDecoration(
                  hintText: 'Search by name, category...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon:
                  Icon(Icons.search, color: Colors.grey.shade400),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      ref
                          .read(searchQueryProvider.notifier)
                          .state = '';
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                    const BorderSide(color: Color(0xFF6C63FF)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Categories
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(selectedCategoryProvider.notifier)
                          .state = cat;
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: productsAsync.when(
                data: (products) {
                  final filtered = _filterProducts(
                      products, searchQuery, selectedCategory);
                  return Text(
                    '${filtered.length} products found',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ),

            const SizedBox(height: 10),

            // Products Grid
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  final filtered = _filterProducts(
                      products, searchQuery, selectedCategory);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            searchQuery.isNotEmpty
                                ? 'No results for "$searchQuery"'
                                : 'No products in this category',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _ProductCard(product: filtered[index]),
                  );
                },
                loading: () =>
                const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF6C63FF)),
                ),
                error: (e, _) =>
                    Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter logic — name, category, description sab match karo
  List<Product> _filterProducts(List<Product> products, String query,
      String category) {
    return products.where((p) {
      // Category filter
      final matchCategory = category == 'All' ||
          p.category.toLowerCase() == category.toLowerCase();

      if (query.isEmpty) return matchCategory;

      // Har word ko alag check karo
      final words = query.toLowerCase().split(' ');

      final searchableText = [
        p.name.toLowerCase(),
        p.description.toLowerCase(),
        p.category.toLowerCase(),
      ].join(' ');

      // Har word match ho
      final matchSearch = words.every(
            (word) => word.isEmpty || searchableText.contains(word),
      );

      return matchCategory && matchSearch;
    }).toList();
  }
}


class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
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
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    )
                        : Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_outlined,
                          color: Colors.grey),
                    ),
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
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    // Wishlist
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                              size: 14, color: Color(0xFFFFC107));
                        } else if (i < product.rating) {
                          return const Icon(Icons.star_half_rounded,
                              size: 14, color: Color(0xFFFFC107));
                        } else {
                          return const Icon(Icons.star_outline_rounded,
                              size: 14, color: Color(0xFFFFC107));
                        }
                      }),
                      const SizedBox(width: 4),
                      Text(
                          '${product.rating}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Rs ${product.price.toInt()}',
                        style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          'Rs ${product.originalPrice!.toInt()}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
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