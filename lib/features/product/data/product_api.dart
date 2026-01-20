import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:store/config/app_config.dart';
import 'package:store/core/network/api_client.dart';
import 'package:store/features/auth/data/session_store.dart';
import 'package:store/features/product/data/model/product.dart';

/// Product API using the common ApiClient
class ProductApi {
  ProductApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  String get _baseUrl => '${AppConfig.apiBaseUrl}/products';
  String get _uploadsUrl => '${AppConfig.apiBaseUrl}/uploads';

  /// Upload an array of images. Already-uploaded URLs are returned unchanged.
  /// Local file paths are uploaded in a single multipart request.
  Future<List<String>> uploadImages(List<String> imagePaths) async {
    print('📤 Uploading images: $imagePaths');
    if (imagePaths.isEmpty) return [];

    final urls = <String>[];
    final localPaths = <String>[];

    for (final path in imagePaths) {
      if (path.startsWith('http')) {
        urls.add(path); // keep existing URLs
      } else {
        localPaths.add(path);
      }
    }

    if (localPaths.isEmpty) {
      return urls; // nothing to upload
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadsUrl));
      for (final path in localPaths) {
        final file = File(path);
        if (!await file.exists()) {
          throw Exception('Image file not found: $path');
        }
        request.files.add(await http.MultipartFile.fromPath('files', path));
      }

      // Add auth headers if available
      final user = SessionStore.currentUser.value;
      if (user != null && user.accessToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer ${user.accessToken}';
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('📥 Upload response status: ${response.statusCode}');
      print('📥 Upload response body: $responseBody');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upload images (${response.statusCode})');
      }

      final decoded = _client.decodeResponse(
        http.Response(responseBody, response.statusCode),
      );

      // Try common keys; adjust to your backend shape
      final dynamic payload =
          decoded['data'] ??
          decoded['urls'] ??
          decoded['files'] ??
          decoded['images'];
      if (payload is List) {
        urls.addAll(payload.map((e) => e.toString()));
      } else if (payload is String) {
        urls.add(payload);
      } else {
        throw Exception('No URLs returned from upload');
      }

      return urls;
    } catch (e) {
      print('❌ Upload error: $e');
      rethrow;
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

  Future<ProductModel> createProduct(ProductModel product) async {
    print('📤 Creating product at: $_baseUrl');

    // Upload images (local files in bulk, URLs kept as-is)
    final uploadedUrls = await uploadImages(product.imageUrls);
    final productToSave = product.copyWith(imageUrls: uploadedUrls);
    final body = {...productToSave.toJson()}..remove('id');
    print('📦 Request body: $body');

    final response = await _client.post(_baseUrl, body: body);
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (!_client.isSuccess(response)) {
      final errorMsg = _client.getErrorMessage(response);
      print('❌ Error: $errorMsg');
      throw Exception(errorMsg);
    }

    final decoded = _client.decodeResponse(response);
    return ProductModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final url = '$_baseUrl/${product.id}';
    print('📤 Updating product at: $url');

    // Upload images (local files in bulk, URLs kept as-is)
    final uploadedUrls = await uploadImages(product.imageUrls);
    final productToSave = product.copyWith(imageUrls: uploadedUrls);
    print('📦 Request body: ${productToSave.toJson()}');

    final response = await _client.put(url, body: productToSave.toJson());
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (!_client.isSuccess(response)) {
      final errorMsg = _client.getErrorMessage(response);
      print('❌ Error: $errorMsg');
      throw Exception(errorMsg);
    }

    final decoded = _client.decodeResponse(response);
    return ProductModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String id) async {
    final response = await _client.delete('$_baseUrl/$id');
    if (!_client.isSuccess(response)) {
      final errorMsg = _client.getErrorMessage(response);
      throw Exception(errorMsg);
    }
  }
}
