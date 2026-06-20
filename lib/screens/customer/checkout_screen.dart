import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/pakistan_cities.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = false;

  final _emailController = TextEditingController();
  String _selectedCity = '';
  List<String> _citySuggestions = [];
  bool _showCitySuggestions = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cartItems = ref.read(cartProvider);
      final total = ref.read(cartTotalProvider);

      final orderItems = cartItems
          .map((item) => OrderItem(
        productId: item.product.id,
        productName: item.product.name,
        productImage: item.product.images.isNotEmpty
            ? item.product.images[0]
            : '',
        price: item.product.price,
        quantity: item.quantity,
        selectedSize: item.selectedSize,
      ))
          .toList();

      final order = await ref.read(orderProvider.notifier).placeOrder(
        userName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        items: orderItems,
        totalAmount: total,
      );

      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        setState(() => _isLoading = false);
        _showOrderSuccess(order);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOrderSuccess(OrderModel order) {
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
              const Text(
                'Order Confirmed! 🎉',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),

              // Order ID
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Order ID: ',
                      style: TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                    Text(
                      '#${order.id}',
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Estimated delivery
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping_outlined,
                        color: Colors.green.shade600, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Delivery',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${order.estimatedDays} business days',
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Order details sent to\n${order.userEmail}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              _buildSectionTitle('Order Summary'),
              const SizedBox(height: 12),
              Container(
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
                    ...cartItems.map((item) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: item.product.images.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: item.product.images[0],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade100,
                                    child: const Icon(
                                        Icons.image_outlined),
                                  ),
                            )
                                : Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade100,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                if (item.selectedSize != null)
                                  Text(
                                    'Size: ${item.selectedSize}',
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11),
                                  ),
                                Text(
                                  'Qty: ${item.quantity}',
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rs ${(item.product.price * item.quantity).toInt()}',
                            style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            'Rs ${total.toInt()}',
                            style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Delivery Details
              _buildSectionTitle('Delivery Details'),
              const SizedBox(height: 12),

              _buildFormField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline,
                validator: (val) =>
                val!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 12),
              _buildFormField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '03XX XXXXXXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) =>
                val!.isEmpty ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 12),
              _buildFormField(
                controller: _addressController,
                label: 'Address',
                hint: 'House #, Street, Area',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (val) =>
                val!.isEmpty ? 'Please enter address' : null,
              ),
              const SizedBox(height: 12),
              // City field with search
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _cityController,
                    onChanged: (val) {
                      setState(() {
                        _selectedCity = val;
                        _citySuggestions = PakistanCities.search(val);
                        _showCitySuggestions = val.isNotEmpty;
                      });
                    },
                    validator: (val) =>
                    val!.isEmpty ? 'Please enter city' : null,
                    style: const TextStyle(
                        color: Color(0xFF1A1A2E), fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'City',
                      hintText: 'Search city...',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13),
                      prefixIcon: const Icon(
                          Icons.location_city_outlined,
                          color: Color(0xFF6C63FF),
                          size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                        BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF6C63FF), width: 1.5),
                      ),
                    ),
                  ),
                  if (_showCitySuggestions &&
                      _citySuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border:
                        Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _citySuggestions.length > 5
                            ? 5
                            : _citySuggestions.length,
                        itemBuilder: (context, i) {
                          final city = _citySuggestions[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on,
                                color: Color(0xFF6C63FF), size: 16),
                            title: Text(city,
                                style: const TextStyle(
                                    color: Color(0xFF1A1A2E),
                                    fontSize: 13)),
                            onTap: () {
                              _cityController.text = city;
                              setState(() {
                                _selectedCity = city;
                                _showCitySuggestions = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Payment method
              _buildSectionTitle('Payment Method'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF6C63FF)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.money,
                          color: Color(0xFF6C63FF)),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cash on Delivery',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Pay when you receive',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF6C63FF)),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Place Order button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    'Place Order — Rs ${total.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
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
          const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
      ),
    );
  }
}