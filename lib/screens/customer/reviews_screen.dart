import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  final Product product;
  const ReviewsScreen({super.key, required this.product});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  double _selectedRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) {
      _showSnack('Please select a star rating', isError: true);
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      _showSnack('Please write a review', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(authStateProvider).value!;
      await submitReview(
        productId: widget.product.id,
        userId: user.uid,
        userEmail: user.email ?? '',
        userName: user.email?.split('@')[0] ?? 'User',
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );
      if (mounted) {
        _showSnack('Review submitted! ✅', isError: false);
        _commentController.clear();
        setState(() => _selectedRating = 0);
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
      isError ? Colors.red.shade400 : const Color(0xFF6C63FF),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(reviewsProvider(widget.product.id));
    final ratingAsync = ref.watch(productRatingProvider(widget.product.id));
    final canReviewAsync = ref.watch(canReviewProvider(widget.product.id));
    final userReviewAsync = ref.watch(userReviewProvider(widget.product.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Reviews',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Summary Card
            ratingAsync.when(
              data: (data) => _RatingSummaryCard(
                average: (data['average'] as double),
                count: data['count'] as int,
                reviews: reviewsAsync.value ?? [],
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 16),

            // Write Review Section
            userReviewAsync.when(
              data: (existingReview) {
                if (existingReview != null) {
                  // Already reviewed
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF6C63FF).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF6C63FF), size: 20),
                            const SizedBox(width: 8),
                            const Text('Your Review',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6C63FF))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _StarRow(
                            rating: existingReview.rating, size: 20),
                        const SizedBox(height: 8),
                        Text(existingReview.comment,
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                height: 1.5)),
                        const SizedBox(height: 6),
                        Text(
                          'Submitted ${_formatDate(existingReview.createdAt)}',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 11),
                        ),
                      ],
                    ),
                  );
                }

                return canReviewAsync.when(
                  data: (canReview) {
                    if (!canReview) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.orange.shade600),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'You can review this product after it\'s delivered to you',
                                style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Write review form
                    return _WriteReviewCard(
                      selectedRating: _selectedRating,
                      controller: _commentController,
                      isSubmitting: _isSubmitting,
                      onRatingSelect: (r) =>
                          setState(() => _selectedRating = r),
                      onSubmit: _submit,
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                );
              },
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF6C63FF))),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 20),

            // Reviews List
            reviewsAsync.when(
              data: (reviews) {
                if (reviews.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.rate_review_outlined,
                              size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('No reviews yet',
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text('Be the first to review this product',
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Reviews (${reviews.length})',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 12),
                    ...reviews.map((r) => _ReviewCard(review: r)),
                  ],
                );
              },
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF6C63FF))),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// Rating Summary — average + bar chart
class _RatingSummaryCard extends StatelessWidget {
  final double average;
  final int count;
  final List<ReviewModel> reviews;

  const _RatingSummaryCard({
    required this.average,
    required this.count,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    // Count per star
    final starCounts = List.generate(5, (i) {
      final star = 5 - i;
      return reviews.where((r) => r.rating.round() == star).length;
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 12)
        ],
      ),
      child: Row(
        children: [
          // Left — big number
          Column(
            children: [
              Text(
                average.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              _StarRow(rating: average, size: 18),
              const SizedBox(height: 4),
              Text(
                '$count ${count == 1 ? 'review' : 'reviews'}',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(width: 20),

          // Right — bar chart per star
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final cnt = starCounts[i];
                final pct = count == 0 ? 0.0 : cnt / count;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Text('$star',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC107), size: 12),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: Colors.grey.shade100,
                            valueColor:
                            const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFFC107)),
                            minHeight: 7,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$cnt',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// Write Review Form
class _WriteReviewCard extends StatelessWidget {
  final double selectedRating;
  final TextEditingController controller;
  final bool isSubmitting;
  final Function(double) onRatingSelect;
  final VoidCallback onSubmit;

  const _WriteReviewCard({
    required this.selectedRating,
    required this.controller,
    required this.isSubmitting,
    required this.onRatingSelect,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Write a Review',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 14),

          // Star selector
          const Text('Your Rating',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final star = i + 1.0;
              return GestureDetector(
                onTap: () => onRatingSelect(star),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    star <= selectedRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: star <= selectedRating
                        ? const Color(0xFFFFC107)
                        : Colors.grey.shade300,
                    size: 36,
                  ),
                ),
              );
            }),
          ),

          if (selectedRating > 0) ...[
            const SizedBox(height: 6),
            Text(
              _ratingLabel(selectedRating),
              style: const TextStyle(
                  color: Color(0xFFFFC107),
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ],

          const SizedBox(height: 14),

          // Comment field
          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 300,
            style: const TextStyle(
                color: Color(0xFF1A1A2E), fontSize: 14),
            decoration: InputDecoration(
              hintText:
              'Share your experience with this product...',
              hintStyle: TextStyle(
                  color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: Color(0xFF6C63FF), width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : const Text('Submit Review',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(double r) {
    if (r == 1) return 'Poor';
    if (r == 2) return 'Fair';
    if (r == 3) return 'Good';
    if (r == 4) return 'Very Good';
    return 'Excellent! 🌟';
  }
}

// Individual Review Card
class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 2),
                    _StarRow(rating: review.rating, size: 14),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.6),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}

// Reusable star row
class _StarRow extends StatelessWidget {
  final double rating;
  final double size;
  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star_rounded,
              color: const Color(0xFFFFC107), size: size);
        } else if (i < rating) {
          return Icon(Icons.star_half_rounded,
              color: const Color(0xFFFFC107), size: size);
        } else {
          return Icon(Icons.star_outline_rounded,
              color: Colors.grey.shade300, size: size);
        }
      }),
    );
  }
}