import 'dart:convert';

import '../model/category.dart';
import 'package:http/http.dart' as http;

class CategoryController {
  String apiUrl = 'http://18.218.84.231:8080/api/v1/category';

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Category> categories =
          body.map((dynamic item) => Category.fromJson(item)).toList();
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
