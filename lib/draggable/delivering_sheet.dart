import 'package:cyclopath/custom_widgets/order_card.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';

class DeliveringSheet extends StatelessWidget {
  const DeliveringSheet({
    Key? key,
    required this.model,
    required this.drawerController,
    required this.dropArrowController,
    this.bottomAppBarController,
  }) : super(key: key);

  final UserSession model;
  final AnimationController drawerController;
  final AnimationController dropArrowController;
  final AnimationController? bottomAppBarController;
  @override
  Widget build(BuildContext context) {
    drawerController.animateTo(0.4, curve: standardEasing);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
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
        OrderTable(),
      ],
    );
  }
}
