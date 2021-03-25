import 'package:flutter/cupertino.dart';

import 'customer_model.dart';

class Order {
  Order({
    required this.id,
    required this.customer,
    required this.selectedDeliveryTime,
    this.actualArrivalTime,
    this.tip,
    this.note,
    this.orderStatus = OrderStatus.placed,
  });
  final int id;
  final Customer customer;
  final DateTime selectedDeliveryTime;
  final DateTime? actualArrivalTime;
  final double? tip;
  final String? note;
  final OrderStatus orderStatus;
}

// ignore: avoid_classes_with_only_static_members
class OrderQueue with ChangeNotifier {
  static final orderlist = <Order>[
    Order(
      id: 1,
      customer: Customer(
          id: 1,
          forename: 'Vitlay',
          name: 'Ginzburg',
          adress: 'Mittelweg 177, 20148 Hamburg',
          email: 'vitaly@web.de',
          phone: '017694323423'),
      selectedDeliveryTime: DateTime.parse('1969-07-20 20:18:04Z'),
      tip: 2,
      note: '2 Stock',
    ),
    Order(
      id: 1,
      customer: Customer(
        id: 1,
        forename: 'Karl',
        name: 'Schwarz',
        adress: 'Fontenay 10, 20354 Hamburg',
        email: 'mail@web.de',
        phone: '017694323423',
        company: 'The Fontenay Hotel',
      ),
      selectedDeliveryTime: DateTime.parse('1969-07-20 20:30:04Z'),
      tip: 2,
      note: '2 Stock',
    ),
    Order(
      id: 1,
      customer: Customer(
          id: 1,
          forename: 'Nikola',
          name: 'Bloch',
          adress: 'Alsterchaussee 24, 20149 Hamburg',
          email: 'mail@web.de',
          phone: '017694323423'),
      selectedDeliveryTime: DateTime.parse('1969-07-20 20:34:04Z'),
      tip: 2,
      note: '2 Stock',
    ),
    Order(
      id: 1,
      customer: Customer(
          id: 1,
          forename: 'Paul',
          name: 'Ehrlich',
          adress: 'Linnering 1, 22299 Hamburg',
          email: 'mail@planetarium.de',
          phone: '017694323423',
          company: 'Planetarium Hamburg'),
      selectedDeliveryTime: DateTime.parse('1969-07-20 20:40:04Z'),
      tip: 2,
      note: '2 Stock',
    ),
  ];
}

enum OrderStatus { placed, ready, picked, riding, arrived, delivered }
