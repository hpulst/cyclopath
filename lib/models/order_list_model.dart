import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'order.dart';

class OrderListModel extends ChangeNotifier {
  OrderListModel({
    List<Order>? orderQueue,
  }) : _orderQueue = orderQueue ?? [];

  final List<Order> _orderQueue;

  OrderRepository repository = OrderRepository();
  final String _selectedOrder = '';
  bool _isLoading = false;

  List<Order> get orderQueue => _orderQueue;
  String get selectedOrder => _selectedOrder;

  bool get isLoading => _isLoading;

  Future loadOrders() {
    _isLoading = true;
    notifyListeners();
    return repository.loadOrders().then((loadedOrders) {
      orderQueue.addAll(loadedOrders);
      // .map(Order.fromEntiry)
      _isLoading = false;
      notifyListeners();
    }).catchError((dynamic error) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error caught: $error');
    });
  }

  void clearCompleted() {
    _orderQueue.removeWhere((order) => order.complete);
    notifyListeners();
    _uploadItems();
  }

  void updateOrder(Order order) {
    final oldOrder = _orderQueue.firstWhere((it) => it.id == order.id);
    final replaceIndex = _orderQueue.indexOf(oldOrder);
    _orderQueue.replaceRange(replaceIndex, replaceIndex + 1, [order]);
    notifyListeners();
    _uploadItems();
  }

  void _uploadItems() {
    // repository.saveOrders(_orderQueue.map((it) => it.toEntity()).toList());
  }

  Order orderById(String id) {
    return _orderQueue.firstWhere((it) => it.id == id);
  }

  Order get currentOrder =>
      orderQueue.firstWhere((Order order) => !order.complete);

  int get numCompleted =>
      orderQueue.where((Order order) => order.complete).toList().length;

  bool get hasCompleted => numCompleted > 0;

  int get numActive =>
      orderQueue.where((Order order) => !order.complete).toList().length;

  bool get hasActiveOrders => numActive > 0;
}

class OrderRepository {
  Future<List<Order>> loadOrders() async {
    final jsonOrders = await _loadAssets();
    final List<dynamic> parsedJson = jsonDecode(jsonOrders);
    return parsedJson.map((e) => Order.fromJson(e)).toList();
  }

  Future<String> _loadAssets() {
    const filePath = 'assets/json/orders.json';
    return rootBundle.loadString(filePath);
  }
}
