import 'package:cyclopath/models/order.dart';
import 'package:flutter/material.dart';

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
    return Container(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(order.street),
            ],
          ),
        ],
      ),
    );
  }
}
