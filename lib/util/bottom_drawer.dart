import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomDrawer extends StatelessWidget {
  const BottomDrawer({
    Key key,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.leading,
  }) : super(key: key);

  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      child: Material(
        // color: Theme.of(context).bottomSheetTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: TimeOfDay(),
      ),
    );
  }
}

class TimeOfDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: Text('${DateTime.now()}'),
            // Text('${TimeOfDay.fromDateTime(DateTime.now().subtract(Duration(minutes: (TimeOfDay.now().minute % 5)))} VOR  ${now.minute % 5} MINUTEN'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('JETZT'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Now'),
          ),
        ],
      ),
    );
  }
}
