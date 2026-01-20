import 'package:store/config/app_config.dart';
import 'package:store/core/network/api_client.dart';
import 'package:store/features/categories/data/models/category.dart';
import 'package:store/features/product/data/model/product.dart';

/// Category API helper for fetching and managing categories from the backend.
class CategoryApi {
  CategoryApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Base URL for the category API.
  String get _baseUrl => '${AppConfig.apiBaseUrl}/categories';

  /// Fetch all categories from the database.
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _client.get(_baseUrl);

      if (!_client.isSuccess(response)) {
        throw Exception('Failed to fetch categories (${response.statusCode})');
      }

      final decoded = _client.decodeResponse(response);
      final categoriesJson = decoded['data'] ?? decoded['categories'] ?? [];

      return (categoriesJson as List)
          .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    final response = await _client.get(_baseUrl);
    if (!_client.isSuccess(response)) {
      throw Exception('Failed to fetch products (${response.statusCode})');
    }
    final decoded = _client.decodeResponse(response);
    final productsJson = decoded['data'] ?? decoded['products'] ?? [];
    return (productsJson as List)
        .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _client.get('$_baseUrl/$id');
    if (!_client.isSuccess(response)) {
      final errorMsg = _client.getErrorMessage(response);
      throw Exception(errorMsg);
    }
    final decoded = _client.decodeResponse(response);
    return ProductModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }
}
