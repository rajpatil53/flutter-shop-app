import 'package:flutter/foundation.dart';

import './product.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({this.id, this.title, this.price, this.quantity});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> items = {};

  int get itemCount {
    return items.length;
  }

  double get cartTotal {
    double total = 0.0;
    items.forEach((key, value) {
      total += value.quantity * value.price;
    });
    return total;
  }

  void addItem(Product product) {
    if (items.containsKey(product.id)) {
      items.update(product.id, (existingItem) {
        return CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          quantity: existingItem.quantity + 1,
        );
      });
    } else {
      items.putIfAbsent(product.id, () {
        return CartItem(
            id: DateTime.now().toString(),
            price: product.price,
            title: product.title,
            quantity: 1);
      });
    }
    notifyListeners();
  }

  void deleteItem(String id) {
    items.remove(id);
    notifyListeners();
  }

  void deleteSubItem(String productId) {
    if (!items.containsKey(productId)) {
      return;
    }
    if (items[productId].quantity > 1) {
      items.update(productId, (existingItem) {
        return CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          quantity: existingItem.quantity - 1,
        );
      });
    } else {
      items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }
}
