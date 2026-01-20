import 'package:store/config/app_config.dart';
import 'package:store/core/network/api_client.dart';
import 'package:store/features/product/data/model/product.dart';

/// Product API using the common ApiClient
class ProductApi {
  ProductApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  String get _baseUrl => '${AppConfig.apiBaseUrl}/products';

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
    final body = {...product.toJson()}..remove('id');
    final response = await _client.post(_baseUrl, body: body);
    if (!_client.isSuccess(response)) {
      final errorMsg = _client.getErrorMessage(response);
      throw Exception(errorMsg);
    }
    final decoded = _client.decodeResponse(response);
    return ProductModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await _client.put(
      '$_baseUrl/${product.id}',
      body: product.toJson(),
    );
    if (!_client.isSuccess(response)) {
      final errorMsg = _client.getErrorMessage(response);
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
