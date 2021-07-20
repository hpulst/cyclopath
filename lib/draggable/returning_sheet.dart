import 'dart:async';

import 'package:cyclopath/custom_widgets/order_list_button.dart';
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
    required this.setRoute,
  }) : super(key: key);

  final PanelController panelController;
  final VoidCallback setRoute;

  @override
  _ReturningSheetState createState() => _ReturningSheetState();
}

class _ReturningSheetState extends State<ReturningSheet> {
  late Timer _timer;
  late Duration _diff;

  @override
  void initState() {
    final model = context.read<OrderListModel>();
    model.createOfficeMarkers();
    model.createRoute();
    widget.setRoute();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String duration =
        context.read<OrderListModel>().directions.totalDuration;
    // final Duration d = DataTime.parse(duration);
    print('Duration: $duration');

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Expanded(
              Text(
                'Wir erwarten dich in ${duration}',
                style: TextStyle(fontSize: 22),
              ),
              OrderTimer(duration: Duration(minutes: 20)),
              // ),
              // ),
              const OrderListButton(),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          _ReturnCompleteSlide(
            // id: id,
            setRoute: widget.setRoute,
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
    // required this.id,
    required this.setRoute,
    required this.panelController,
  }) : super(key: key);

  // final String id;
  final VoidCallback setRoute;
  final PanelController panelController;

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
    // const _listKey = ValueKey('slider');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTapDown: (TapDownDetails details) {
          panelController.close();
        },
        child: SlideAction(
          // key: _listKey,
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
