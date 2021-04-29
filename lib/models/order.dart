import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
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
    required this.phone,
    this.email,
    this.tip,
    this.note,
  })  : orderStatus = OrderStatus.riding,
        selectedDeliveryTime = DateTime.now().add(
          Duration(minutes: 12 + 2 * id),
        );

  final int id;
  final String customer;
  final String street;
  final String city;
  final String postal;
  final String phone;
  final DateTime selectedDeliveryTime;
  final String? email;
  final double? tip;
  final String? note;
  final OrderStatus orderStatus;

  // ignore: sort_constructors_first
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
