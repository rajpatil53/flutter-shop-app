import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final List<CartItem> products;
  final DateTime dateTime;
  final double amount;

  OrderItem({
    @required this.id,
    @required this.products,
    @required this.dateTime,
    @required this.amount,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken, userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> getOrders() async {
    final url =
        'https://flutter-shop-app-1.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final resp = await http.get(url);
      final fetchedOrders = json.decode(resp.body) as Map<String, dynamic>;
      if (fetchedOrders == null) return;
      final List<OrderItem> orders = [];
      fetchedOrders.forEach((orderId, orderData) {
        orders.add(OrderItem(
          id: orderId,
          dateTime: DateTime.parse(orderData['dateTime']),
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  quantity: item['quantity'],
                  title: item['title'],
                  price: item['price']))
              .toList(),
        ));
      });
      _orders = orders.reversed.toList();
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timeStamp = DateTime.now();
    final url =
        'https://flutter-shop-app-1.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProducts
                .map((prod) => {
                      'id': prod.id,
                      'title': prod.title,
                      'quantity': prod.quantity,
                      'price': prod.price,
                    })
                .toList(),
          }));
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          products: cartProducts,
          dateTime: timeStamp,
          amount: total,
        ),
      );
      notifyListeners();
    } catch (err) {
      print(err);
      throw err;
    }
  }
}
