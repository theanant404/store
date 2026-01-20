import 'dart:io';

import 'package:flutter/material.dart';
import 'package:store/features/product/data/model/product.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});

  final ProductModel product;

  bool _isRemote(String? url) => url != null && url.startsWith('http');

  double _lowestPrice() {
    if (product.varieties.isEmpty) return 0;
    return product.varieties
        .map((v) => v.price)
        .reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final price = _lowestPrice();
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
              '\u20b9${price.toStringAsFixed(2)}',
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
                'Available Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...product.varieties.map(
                (v) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('₹${v.price.toStringAsFixed(2)}'),
                    subtitle: _buildVarietySubtitle(v),
                    trailing: v.stock > 0
                        ? const Chip(label: Text('In Stock'))
                        : const Chip(label: Text('Out of Stock')),
                  ),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to cart (placeholder)')),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVarietySubtitle(ProductVariety v) {
    final pieces = <String>[];
    if (v.weight != null) pieces.add('${v.weight} kg');
    if (v.quantity != null) pieces.add('${v.quantity}${v.quantityUnit ?? ''}');
    if (v.discount != null) pieces.add('Discount ${v.discount}%');
    return pieces.isEmpty
        ? const Text('')
        : Text(pieces.join(' · '), style: const TextStyle(fontSize: 13));
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
