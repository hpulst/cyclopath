import 'dart:async';
import 'dart:core';

import 'package:cyclopath/models/order.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _OrderDescription(
                      street: order.street,
                      name: order.customer,
                      note: order.note,
                      email: order.email,
                      tip: order.tip,
                      phone: order.phone,
                    ),
                  ),
                  _OrderTimer(
                    selectedDeliveryTime: order.selectedDeliveryTime,
                  ),
                ],
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

class _OrderDescription extends StatelessWidget {
  const _OrderDescription({
    required this.street,
    required this.name,
    required this.phone,
    this.note,
    this.email,
    this.tip,
  });

  final String street;
  final String name;
  final String? note;
  final String? email;
  final double? tip;
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
          padding: EdgeInsets.only(bottom: 12),
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
          padding: EdgeInsets.only(bottom: 4),
        ),
        _OrderNote(note: note),
      ],
    );
  }
}

class _OrderNote extends StatelessWidget {
  const _OrderNote({
    Key? key,
    required this.note,
  }) : super(key: key);

  final String? note;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: note != '',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          border: Border.all(
            width: 0.5,
            color: Colors.amber,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_rounded,
              size: 20,
              color: Colors.amber.shade700,
            ),
            const Padding(
              padding: EdgeInsets.only(right: 2),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  note!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTimer extends StatefulWidget {
  const _OrderTimer({required this.selectedDeliveryTime});
  final DateTime selectedDeliveryTime;

  @override
  _OrderTimerState createState() => _OrderTimerState();
}

class _OrderTimerState extends State<_OrderTimer> {
  final DateTime _dateTime = DateTime.now();
  late Timer _timer;
  late Duration _diff;

  @override
  void initState() {
    super.initState();
    startTimer(
      widget.selectedDeliveryTime.difference(_dateTime),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void startTimer(Duration duration) {
    _diff = duration;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => setState(
        () {
          _diff = _diff - const Duration(seconds: 1);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sDuration = '${_diff.inMinutes}:${_diff.inSeconds.remainder(60)}';
    return Text(
      _diff.isNegative ? 'in ' : 'vor ' + sDuration,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: _diff.isNegative
            ? Colors.red.shade600
            : Theme.of(context).primaryColor,
      ),
    );
  }
}
