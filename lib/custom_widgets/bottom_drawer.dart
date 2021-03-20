import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomDrawer extends StatelessWidget {
  const BottomDrawer({
    Key? key,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.leading,
  }) : super(key: key);

  final GestureDragUpdateCallback? onVerticalDragUpdate;
  final GestureDragEndCallback? onVerticalDragEnd;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      child: Material(
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: SelectTime(),
      ),
    );
  }
}

class SelectTime extends StatelessWidget {
  final TimeOfDay now = TimeOfDay.now();
  final DateTime timely =
      DateTime.now().subtract(Duration(minutes: TimeOfDay.now().minute % 5));
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        padding: const EdgeInsets.all(12),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                height: 3.0,
              ),
              Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius:
                        const BorderRadius.all(Radius.circular(12.0))),
              ),
              const SizedBox(height: 10),
              Text(
                'Schichtstart auswählen:',
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () {},
              //   style: ElevatedButton.styleFrom(
              //     padding: const EdgeInsets.all(20),
              //     minimumSize: const Size(260, 0.0),
              //   ),
              //   child: Text(
              //       '${TimeOfDay.fromDateTime(DateTime.now().subtract(Duration(minutes: TimeOfDay.now().minute % 5))).format(context)} (vor  ${now.minute % 5} Minuten)'),
              // ),
              const SizedBox(height: 10),
              ChipsFactory(),
              // OutlinedButton(
              //   onPressed: () {},
              //   // style: ElevatedButton.styleFrom(
              //   //   padding: const EdgeInsets.all(20),
              //   //   minimumSize: const Size(260, 0.0),
              //   // ),
              //   child: const Text(
              //     'JETZT',
              //   ),
              // ),
              // const SizedBox(height: 10),
              // OutlinedButton(
              //   onPressed: () {},
              //   // style: OutlinedButton.styleFrom(
              //   //   padding: const EdgeInsets.all(20),
              //   //   minimumSize: const Size(260, 0.0),
              //   // ),
              //   child: Text(TimeOfDay.fromDateTime(
              //     timely.add(
              //       const Duration(minutes: 5),
              //     ),
              //   ).format(context)),
              // ),
              // const SizedBox(height: 10),
              // // ElevatedButton(
              // //   onPressed: () {},
              // //   style: ElevatedButton.styleFrom(
              // //     padding: const EdgeInsets.all(20),
              // //     minimumSize: const Size(260, 0.0),
              // //   ),
              // //   child: Text(TimeOfDay.fromDateTime(
              // //     timely.add(
              // //       const Duration(minutes: 10),
              // //     ),
              // //   ).format(context)),
              // // ),
              // // const SizedBox(height: 10),
              // // ElevatedButton(
              // //   onPressed: () {},
              // //   style: ElevatedButton.styleFrom(
              // //     padding: const EdgeInsets.all(20),
              // //     minimumSize: const Size(260, 0.0),
              // //   ),
              // //   child: Text(TimeOfDay.fromDateTime(
              // //     timely.add(
              // //       const Duration(minutes: 15),
              // //     ),
              // //   ).format(context)),
              // // ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChipsFactory extends StatelessWidget {
  final TimeOfDay now = TimeOfDay.now();
  final DateTime timely =
      DateTime.now().subtract(Duration(minutes: TimeOfDay.now().minute % 5));

  final int _value = 1;

  @override
  Widget build(BuildContext context) {
    List<Widget> chips;
    chips = [];

    chips.add(
      ChoiceChip(
          label: Text(
              '${TimeOfDay.fromDateTime(DateTime.now().subtract(Duration(minutes: TimeOfDay.now().minute % 5))).format(context)} (vor  ${now.minute % 5} Minuten)'),
          selected: _value == 0),
    );
    chips.add(
      ChoiceChip(label: const Text('JETZT'), selected: _value == 0),
    );

    for (var i = 1; i < 6; i++) {
      chips.add(
        ChoiceChip(
            label: Text(
              TimeOfDay.fromDateTime(
                timely.add(
                  Duration(minutes: 5 * i),
                ),
              ).format(context),
            ),
            selected: _value == i + 2),
      );
    }
    return Container();
  }
}
