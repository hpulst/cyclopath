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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      children: [
        const SizedBox(
          height: 20,
        ),
        SimpleDialogItem(
          icon: Icons.phone,
          text: 'Store anrufen',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(
          height: 20,
        ),
        SimpleDialogItem(
          icon: Icons.pedal_bike_rounded,
          text: 'Statistik',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(
          height: 20,
        ),
        SimpleDialogItem(
          icon: CupertinoIcons.hand_raised_fill,
          text: 'Schicht beenden',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(
          height: 50,
        ),
        const Divider(
          color: Colors.grey,
        ),
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
            child: Text(text, style: Theme.of(context).textTheme.headline5),
          ),
        ],
      ),
    );
  }
}
