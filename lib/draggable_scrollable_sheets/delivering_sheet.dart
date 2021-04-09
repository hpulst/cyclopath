import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';

class DeliveringSheet extends StatelessWidget {
  const DeliveringSheet({
    Key? key,
    required this.model,
    required this.drawerController,
    required this.dropArrowController,
  }) : super(key: key);

  final UserSession? model;
  final AnimationController drawerController;
  final AnimationController dropArrowController;

  @override
  Widget build(BuildContext context) {
    drawerController.forward();

    return ListView(
      padding: const EdgeInsets.all(12),
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
          children: [
            const SizedBox(
              width: 45,
            ),
            Expanded(
              child: Text(
                model!.selectedUserSessionType.title!,
                style: const TextStyle(fontSize: 25.0),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              width: 45,
            ),
          ],
        ),
      ],
    );
  }
}

class OrderCard extends StatelessWidget {
  // OrderCard({Key key, this.address, this.phone, this.})
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class CorderQueue {}
