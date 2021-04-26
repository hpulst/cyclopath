import 'dart:core';

import 'package:cyclopath/models/order.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class OrderTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Order>>(
      future: loadOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return OrderList(
            orderList: snapshot.data,
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

class OrderList extends StatelessWidget {
  const OrderList({
    Key? key,
    this.orderList,
  }) : super(key: key);

  final List<Order>? orderList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: orderList!.length,
      itemBuilder: (context, index) {
        return OrderCard(order: orderList![index]);
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({Key? key, required this.order}) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
                child: _OrderDescription(
                  street: order.street,
                  name: order.customer,
                  note: order.note,
                  email: order.email,
                  tip: order.tip,
                  selectedDeliveryTime: order.selectedDeliveryTime,
                  phone: order.phone,
                ),
              ),
            ),
            _OrderButtons(),
          ],
        ),
      ),
    );
  }
}

class _OrderButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text(
                'ZUGESTELLT',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension Ex on double {
  String toStringAsFixedNoZero(int n) =>
      double.parse(this.toStringAsFixed(n)).toString();
}

class _OrderDescription extends StatelessWidget {
  const _OrderDescription({
    required this.street,
    required this.name,
    this.note,
    this.email,
    this.tip,
    this.selectedDeliveryTime,
    required this.phone,
  });

  final String street;
  final String name;
  final String? note;
  final String? email;
  final double? tip;
  final DateTime? selectedDeliveryTime;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          street,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline6,
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
        ),
        Row(
          children: [
            Text(
              name,
              maxLines: 2,
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 15),
        ),
        Visibility(
          visible: tip! > 0.0,
          child: Row(
            children: [
              const Icon(
                Icons.favorite,
                color: Colors.black,
                size: 15,
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
              ),
              Text(
                '${tip!.toStringAsFixed(tip!.truncateToDouble() == tip ? 0 : 2)}€ Trinkgeld',
                maxLines: 1,
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 2),
        ),
        Visibility(
          visible: note != '',
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.hand_point_right_fill,
                size: 20,
              ),
              const Padding(
                padding: EdgeInsets.only(right: 2),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    note!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.amber,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
