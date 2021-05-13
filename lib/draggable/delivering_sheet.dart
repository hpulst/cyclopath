import 'dart:async';

import 'package:cyclopath/models/order.dart';
import 'package:cyclopath/models/order_list_model.dart';
import 'package:cyclopath/pages/orderlist_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DeliveringSheet extends StatelessWidget {
  const DeliveringSheet({
    Key? key,
    required this.panelController,
  }) : super(key: key);

  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderListModel>(
      builder: (context, orderList, _) {
        if (!orderList.hasActiveOrders) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            OrderPreviewCard(
                order: orderList.currentOrder,
                panelController: panelController),
            Visibility(
              visible: orderList.currentOrder.note!.isNotEmpty,
              child: _OrderNote(
                note: orderList.currentOrder.note!,
                panelController: panelController,
              ),
            ),
            _OrderDescription(
              street: orderList.currentOrder.street,
              customer: orderList.currentOrder.customer,
              note: orderList.currentOrder.note,
              email: orderList.currentOrder.email,
              tip: orderList.currentOrder.tip,
              phone: orderList.currentOrder.phone,
              panelController: panelController,
            ),
          ],
        );
      },
    );
  }
}

class OrderPreviewCard extends StatefulWidget {
  const OrderPreviewCard({
    Key? key,
    required this.order,
    required this.panelController,
  }) : super(key: key);

  final PanelController panelController;
  final Order order;

  @override
  _OrderPreviewCardState createState() => _OrderPreviewCardState();
}

class _OrderPreviewCardState extends State<OrderPreviewCard> {
  @override
  Widget build(BuildContext context) {
    final isPanelClosed = widget.panelController.isPanelClosed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.order.street,
                // maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 23),
              ),
              const _OrderListButton(),
            ],
          ),
          // const Padding(
          //   padding: EdgeInsets.only(bottom: 8),
          // ),
          Row(
            children: [
              Text(
                widget.order.customer,
                maxLines: 2,
              ),
              const Text(' • '),
              _OrderTimer(
                selectedDeliveryTime: widget.order.selectedDeliveryTime,
              ),
            ],
          ),
          Visibility(
            visible: isPanelClosed,
            maintainAnimation: true,
            maintainState: true,
            maintainSize: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 10, 8),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.warning_rounded,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.order.note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const _OrderDeliveredButtons(),
        ],
      ),
    );
  }
}

class _OrderListButton extends StatelessWidget {
  const _OrderListButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => {
            Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (context) => const OrderListPage(),
              ),
            ),
          },
          icon: const Icon(
            Icons.list_rounded,
            size: 35,
          ),
        ),
      ],
    );
  }
}

class _OrderDescription extends StatelessWidget {
  const _OrderDescription({
    Key? key,
    required this.street,
    required this.customer,
    required this.phone,
    this.note,
    this.email,
    this.tip,
    required this.panelController,
  }) : super(key: key);

  final String street;
  final String customer;
  final String? note;
  final String? email;
  final double? tip;
  final String phone;
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  color: Colors.black,
                  size: 15,
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                ),
                Text('Telefonnummer: $phone'),
              ],
            ),
            Visibility(
              visible: email != null,
              child: Row(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const Icon(
                    Icons.favorite,
                    color: Colors.black,
                    size: 15,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                  ),
                  Text(
                    'Emai: $email',
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Visibility(
              visible: tip! > 0.0,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
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
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderNote extends StatelessWidget {
  const _OrderNote({
    Key? key,
    required this.note,
    required this.panelController,
    this.isExpanded,
  }) : super(key: key);

  final String note;
  final PanelController panelController;
  final bool? isExpanded;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: note.isNotEmpty,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        // border: Border.all(
        // ),
        // ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.warning_rounded,
                size: 25,
                color: Colors.red,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 4),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  note,
                  maxLines: 10,
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
    // final selectedDeliveryTime =
    //     TimeOfDay.fromDateTime(widget.selectedDeliveryTime).format(context);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final sDuration =
        '${twoDigits(_diff.inMinutes.abs())}:${twoDigits(_diff.inSeconds.remainder(60).abs())}';

    return Text(
      _diff.isNegative ? 'vor ' + sDuration : 'in ' + sDuration,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: _diff.isNegative
            ? Colors.red.shade600
            : Theme.of(context).primaryColor,
      ),
    );
    ;
  }
}

class _OrderDeliveredButtons extends StatelessWidget {
  const _OrderDeliveredButtons({Key? key}) : super(key: key);

  //  _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
  //               _initFabHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Builder(
        builder: (context) {
          final _key = GlobalKey<SlideActionState>();

          return SlideAction(
            height: 50,
            sliderButtonIconPadding: 10,
            text: 'Zugestellt',
            onSubmit: () {
              Future.delayed(
                const Duration(seconds: 1),
                () => _key.currentState!.reset(),
              );
            },
            innerColor: Colors.white,
            outerColor: Colors.black,
          );
        },
      ),
    );
  }
}
