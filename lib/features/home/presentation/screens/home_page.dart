import 'dart:io';

import 'package:flutter/material.dart';
import 'package:store/features/categories/data/models/category.dart';
import 'package:store/features/home/data/home_api.dart';
import 'package:store/features/product/data/model/product.dart';
import 'package:store/features/product/data/product_repository.dart';
import 'package:store/features/product/presentation/screens/product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _LandingPageState();
}

class _LandingPageState extends State<HomePage> {
  final PageController _carouselController = PageController();
  final CategoryApi _categoryApi = CategoryApi();

  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = false;
  List<ProductModel> _products = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final cats = await _categoryApi.getAllCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final prods = await ProductRepository.fetchAllProducts();
      if (mounted) setState(() => _products = prods);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Text(
              'E-Store',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: null,
                icon: Icon(Icons.search, color: Colors.black),
              ),
              IconButton(
                onPressed: null,
                icon: Icon(Icons.notifications_none, color: Colors.black),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCarousel(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildCategoryList(),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _buildProductGrid(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _carouselController,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    Icons.bolt,
                    size: 150,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'FLASH SALE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Up to 60% off',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Limited time deals on top brands',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryList() {
    if (_isLoadingCategories) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_categories.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No categories available')),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      (cat.imageUrl != null && cat.imageUrl!.isNotEmpty)
                      ? NetworkImage(cat.imageUrl!)
                      : null,
                  child: (cat.imageUrl == null || cat.imageUrl!.isEmpty)
                      ? Text(
                          cat.title.isNotEmpty
                              ? cat.title[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    cat.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoadingProducts) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_products.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: Text('No products available')),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildProductCard(_products[index]),
        childCount: _products.length,
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final price = product.varieties.isNotEmpty
        ? product.varieties.map((v) => v.price).reduce((a, b) => a < b ? a : b)
        : 0.0;
    final image = product.imageUrls.isNotEmpty ? product.imageUrls.first : null;
    final isRemote = image != null && image.startsWith('http');

    final Widget imageWidget;
    if (image == null) {
      imageWidget = const Center(
        child: Icon(Icons.image, size: 50, color: Colors.blue),
      );
    } else if (isRemote) {
      imageWidget = Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image_outlined)),
      );
    } else {
      imageWidget = Image.file(
        File(image),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image_outlined)),
      );
    }

    return InkWell(
      onTap: () => _openProductDetail(product),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Container(color: Colors.blue[50], child: imageWidget),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      5,
                      (i) =>
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProductDetail(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
    );
  }
}
