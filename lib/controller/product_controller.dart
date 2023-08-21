import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/product_model.dart';

class ProductController {
  final baseUrl = 'http://18.118.26.112:8080/api/v1/product';

  Future<List<Product>> fetchProductsBySubcategory(
      int subcategoryId, int page) async {
    final response = await http.get(
        Uri.parse('$baseUrl/subcategory/$subcategoryId?page=$page&pageSize=5'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return responseData.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  Future<List<Product>> fetchProductsById(int productId) async {
    final response = await http.get(Uri.parse('$baseUrl/$productId'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return responseData.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch products');
    }
  }
}
