import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class OfflineSheet extends StatefulWidget {
  const OfflineSheet({
    Key? key,
    this.model,
    required this.panelController,
  }) : super(key: key);

  final PanelController panelController;
  final UserSession? model;

  @override
  _OfflineSheetState createState() => _OfflineSheetState();
}

class _OfflineSheetState extends State<OfflineSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) async {
        if (widget.panelController.isAttached) {
          await widget.panelController.animatePanelToSnapPoint(
              duration: const Duration(microseconds: 900),
              curve: Curves.decelerate);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      // physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 22.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Starte Schicht um:',
              style: TextStyle(fontSize: 26.0),
            ),
          ],
        ),
        const SizedBox(height: 22.0),
        ShiftStarts(
          panelController: widget.panelController,
        ),
        SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: false,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Go online'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShiftStarts extends StatelessWidget {
  ShiftStarts({
    Key? key,
    required this.panelController,
  }) : super(key: key);
  final PanelController panelController;

  final TimeOfDay now = TimeOfDay.now();
  final DateTime timely =
      DateTime.now().subtract(Duration(minutes: TimeOfDay.now().minute % 5));

  @override
  Widget build(BuildContext context) {
    final List timingButtons = <Widget>[];

    for (var i = 0; i < 10; i++) {
      timingButtons.add(
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Align(
            alignment: Alignment.center,
            child: i == 1
                ? ElevatedButton(
                    onPressed: () {
                      panelController.close();
                      Future.delayed(
                        const Duration(
                          milliseconds: 120,
                        ),
                        () {
                          // Wait until animations are complete to reload the state.
                          // Delay scales with the timeDilation value of the gallery.
                          context.read<UserSession>().selectedUserSessionType =
                              UserSessionType.online;
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      minimumSize: const Size(260, 0.0),
                    ),
                    child: shiftTimer(i, context),
                  )
                : OutlinedButton(
                    onPressed: () {
                      panelController.close();
                      Future.delayed(
                        const Duration(
                          milliseconds: 120,
                        ),
                        () {
                          // Wait until animations are complete to reload the state.
                          // Delay scales with the timeDilation value of the gallery.
                          context.read<UserSession>().selectedUserSessionType =
                              UserSessionType.online;
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      minimumSize: const Size(260, 0.0),
                      side: const BorderSide(width: 1.0, color: Colors.grey),
                    ),
                    child: shiftTimer(i, context),
                  ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: timingButtons.length,
      itemBuilder: (context, index) => timingButtons[index],
    );
  }

  Widget shiftTimer(int i, BuildContext context) {
    return Text(
      i < 2
          ? i < 1
              ? '${fiveBefore().format(context)} (vor ${now.minute % 5} Minuten)'
              : 'JETZT'
          : TimeOfDay.fromDateTime(
              timely.add(
                Duration(
                  minutes: 5 * (i - 1),
                ),
              ),
            ).format(context),
      style: const TextStyle(fontSize: 18),
    );
  }

  TimeOfDay fiveBefore() => TimeOfDay.fromDateTime(
        DateTime.now().subtract(
          Duration(minutes: now.minute % 5),
        ),
      );
}
