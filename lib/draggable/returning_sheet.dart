import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';

class ReturningSheet extends StatelessWidget {
  const ReturningSheet({
    Key? key,
    required this.model,
  }) : super(key: key);

  final UserSession? model;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            IconButton(
              icon: const Icon(Icons.expand_less),
              iconSize: 30,
              onPressed: () {},
            ),
            const SizedBox(
              width: 1,
            ),
            const Expanded(
              child: Text(
                // model!.selectedUserSessionType.title!,
                'hi',
                style: TextStyle(fontSize: 25.0),
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
