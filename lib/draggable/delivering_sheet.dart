import 'dart:async';

import 'package:cyclopath/models/order_list_model.dart';
import 'package:cyclopath/pages/orderlist_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class DeliveringSheet extends StatefulWidget {
  const DeliveringSheet({
    Key? key,
    required this.panelController,
    required this.getCurrentLocation,
  }) : super(key: key);

  final PanelController panelController;
  final VoidCallback getCurrentLocation;

  @override
  _DeliveringSheetState createState() => _DeliveringSheetState();
}

class _DeliveringSheetState extends State<DeliveringSheet> {
  @override
  void initState() {
    //   WidgetsBinding.instance?.addPostFrameCallback((_) async {
    //     await widget.panelController.animatePanelToSnapPoint(
    //         duration: const Duration(microseconds: 500),
    //         curve: Curves.decelerate);
    // });
    super.initState();
    widget.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return OrderCard(
      panelController: widget.panelController,
      getCurrentLocation: widget.getCurrentLocation,
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    Key? key,
    required this.panelController,
    required this.getCurrentLocation,
  }) : super(key: key);

  final PanelController panelController;
  final VoidCallback getCurrentLocation;

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
                selectedDeliveryTime:
                    orderList.currentOrder.selectedDeliveryTime,
                id: orderList.currentOrder.id,
                panelController: panelController,
                getCurrentLocation: getCurrentLocation,
              ),
              const SizedBox(height: 10),
              if (orderList.currentOrder.note.isNotEmpty)
                OrderListTile(
                  listTileText: orderList.currentOrder.note,
                  listTileColor: Colors.red.shade100,
                  icon: Icons.warning_rounded,
                  iconColor: Colors.red,
                ),
              if (orderList.currentOrder.tip > 0.0)
                OrderListTile(
                  listTileText:
                      '${orderList.currentOrder.tip.toStringAsFixed(orderList.currentOrder.tip.truncateToDouble() == orderList.currentOrder.tip ? 0 : 2)}€ Trinkgeld',
                  icon: Icons.favorite,
                ),
              if (orderList.currentOrder.email.isNotEmpty)
                OrderListTile(
                  listTileText: orderList.currentOrder.email,
                  icon: Icons.mail_outline_rounded,
                ),
              OrderListTile(
                listTileText: orderList.currentOrder.ordernumber,
                icon: Icons.airplane_ticket_rounded,
              ),
              OrderListTile(
                listTileText: orderList.currentOrder.complete.toString(),
                icon: Icons.airplane_ticket_rounded,
              ),
              _OrderPhone(phone: orderList.currentOrder.phone),
            ],
          ),
        );
      },
    );
  }
}

class OrderPreviewCard extends StatelessWidget {
  const OrderPreviewCard({
    Key? key,
    required this.street,
    required this.customer,
    required this.note,
    required this.selectedDeliveryTime,
    required this.id,
    required this.panelController,
    required this.getCurrentLocation,
  }) : super(key: key);

  final String street;
  final String customer;
  final String note;
  final DateTime selectedDeliveryTime;
  final String id;
  final PanelController panelController;
  final VoidCallback getCurrentLocation;

  @override
  Widget build(BuildContext context) {
    final isPanelClosed = panelController.isPanelClosed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              street,
              // maxLines: 3,
              // overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 25),
            ),
            const _OrderListButton(),
          ],
        ),
        Row(
          children: [
            Text(
              customer,
              maxLines: 2,
            ),
            const Text(' • '),
            _OrderTimer(
              selectedDeliveryTime: selectedDeliveryTime,
            ),
          ],
        ),
        Visibility(
          visible: isPanelClosed && note.isNotEmpty,
          replacement: const SizedBox(
            height: 18,
          ),
          child: SizedBox(
            height: 40,
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              horizontalTitleGap: -10,
              leading: const Icon(
                Icons.warning_rounded,
                color: Colors.red,
              ),
              title: Text(
                note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        _OrderCompleteSlide(
          id: id,
          getCurrentLocation: getCurrentLocation,
        ),
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

class OrderListTile extends StatelessWidget {
  const OrderListTile({
    Key? key,
    required this.listTileText,
    required this.icon,
    this.visible = true,
    this.listTileColor,
    this.iconColor = Colors.black,
  }) : super(key: key);

  final String listTileText;
  final Color? listTileColor;
  final IconData icon;
  final bool visible;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        color: listTileColor,
        elevation: 2,
        child: ListTile(
          minLeadingWidth: 20,
          leading: Icon(
            icon,
            color: iconColor,
          ),
          title: Text(
            listTileText,
            maxLines: 10,
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.white,
        child: Ink(
          decoration: const ShapeDecoration(
            color: Colors.black,
            shape: CircleBorder(),
          ),
          child: IconButton(
            padding: const EdgeInsets.all(15),
            onPressed: () => url_launcher.launch('tel://$phone'),
            enableFeedback: true,
            tooltip: phone,
            icon: const Icon(
              Icons.phone,
              color: Colors.white,
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

class _OrderCompleteSlide extends StatelessWidget {
  const _OrderCompleteSlide({
    Key? key,
    required this.id,
    required this.getCurrentLocation,
  }) : super(key: key);

  final String id;
  final VoidCallback getCurrentLocation;

  @override
  Widget build(BuildContext context) {
    final _listKey = ValueKey(id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SlideAction(
        key: _listKey,
        onSubmit: () {
          Future.delayed(
            const Duration(seconds: 1),
            () {
              // sliderKey.currentState?.reset();
              final model = context.read<OrderListModel>();
              final order = model.orderById(id).copyWith(newcomplete: true);
              model.updateOrder(order);

              // model.createMarkers();
              model.removeMarker(order.id);
              getCurrentLocation();
            },
          );
        },
        height: 50,
        sliderButtonIconPadding: 10,
        text: 'Zugestellt',
        innerColor: Colors.white,
        outerColor: Colors.black,
      ),
    );
  }
}
