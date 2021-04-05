import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';

class WaitingSheet extends StatelessWidget {
  const WaitingSheet(
      {Key? key,
      required this.model,
      required this.toggleDraggableScrollableSheet})
      : super(key: key);
  final UserSession? model;
  final VoidCallback toggleDraggableScrollableSheet;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            IconButton(
              icon: const Icon(Icons.expand_less),
              iconSize: 30,
              onPressed: () {
                toggleDraggableScrollableSheet();
              },
            ),
            const SizedBox(
              width: 1,
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
