import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _products = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  String authToken;
  String userId;

  Products(this.authToken, this.userId, this._products);

  List<Product> get items {
    return [..._products];
  }

  List<Product> get favoritesOnly {
    return _products.where((product) => product.isFavorite).toList();
  }

  Product getById(String id) {
    return _products.firstWhere((prod) => prod.id == id);
  }

  Future<void> getProducts([bool isForUser = false]) async {
    try {
      final filterParam =
          isForUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
      var url =
          'https://flutter-shop-app-1.firebaseio.com/products.json?auth=$authToken$filterParam';
      final resp = await http.get(url);
      final loadedProducts = json.decode(resp.body) as Map<String, dynamic>;
      if (loadedProducts == null) return;
      url =
          'https://flutter-shop-app-1.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResp = await http.get(url);
      final favoriteData = json.decode(favoriteResp.body);
      final List<Product> products = [];
      loadedProducts.forEach((prodId, prodData) {
        products.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _products = products;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://flutter-shop-app-1.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
          }));
      _products.add(Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      ));
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateProduct(Product product) async {
    final url =
        'https://flutter-shop-app-1.firebaseio.com/products/${product.id}.json?auth=$authToken';
    await http.patch(url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        }));
    var prodIndex = _products.indexWhere((prod) => prod.id == product.id);
    if (prodIndex >= 0) {
      _products[prodIndex] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-shop-app-1.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _products.indexWhere((prd) => prd.id == id);
    var existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);
    notifyListeners();
    final resp = await http.delete(url);
    if (resp.statusCode >= 400) {
      _products.insert(existingProductIndex, existingProduct);
      existingProduct = null;
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
