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
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Column(
            children: [
              OrderPreviewCard(
                  street: orderList.currentOrder.street,
                  customer: orderList.currentOrder.customer,
                  note: orderList.currentOrder.note,
                  panelController: panelController),
              Visibility(
                visible: orderList.currentOrder.note.isNotEmpty,
                child: _OrderNote(
                  note: orderList.currentOrder.note,
                  panelController: panelController,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              _OrderTip(tip: orderList.currentOrder.tip),
              const SizedBox(
                height: 20,
              ),
              _OrderListTile(
                  listTileText: orderList.currentOrder.email,
                  icon: Icons.mail_outline_rounded,
                  visible: orderList.currentOrder.email.isNotEmpty),
              const SizedBox(
                height: 20,
              ),
              _OrderListTile(
                listTileText: orderList.currentOrder.id,
                icon: Icons.airplane_ticket_rounded,
              ),
              const SizedBox(
                height: 20,
              ),
              _OrderPhone(phone: orderList.currentOrder.phone),
            ],
          ),
        );
      },
    );
  }
}

class OrderPreviewCard extends StatefulWidget {
  const OrderPreviewCard({
    Key? key,
    required this.street,
    required this.customer,
    required this.note,
    required this.panelController,
  }) : super(key: key);

  final String street;
  final String customer;
  final String note;
  final PanelController panelController;

  @override
  _OrderPreviewCardState createState() => _OrderPreviewCardState();
}

class _OrderPreviewCardState extends State<OrderPreviewCard> {
  @override
  Widget build(BuildContext context) {
    final isPanelClosed = widget.panelController.isPanelClosed;
    // final note = widget.note;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.street,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 25),
            ),
            const _OrderListButton(),
          ],
        ),
        Row(
          children: [
            Text(
              widget.customer,
              maxLines: 2,
            ),
            const Text(' • '),
            // _OrderTimer(
            //   selectedDeliveryTime: widget.order.selectedDeliveryTime,
            // ),
          ],
        ),
        // if (isPanelClosed)

        Visibility(
          visible: isPanelClosed,
          // visible: widget.note.isEmpty,
          replacement: const SizedBox(
            height: 18,
          ),
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: -10,
            leading: const Icon(
              Icons.warning_rounded,
              color: Colors.red,
            ),
            title: Text(
              widget.note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // else
        //   const SizedBox(height: 18),
        const _OrderDeliveredButtons(),
      ],
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

class _OrderListTile extends StatelessWidget {
  const _OrderListTile({
    Key? key,
    required this.listTileText,
    required this.icon,
    this.visible = true,
  }) : super(key: key);

  final String listTileText;
  final IconData? icon;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Card(
        child: ListTile(
          leading: const Icon(
            icon,
            color: Colors.black,
          ),
          title: Text(
            listTileText,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

class _OrderTip extends StatelessWidget {
  const _OrderTip({
    Key? key,
    required this.tip,
  }) : super(key: key);

  final double tip;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: tip > 0.0,
      child: Card(
        child: ListTile(
          leading: const Icon(
            Icons.favorite,
            color: Colors.black,
          ),
          title: Text(
            '${tip.toStringAsFixed(tip.truncateToDouble() == tip ? 0 : 2)}€ Trinkgeld',
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

class _OrderPhone extends StatelessWidget {
  const _OrderPhone({
    Key? key,
    required this.phone,
  }) : super(key: key);

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        leading: const Icon(
          Icons.phone,
          color: Colors.black,
          size: 22,
        ),
        title: Text(phone),
      ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Visibility(
        visible: note.isNotEmpty,
        child: Card(
          child: ListTile(
            leading: const Icon(
              Icons.warning_rounded,
              size: 25,
              color: Colors.red,
            ),
            title: Text(
              note,
              maxLines: 10,
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                () => context.read<OrderListModel>().hasCompleted,
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
