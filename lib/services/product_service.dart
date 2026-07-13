import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/product_api.dart';
import '../models/product_model.dart';

class ProductRepository {
  Future<List<Products>> getAllProducts({int limit = 20, int skip = 0}) async {
    try {
      final url = Uri.parse(
        '${ApiEndpoints.productUrl}?limit=$limit&skip=$skip',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List productsJson = data['products'];
        return productsJson.map((json) => Products.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Products not found.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
          'Failed to load products (Code: ${response.statusCode}).',
        );
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('Could not reach the server.');
    } on FormatException {
      throw Exception('Invalid data received from server.');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
}
