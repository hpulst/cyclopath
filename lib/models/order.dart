import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
part 'order.g.dart';

@JsonSerializable()
class Order {
  Order({
    required this.id,
    required this.customer,
    required this.street,
    required this.city,
    required this.postal,
    required this.selectedDeliveryTime,
    this.actualArrivalTime,
    this.tip,
    this.note,
    this.orderStatus = OrderStatus.riding,
  });
  final int id;
  final String customer;
  final String street;
  final String city;
  final String postal;
  final DateTime selectedDeliveryTime;
  final DateTime? actualArrivalTime;
  final double? tip;
  final String? note;
  final OrderStatus orderStatus;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

Future<List<Order>> loadOrders() async {
  final jsonOrders = await _loadAssets();
  final List<dynamic> parsedJson = jsonDecode(jsonOrders);
  return parsedJson.map((e) => Order.fromJson(e)).toList();
}

Future<String> _loadAssets() {
  const filePath = 'assets/json/orders.json';
  return rootBundle.loadString(filePath);
}

enum OrderStatus { placed, ready, picked, riding, arrived, delivered }