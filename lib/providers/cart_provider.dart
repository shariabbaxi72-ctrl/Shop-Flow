import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

final cartProvider =
StateNotifierProvider<CartNotifier, List<CartItem>>(
      (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  // Cart mein add karo
  void addToCart(Product product, {String? selectedSize}) {
    final existingIndex = state.indexWhere(
          (item) =>
      item.product.id == product.id &&
          item.selectedSize == selectedSize,
    );

    if (existingIndex != -1) {
      // Already hai — quantity bardhao
      final updated = List<CartItem>.from(state);
      updated[existingIndex] = updated[existingIndex].copyWith(
        quantity: updated[existingIndex].quantity + 1,
      );
      state = updated;
    } else {
      // Naya item add karo
      state = [
        ...state,
        CartItem(
          product: product,
          quantity: 1,
          selectedSize: selectedSize,
        ),
      ];
    }
  }

  // Quantity bardhao
  void increaseQuantity(int index) {
    final updated = List<CartItem>.from(state);
    updated[index] =
        updated[index].copyWith(quantity: updated[index].quantity + 1);
    state = updated;
  }

  // Quantity ghatao
  void decreaseQuantity(int index) {
    if (state[index].quantity == 1) {
      removeFromCart(index);
      return;
    }
    final updated = List<CartItem>.from(state);
    updated[index] =
        updated[index].copyWith(quantity: updated[index].quantity - 1);
    state = updated;
  }

  // Remove karo
  void removeFromCart(int index) {
    final updated = List<CartItem>.from(state);
    updated.removeAt(index);
    state = updated;
  }

  // Cart clear karo
  void clearCart() => state = [];

  // Total price
  double get totalPrice =>
      state.fold(0, (sum, item) => sum + item.totalPrice);

  // Total items
  int get totalItems =>
      state.fold(0, (sum, item) => sum + item.quantity);
}

// Helper providers
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});