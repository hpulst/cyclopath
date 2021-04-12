import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OfflineSheet extends StatelessWidget {
  const OfflineSheet({
    required this.model,
    required this.drawerController,
    required this.dropArrowController,
  });

  final UserSession model;
  final AnimationController drawerController;
  final AnimationController dropArrowController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Column(
          children: [
            const SizedBox(
              height: 6.0,
            ),
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: const BorderRadius.all(
                  Radius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 15,
                ),
                const SizedBox(
                  width: 1,
                ),
                Expanded(
                  child: Text(
                    '${model.selectedUserSessionType.title}',
                    style: const TextStyle(fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  width: 45,
                ),
              ],
            ),
            const Divider(
              height: 20,
            ),
            ShiftStarts(
              drawerController: drawerController,
              dropArrowController: dropArrowController,
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
        ),
      ],
    );
  }
}

class ShiftStarts extends StatelessWidget {
  ShiftStarts({
    required this.drawerController,
    required this.dropArrowController,
  });

  final AnimationController drawerController;
  final AnimationController dropArrowController;

  final TimeOfDay now = TimeOfDay.now();
  final DateTime timely =
      DateTime.now().subtract(Duration(minutes: TimeOfDay.now().minute % 5));

  @override
  Widget build(BuildContext context) {
    final timingButtons = <Widget>[];

    for (var i = 0; i < 6; i++) {
      timingButtons.add(
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton(
            onPressed: () {
              drawerController.reverse();
              dropArrowController.forward();
              // Future.delayed(
              //   const Duration(seconds: 1),
              //   () {
              print('Delay');
              context.read<UserSession>().selectedUserSessionType =
                  UserSessionType.online;
            },
            // ),
            // };
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              minimumSize: const Size(260, 0.0),
            ),
            child: Text(i < 2
                ? i < 1
                    ? '${TimeOfDay.fromDateTime(DateTime.now().subtract(Duration(minutes: now.minute % 5))).format(context)} (vor ${now.minute % 5} Minuten)'
                    : 'JETZT'
                : TimeOfDay.fromDateTime(
                    timely.add(
                      Duration(
                        minutes: 5 * (i - 1),
                      ),
                    ),
                  ).format(context)),
          ),
        ),
        // const SizedBox(height: 10),
      );
    }

    return Column(
      children: timingButtons,
    );
  }
}
