import 'dart:async';

import 'package:cyclopath/models/order.dart';
import 'package:cyclopath/pages/orderlist_page.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DeliveringSheet extends StatefulWidget {
  const DeliveringSheet({
    Key? key,
    required this.model,
    required this.panelController,
  }) : super(key: key);

  final UserSession model;
  final PanelController panelController;

  @override
  _DeliveringSheetState createState() => _DeliveringSheetState();
}

class _DeliveringSheetState extends State<DeliveringSheet> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const SizedBox(
            height: 12.0,
          ),
          Center(
            child: Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.all(
                  Radius.circular(12.0),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OrderCard(order: order),

              // const Text(
              //   'Schlingensiefstraße 3',
              //   style: TextStyle(fontSize: 25.0),
              //   textAlign: TextAlign.center,
              // ),
              // IconButton(
              //   onPressed: () => {
              //     Navigator.push<void>(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => OrderListPage(),
              //       ),
              //     ),
              //   },
              //   icon: const Icon(
              //     Icons.list_rounded,
              //     size: 30,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({Key? key, required this.order}) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                // _OrderTimer(
                //   selectedDeliveryTime: order.selectedDeliveryTime,
                // ),
              ],
            ),
          ),
          _OrderButtons(),
        ],
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
    Key? key,
    required this.street,
    required this.name,
    required this.phone,
    this.note,
    this.email,
    this.tip,
  }) : super(key: key);

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
    final sDuration =
        '${_diff.inMinutes.abs()}:${_diff.inSeconds.remainder(60).abs()}';
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
