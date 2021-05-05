import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class OfflineSheet extends StatefulWidget {
  const OfflineSheet({
    this.model,
    required this.panelController,
  });

  final PanelController panelController;
  final UserSession? model;

  @override
  _OfflineSheetState createState() => _OfflineSheetState();
}

class _OfflineSheetState extends State<OfflineSheet> {
  @override
  void initState() {
    super.initState();
    if (widget.panelController.isAttached) {
      widget.panelController.animatePanelToSnapPoint(curve: Curves.easeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      // padding: const EdgeInsets.all(12),
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
              'Starte Schicht um:',
              style: TextStyle(fontSize: 26.0),
            ),
          ],
        ),
        const SizedBox(height: 22.0),
        ShiftStarts(
          panelController: widget.panelController,
        ),
        Container(
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
    final timingButtons = <Widget>[];

    for (var i = 0; i < 7; i++) {
      timingButtons.add(
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton(
            onPressed: () {
              panelController.close();
              Future.delayed(
                const Duration(
                  // milliseconds: panelController.value == 1 ? 300 : 120,

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
          ),
        ),
      );
    }

    return Column(
      children: timingButtons,
    );
  }

  Text shiftTimer(int i, BuildContext context) {
    return Text(
      i < 2
          ? i < 1
              ? '${fiveBelow().format(context)} (vor ${now.minute % 5} Minuten)'
              : 'JETZT'
          : TimeOfDay.fromDateTime(
              timely.add(
                Duration(
                  minutes: 5 * (i - 1),
                ),
              ),
            ).format(context),
      style: const TextStyle(fontSize: 20),
    );
  }

  TimeOfDay fiveBelow() => TimeOfDay.fromDateTime(
        DateTime.now().subtract(
          Duration(minutes: now.minute % 5),
        ),
      );
}

  // var _dateTime = DateTime.now();
  // late Timer _timer;

  // @override
  // void initState() {
  //   super.initState();
  //   _updateTime();
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _timer.cancel();
  // }
  // void _updateTime() {
  //   setState(() {
  //     _dateTime = DateTime.now();
  //     _timer = Timer(
  //       const Duration(seconds: 1) -
  //           Duration(milliseconds: _dateTime.millisecond),
  //       _updateTime,
  //     );
  //   });
  // }
