import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class SimpleDialogWidget extends StatelessWidget {
  const SimpleDialogWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Salat satt'),
      children: [
        SimpleDialogItem(
          icon: Icons.phone,
          text: 'Store anrufen',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        SimpleDialogItem(
          icon: CupertinoIcons.hand_raised_fill,
          text: 'Schicht beenden',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const Divider(),
        const Spacer(),
        SimpleDialogItem(
          icon: Icons.logout_rounded,
          color: Colors.grey,
          text: 'Logout',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class SimpleDialogItem extends StatelessWidget {
  const SimpleDialogItem(
      {Key? key,
      required this.icon,
      this.color,
      required this.text,
      required this.onPressed})
      : super(key: key);

  final IconData icon;
  final Color? color;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36.0, color: color),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
