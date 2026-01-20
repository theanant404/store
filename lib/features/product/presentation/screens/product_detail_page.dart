import 'dart:io';

import 'package:flutter/material.dart';
import 'package:store/features/cart/data/services/cart_service.dart';
import 'package:store/features/product/data/model/product.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late ProductVariety _selectedVariety;
  int _quantity = 1;
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _selectedVariety = widget.product.varieties.isNotEmpty
        ? widget.product.varieties.first
        : ProductVariety(id: '0', price: 0);
  }

  ProductModel get product => widget.product;

  bool _isRemote(String? url) => url != null && url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(),
            const SizedBox(height: 16),
            Text(
              product.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${_selectedVariety.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.description.isNotEmpty
                  ? product.description
                  : 'No description available.',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            if (product.varieties.isNotEmpty) ...[
              const Text(
                'Select Option',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<ProductVariety>(
                isExpanded: true,
                value: _selectedVariety,
                items: product.varieties
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(
                          '₹${v.price.toStringAsFixed(2)} ${_buildVarietyLabel(v)}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedVariety = v);
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '$_quantity',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _quantity <
                                  (_selectedVariety.stock > 0
                                      ? _selectedVariety.stock
                                      : 10)
                              ? () => setState(() => _quantity++)
                              : null,
                          icon: const Icon(Icons.add),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _selectedVariety.stock > 0
                  ? () {
                      _cartService.addItem(
                        product: product,
                        variety: _selectedVariety,
                        quantity: _quantity,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $_quantity item(s) to cart'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
            ),
          ),
        ),
      ),
    );
  }

  String _buildVarietyLabel(ProductVariety v) {
    final pieces = <String>[];
    if (v.weight != null) pieces.add('${v.weight}kg');
    if (v.quantity != null) pieces.add('${v.quantity}${v.quantityUnit ?? ''}');
    if (v.discount != null) pieces.add('${v.discount}% off');
    return pieces.isEmpty ? '' : '(${pieces.join(', ')})';
  }

  Widget _buildImageGallery() {
    if (product.imageUrls.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.image, size: 64, color: Colors.blue),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: PageView.builder(
        itemCount: product.imageUrls.length,
        itemBuilder: (context, index) {
          final url = product.imageUrls[index];
          if (_isRemote(url)) {
            return _buildRemoteImage(url);
          }
          return _buildLocalImage(url);
        },
      ),
    );
  }

  Widget _buildRemoteImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        headers: const {'User-Agent': 'Mozilla/5.0', 'Accept': '*/*'},
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.blue[50],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          color: Colors.blue[50],
          child: const Center(child: Icon(Icons.broken_image_outlined)),
        ),
      ),
    );
  }

  Widget _buildLocalImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.blue[50],
          child: const Center(child: Icon(Icons.broken_image_outlined)),
        ),
      ),
    );
  }
}
