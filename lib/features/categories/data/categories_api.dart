import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:store/config/app_config.dart';
import 'models/category.dart';

/// Category API helper for fetching and managing categories from the backend.
class CategoryApi {
  CategoryApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Base URL for the category API.
  String get _baseUrl => '${AppConfig.apiBaseUrl}/categories';

  /// Fetch all categories from the database.
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final uri = Uri.parse(_baseUrl);
      final response = await _client.get(
        uri,
        headers: const {'Content-Type': 'application/json'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to fetch categories (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final categoriesJson = decoded['data'] ?? decoded['categories'] ?? [];

      return (categoriesJson as List)
          .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Add a new category to the database.
  Future<CategoryModel> addCategory(CategoryModel category) async {
    print(category);
    try {
      final uri = Uri.parse(_baseUrl);

      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': category.title,
          'slug': category.slug,
          'description': category.description,
          'imageUrl': category.imageUrl,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(decoded['message'] ?? 'Failed to add category');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return CategoryModel.fromJson(decoded['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error adding category: $e');
    }
  }

  /// Update an existing category in the database.
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final uri = Uri.parse('$_baseUrl/${category.id}');
      final response = await _client.put(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': category.title,
          'slug': category.slug,
          'description': category.description,
          'imageUrl': category.imageUrl,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(decoded['message'] ?? 'Failed to update category');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return CategoryModel.fromJson(decoded['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  /// Delete a category from the database.
  Future<void> deleteCategory(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/$id');
      final response = await _client.delete(
        uri,
        headers: const {'Content-Type': 'application/json'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(decoded['message'] ?? 'Failed to delete category');
      }
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }
}

/// In-memory repository for categories that syncs with the backend.
class CategoryRepository {
  // Holds categories fetched from the backend. Starts empty; populated via fetchAllCategories.
  static final List<CategoryModel> _categories = [];

  static List<CategoryModel> all() => List.unmodifiable(_categories);

  static bool slugExists(String slug, {String? ignoreId}) {
    final lower = slug.toLowerCase();
    return _categories.any(
      (c) =>
          c.slug.toLowerCase() == lower &&
          (ignoreId == null || c.id != ignoreId),
    );
  }

  static final _api = CategoryApi();

  /// Fetch all categories from the API
  static Future<List<CategoryModel>> fetchAllCategories() async {
    try {
      final categories = await _api.getAllCategories();
      _categories.clear();
      _categories.addAll(categories);
      return categories;
    } catch (e) {
      // Fallback to in-memory data if API fails
      return List.unmodifiable(_categories);
    }
  }

  /// Add a new category via API
  static Future<CategoryModel> addCategory(CategoryModel category) async {
    if (slugExists(category.slug)) {
      throw Exception('Slug already exists');
    }
    final newCategory = await _api.addCategory(category);
    _categories.add(newCategory);
    return newCategory;
  }

  /// Update a category via API
  static Future<CategoryModel> updateCategory(CategoryModel updated) async {
    if (slugExists(updated.slug, ignoreId: updated.id)) {
      throw Exception('Slug already exists');
    }
    final updatedCategory = await _api.updateCategory(updated);
    final idx = _categories.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      _categories[idx] = updatedCategory;
    }
    return updatedCategory;
  }

  /// Delete a category via API
  static Future<void> deleteCategory(String id) async {
    await _api.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
  }
}
