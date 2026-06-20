import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String? selectedSize;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedSize,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize,
    );
  }

  double get totalPrice => product.price * quantity;
}