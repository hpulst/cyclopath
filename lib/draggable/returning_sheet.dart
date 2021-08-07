import 'dart:async';

import 'package:cyclopath/custom_widgets/adaptive_navi.dart';
import 'package:cyclopath/custom_widgets/order_list_tiles.dart';
import 'package:cyclopath/custom_widgets/route_timer.dart';
import 'package:cyclopath/models/order_list_model.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ReturningSheet extends StatefulWidget {
  const ReturningSheet({
    Key? key,
    required this.panelController,
    required this.setCameraToRoute,
  }) : super(key: key);

  final PanelController panelController;
  final SetCameraToRoute setCameraToRoute;

  @override
  _ReturningSheetState createState() => _ReturningSheetState();
}

class _ReturningSheetState extends State<ReturningSheet> {
  @override
  void initState() {
    super.initState();

    final model = context.read<OrderListModel>();

    model.createOfficeMarkers();
    model.createRoute();
    widget.setCameraToRoute(model.routeBounds, model.destinationMarkerId);
  }

  @override
  Widget build(BuildContext context) {
    final durationInSeconds = context
        .select((OrderListModel order) => order.directions.totalDurationValue);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Wir erwarten dich ',
                style: TextStyle(fontSize: 22),
              ),
              OrderTimer(
                duration: Duration(seconds: durationInSeconds),
                fontSize: 22.0,
              ),
              const Spacer(),
              const OrderListButton(),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          _ReturnCompleteSlide(
            setCameraToRoute: widget.setCameraToRoute,
            panelController: widget.panelController,
          ),
        ],
      ),
    );
  }
}

class _ReturnCompleteSlide extends StatelessWidget {
  const _ReturnCompleteSlide({
    Key? key,
    required this.setCameraToRoute,
    required this.panelController,
  }) : super(key: key);

  final PanelController panelController;
  final SetCameraToRoute setCameraToRoute;

  void setSession(BuildContext context) {
    Future.delayed(
      const Duration(
        milliseconds: 1,
      ),
      () {
        context.read<UserSession>().selectedUserSessionType =
            UserSessionType.waiting;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTapDown: (TapDownDetails details) {
          panelController.close();
        },
        child: SlideAction(
          onSubmit: () {
            Future.delayed(
              const Duration(seconds: 1),
              () async {
                setSession(context);
              },
            );
          },
          text: 'Zurück im Store!',
          innerColor: Colors.white,
          outerColor: Colors.black,
        ),
      ),
    );
  }
}
