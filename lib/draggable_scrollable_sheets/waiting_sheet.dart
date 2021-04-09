import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';

class WaitingSheet extends StatelessWidget {
  const WaitingSheet({
    Key? key,
    this.model,
    required this.drawerController,
    required this.dropArrowController,
  }) : super(key: key);

  final UserSession? model;
  final AnimationController drawerController;
  final AnimationController dropArrowController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(
          height: 6.0,
        ),
        Center(
          child: Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: const BorderRadius.all(
                Radius.circular(12.0),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          children: const [
            SizedBox(
              width: 45,
            ),
            // model.selectedUserSessionType.title,
            Expanded(
              child: Text(
                'Statisik',
                style: TextStyle(fontSize: 25.0),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 45,
            ),
          ],
        ),

        const Divider(
          height: 20,
        ),
        // Expanded(child: SizedBox()),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    drawerController.reverse();
                  },
                  tooltip: 'Gehe offline',
                  iconSize: 60,
                  icon: const Icon(
                    Icons.stop_circle,
                    color: Colors.red,
                  ),
                ),
                const Text('Gehe offline'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
