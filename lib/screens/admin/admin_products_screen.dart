import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';

class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        title: const Text('Products',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () =>
                _showAddProductSheet(context),
            icon: const Icon(Icons.add_circle_outline,
                color: Color(0xFF6C63FF)),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey.shade700),
                  const SizedBox(height: 12),
                  Text('No products yet',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showAddProductSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add,
                        color: Colors.white),
                    label: const Text('Add Product',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductAdminCard(
                product: product,
                onEdit: () =>
                    _showEditProductSheet(context, product),
                onDelete: () =>
                    _deleteProduct(context, product.id),
              );
            },
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(
                color: Color(0xFF6C63FF))),
        error: (e, _) =>
            Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductSheet(context),
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _deleteProduct(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Product',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'Are you sure? This cannot be undone.',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('products')
                  .doc(id)
                  .delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Product deleted'),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddProductSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ProductForm(product: null),
    );
  }

  void _showEditProductSheet(
      BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ProductForm(product: product),
    );
  }
}

class _ProductAdminCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductAdminCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.images.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: product.images[0],
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: Colors.grey.shade800,
                child: const Icon(Icons.image_outlined,
                    color: Colors.grey),
              ),
            )
                : Container(
              width: 70,
              height: 70,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.category,
                    style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rs ${product.price.toInt()}',
                  style: const TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Column(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: Color(0xFF6C63FF), size: 18),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.delete_outline,
                      color: Colors.red.shade400, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Add/Edit Product Form
class _ProductForm extends StatefulWidget {
  final Product? product;
  const _ProductForm({required this.product});

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _imageController = TextEditingController();
  String _selectedCategory = 'Shoes';
  bool _isLoading = false;

  final _categories = [
    'Shoes', 'Clothing', 'Electronics', 'Accessories'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _originalPriceController.text =
          widget.product!.originalPrice?.toString() ?? '';
      _imageController.text = widget.product!.images.isNotEmpty
          ? widget.product!.images[0]
          : '';
      _selectedCategory = widget.product!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.parse(_priceController.text),
      'originalPrice': _originalPriceController.text.isNotEmpty
          ? double.parse(_originalPriceController.text)
          : null,
      'images': _imageController.text.isNotEmpty
          ? [_imageController.text.trim()]
          : [],
      'category': _selectedCategory,
      'rating': widget.product?.rating ?? 4.0,
      'reviewCount': widget.product?.reviewCount ?? 0,
      'isAvailable': true,
    };

    try {
      if (widget.product == null) {
        // Add new
        await FirebaseFirestore.instance
            .collection('products')
            .add(data);
      } else {
        // Update existing
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.product!.id)
            .update(data);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.product == null
              ? 'Product added! ✅'
              : 'Product updated! ✅'),
          backgroundColor: const Color(0xFF6C63FF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.product == null
                  ? 'Add New Product'
                  : 'Edit Product',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            _buildField(_nameController, 'Product Name *', false),
            const SizedBox(height: 12),
            _buildField(_descController, 'Description', false),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                    child: _buildField(
                        _priceController, 'Price *', true)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildField(
                        _originalPriceController,
                        'Original Price',
                        true)),
              ],
            ),
            const SizedBox(height: 12),

            // Category dropdown
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  isExpanded: true,
                  items: _categories
                      .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  ))
                      .toList(),
                  onChanged: (val) => setState(
                          () => _selectedCategory = val!),
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildField(
                _imageController, 'Image URL', false),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)
                    : Text(
                  widget.product == null
                      ? 'Add Product'
                      : 'Save Changes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller,
      String hint, bool isNumber) {
    return TextField(
      controller: controller,
      keyboardType:
      isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: const Color(0xFF0F0F1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFF6C63FF)),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
      ),
    );
  }
}