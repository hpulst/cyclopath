import 'dart:async';

import 'package:cyclopath/custom_widgets/order_list_tiles.dart';
import 'package:cyclopath/custom_widgets/route_timer.dart';
import 'package:cyclopath/models/order_list_model.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vibration/vibration.dart';

class DeliveringSheet extends StatefulWidget {
  const DeliveringSheet({
    Key? key,
    required this.panelController,
    required this.setCameraToRoute,
  }) : super(key: key);

  final PanelController panelController;
  final VoidCallback setCameraToRoute;

  @override
  _DeliveringSheetState createState() => _DeliveringSheetState();
}

class _DeliveringSheetState extends State<DeliveringSheet> {
  @override
  void initState() {
    widget.panelController.close();
    setCamera(widget.setCameraToRoute);
    super.initState();
  }

  void setCamera(VoidCallback setCameraToRoute) {
    Future.delayed(
      const Duration(milliseconds: 500),
      () async {
        setCameraToRoute();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrderCard(
      panelController: widget.panelController,
      setCameraToRoute: widget.setCameraToRoute,
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    Key? key,
    required this.panelController,
    required this.setCameraToRoute,
  }) : super(key: key);

  final PanelController panelController;
  final VoidCallback setCameraToRoute;

  void setSession(BuildContext context) {
    Future.delayed(
      const Duration(
        milliseconds: 1,
      ),
      () {
        context.read<UserSession>().selectedUserSessionType =
            UserSessionType.returning;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveOrders =
        context.select((OrderListModel model) => model.hasActiveOrders);

    if (!hasActiveOrders) {
      setSession(context);
    }
    final currentOrder =
        context.select((OrderListModel model) => model.currentOrder);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        children: [
          OrderPreviewCard(
            street: currentOrder.street,
            customer: currentOrder.customer,
            note: currentOrder.note,
            selectedDeliveryTime: currentOrder.selectedDeliveryTime,
            id: currentOrder.id,
            panelController: panelController,
            setCameraToRoute: setCameraToRoute,
          ),
          const SizedBox(height: 10),
          if (currentOrder.note.isNotEmpty)
            OrderListTile(
              listTileText: currentOrder.note,
              listTileColor: Colors.red.shade100,
              icon: Icons.warning_rounded,
              iconColor: Colors.red,
            ),
          if (currentOrder.tip > 0.0)
            OrderListTile(
              listTileText:
                  '${currentOrder.tip.toStringAsFixed(currentOrder.tip.truncateToDouble() == currentOrder.tip ? 0 : 2)}€ Trinkgeld',
              icon: Icons.favorite,
            ),
          if (currentOrder.email.isNotEmpty)
            OrderListTile(
              listTileText: currentOrder.email,
              icon: Icons.mail_outline_rounded,
            ),
          OrderListTile(
            listTileText: currentOrder.ordernumber,
            icon: Icons.airplane_ticket_rounded,
          ),
          OrderPhone(phone: currentOrder.phone),
        ],
      ),
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
    required this.setCameraToRoute,
  }) : super(key: key);

  final String street;
  final String customer;
  final String note;
  final DateTime selectedDeliveryTime;
  final String id;
  final PanelController panelController;
  final VoidCallback setCameraToRoute;

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
            Expanded(
              child: Text(
                street,
                // maxLines: 3,
                // overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 25),
              ),
            ),
            const OrderListButton(),
          ],
        ),
        Row(
          children: [
            Text(
              customer,
              maxLines: 2,
            ),
            const Text(' • '),
            OrderTimer(
              duration: selectedDeliveryTime.difference(DateTime.now()),
            ),
          ],
        ),
        Visibility(
          visible: isPanelClosed && note.isNotEmpty,
          replacement: const SizedBox(
            height: 40,
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
          setCameraToRoute: setCameraToRoute,
          panelController: panelController,
        ),
      ],
    );
  }
}

class _OrderCompleteSlide extends StatelessWidget {
  const _OrderCompleteSlide({
    Key? key,
    required this.id,
    required this.setCameraToRoute,
    required this.panelController,
  }) : super(key: key);

  final String id;
  final VoidCallback setCameraToRoute;
  final PanelController panelController;

  void setSession(BuildContext context) {
    Future.delayed(
      const Duration(
        milliseconds: 1,
      ),
      () {
        context.read<UserSession>().selectedUserSessionType =
            UserSessionType.returning;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _listKey = ValueKey(id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SlideAction(
        key: _listKey,
        onSubmit: () {
          panelController.close();
          Future.delayed(
            const Duration(milliseconds: 800),
            () async {
              await Vibration.vibrate(duration: 100);
              final model = context.read<OrderListModel>();
              final order = model.orderById(id).copyWith(newcomplete: true);
              model.updateOrder(order);

              if (model.hasActiveOrders) {
                await model.createRoute();
                setCameraToRoute();
              } else {
                setSession(context);
              }
            },
          );
        },
        animationDuration: const Duration(milliseconds: 100),
        text: 'Zugestellt',
        innerColor: Colors.white,
        outerColor: Colors.black,
      ),
    );
  }
}
