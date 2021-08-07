import 'package:cyclopath/models/order_list_model.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vibration/vibration.dart';

class WaitingSheet extends StatefulWidget {
  const WaitingSheet({
    Key? key,
    this.model,
    required this.panelController,
  }) : super(key: key);

  final UserSession? model;
  final PanelController panelController;

  @override
  _WaitingSheetState createState() => _WaitingSheetState();
}

class _WaitingSheetState extends State<WaitingSheet> {
  @override
  void initState() {
    // Future.delayed(const Duration(seconds: 2), () {
    context.read<OrderListModel>().loadOrders();
    // });
    super.initState();
  }

  void setSession(BuildContext context) {
    Future.delayed(
      const Duration(
        milliseconds: 1,
      ),
      () {
        Vibration.vibrate();
        widget.panelController.close();
        context.read<UserSession>().selectedUserSessionType =
            UserSessionType.delivering;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveOrders =
        context.select((OrderListModel model) => model.hasActiveOrders);

    if (hasActiveOrders) {
      setSession(context);
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 22.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Suche Fahrten...',
              style: TextStyle(fontSize: 26.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 22.0),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        widget.panelController.close();
                        Future.delayed(
                          const Duration(
                            milliseconds: 120,
                          ),
                          () {
                            // Wait until animations are complete to reload the state.
                            // Delay scales with the timeDilation value of the gallery.
                            context
                                    .read<UserSession>()
                                    .selectedUserSessionType =
                                UserSessionType.delivering;
                          },
                        );
                      },
                      // tooltip: 'Los',
                      iconSize: 60,
                      icon: const Icon(
                        Icons.stop_circle,
                        color: Colors.red,
                      ),
                    ),
                    const Text('Los!'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
