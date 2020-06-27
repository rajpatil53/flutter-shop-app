import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String authToken, String userId) async {
    print('tooglef');
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://flutter-shop-app-1.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
    try {
      final resp = await http.put(url, body: json.encode(isFavorite));
      if (resp.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
        throw HttpException('Could not add to favorites');
      }
    } catch (err) {
      print(err);
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
