import 'package:store/features/product/data/model/product.dart';
import 'package:store/features/product/data/product_api.dart';

/// Repository keeping in-memory cache in sync with backend API.
class ProductRepository {
  static final List<ProductModel> _products = [];
  static final _api = ProductApi();

  static List<ProductModel> allProducts() => List.unmodifiable(_products);

  static List<ProductModel> filterProducts({
    String? categoryId,
    String? searchQuery,
  }) {
    return _products.where((p) {
      final matchCategory = categoryId == null || p.categoryId == categoryId;
      final matchName = searchQuery == null || searchQuery.isEmpty
          ? true
          : p.title.toLowerCase().contains(searchQuery.toLowerCase());
      return matchCategory && matchName;
    }).toList();
  }

  static Future<List<ProductModel>> fetchAllProducts() async {
    final products = await _api.getAllProducts();
    _products
      ..clear()
      ..addAll(products);
    return products;
  }

  static Future<ProductModel> addProduct(ProductModel product) async {
    _validate(product);
    final created = await _api.createProduct(product);
    _products.add(created);
    return created;
  }

  static Future<ProductModel> updateProduct(ProductModel product) async {
    _validate(product);
    final saved = await _api.updateProduct(product);
    final idx = _products.indexWhere((p) => p.id == saved.id);
    if (idx != -1) _products[idx] = saved;
    return saved;
  }

  static Future<void> deleteProduct(String id) async {
    await _api.deleteProduct(id);
    _products.removeWhere((p) => p.id == id);
  }

  static void _validate(ProductModel product) {
    if (product.title.trim().isEmpty) {
      throw Exception('Title is required');
    }
    if (product.description.trim().isEmpty) {
      throw Exception('Description is required');
    }
    if (product.categoryId.isEmpty) {
      throw Exception('Category is required');
    }
    if (product.varieties.isEmpty) {
      throw Exception('At least one variety is required');
    }
    final hasLocalImages = product.imageUrls.any((u) => !u.startsWith('http'));
    if (hasLocalImages) {
      throw Exception(
        'Please use image URLs. Upload from gallery not supported yet.',
      );
    }
  }
}
