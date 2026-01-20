import 'dart:io';

import 'package:flutter/material.dart';
import 'package:store/features/auth/data/session_store.dart';
import 'package:store/features/auth/presentation/screens/login_page.dart';
import 'package:store/features/cart/data/models/cart_item.dart';
import 'package:store/features/cart/data/services/cart_service.dart';
import 'package:store/features/checkout/presentation/screens/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late CartService _cartService;
  final Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _cartService = CartService();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {
      // Remove selections for items no longer in cart
      _selectedItems.removeWhere(
        (id) => !_cartService.items.any((item) => item.id == id),
      );
    });
  }

  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedItems.length == _cartService.items.length) {
        _selectedItems.clear();
      } else {
        _selectedItems.addAll(_cartService.items.map((item) => item.id));
      }
    });
  }

  double _getSelectedTotal() {
    return _cartService.items
        .where((item) => _selectedItems.contains(item.id))
        .fold(0.0, (sum, item) => sum + (item.variety.price * item.quantity));
  }

  int _getSelectedCount() {
    return _cartService.items
        .where((item) => _selectedItems.contains(item.id))
        .fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartService.items;
    final selectedCount = _getSelectedCount();
    final selectedTotal = _getSelectedTotal();
    final isAllSelected =
        _selectedItems.length == items.length && items.isNotEmpty;

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shopping Cart')),
        body: const Center(child: Text('Your cart is empty')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Checkbox(
                value: isAllSelected,
                onChanged: (_) => _toggleSelectAll(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final item = items[index];
                final isSelected = _selectedItems.contains(item.id);
                return _buildCartItemCard(item, isSelected);
              },
            ),
          ),
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected: $selectedCount ${selectedCount == 1 ? 'item' : 'items'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹${selectedTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: _selectedItems.isEmpty
                          ? Colors.grey[300]
                          : null,
                    ),
                    onPressed: _selectedItems.isEmpty
                        ? null
                        : () {
                            if (SessionStore.currentUser.value == null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CheckoutPage(
                                    selectedItems: _cartService.items
                                        .where(
                                          (item) =>
                                              _selectedItems.contains(item.id),
                                        )
                                        .toList(),
                                    selectedTotal: selectedTotal,
                                  ),
                                ),
                              );
                            }
                          },
                    child: const Text('Proceed to Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item, bool isSelected) {
    final imageUrl = item.product.imageUrls.isNotEmpty
        ? item.product.imageUrls.first
        : null;
    final isRemote = imageUrl != null && imageUrl.startsWith('http');

    Widget image;
    if (imageUrl == null) {
      image = const Icon(Icons.image, size: 40, color: Colors.blue);
    } else if (isRemote) {
      image = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined),
      );
    } else {
      image = Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleSelection(item.id),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.blue[50],
                child: image,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${item.variety.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () {
                          _cartService.updateQuantity(
                            item.id,
                            item.quantity - 1,
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () {
                          _cartService.updateQuantity(
                            item.id,
                            item.quantity + 1,
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () {
                          _cartService.removeItem(item.id);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
