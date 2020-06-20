import 'package:flutter/foundation.dart';

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

  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(OrderItem cartProducts) {
    _orders.insert(0, cartProducts);
    notifyListeners();
  }
}
