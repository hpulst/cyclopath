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
  var isLoading = true;

  Future<void> fetchOrderLoadingStatus() {
    return Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        isLoading = context.read<OrderListModel>().isLoading;

        setState(() {
          if (!isLoading) {
            context.read<UserSession>().selectedUserSessionType =
                UserSessionType.delivering;
            Vibration.vibrate();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchOrderLoadingStatus();

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(
          height: 12.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.all(
                  Radius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 22,
        ),
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
