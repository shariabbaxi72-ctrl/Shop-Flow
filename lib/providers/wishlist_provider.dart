import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/product.dart';

final wishlistProvider =
StateNotifierProvider<WishlistNotifier, List<Product>>(
      (ref) => WishlistNotifier(),
);

class WishlistNotifier extends StateNotifier<List<Product>> {
  WishlistNotifier() : super([]);

  void toggleWishlist(Product product) {
    final exists = state.any((p) => p.id == product.id);
    if (exists) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }
  }

  bool isWishlisted(String productId) {
    return state.any((p) => p.id == productId);
  }

  void removeFromWishlist(String productId) {
    state = state.where((p) => p.id != productId).toList();
  }
}

final wishlistCountProvider = Provider<int>((ref) {
  return ref.watch(wishlistProvider).length;
});