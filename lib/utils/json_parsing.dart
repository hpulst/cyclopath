import 'dart:convert';
import 'package:cyclopath/models/order.dart';
import 'package:flutter/services.dart';

class OrderRepository {
  Future<List<Order>> loadOrders() async {
    final jsonOrders = await _loadAssets();
    final List<dynamic> parsedJson = jsonDecode(jsonOrders);
    print('OrderRepository $parsedJson');
    return parsedJson.map((e) => Order.fromJson(e)).toList();
  }

  Future<String> _loadAssets() {
    const filePath = 'assets/json/orders.json';
    return rootBundle.loadString(filePath);
  }
}
