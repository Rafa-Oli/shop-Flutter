import 'dart:math';

import 'package:flutter/foundation.dart';

import 'cart.dart';

class Order {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime date;

  Order({
    this.id,
    this.total,
    this.products,
    this.date,
  });
}

//controla todos os pedidos dentro d aplicação
class Orders with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders {
    return [..._orders];
  }

  void addOrder(List<CartItem> products, double total) {
    _orders.insert(
      0,
      Order(
        id: Random().nextDouble().toString(),
        total: total,
        date: DateTime.now(),
        products: products,
      ),
    );
    notifyListeners();
  }
}
