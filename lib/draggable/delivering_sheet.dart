import 'package:cyclopath/models/order.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';

class DeliveringSheet extends StatelessWidget {
  const DeliveringSheet({
    Key? key,
    required this.model,
    required this.drawerController,
    required this.dropArrowController,
    required this.bottomAppBarController,
  }) : super(key: key);

  final UserSession model;
  final AnimationController drawerController;
  final AnimationController dropArrowController;
  final AnimationController bottomAppBarController;
  @override
  Widget build(BuildContext context) {
    // drawerController.animateTo(0.4, curve: standardEasing);

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
        Row(
          children: [
            const SizedBox(
              width: 45,
            ),
            Expanded(
              child: Text(
                model.selectedUserSessionType.title!,
                // 'Unterwegs',
                style: const TextStyle(fontSize: 25.0),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              width: 45,
            ),
          ],
        ),
        OrderTable(),
      ],
    );
  }
}

class OrderTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Order>>(
      future: loadOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${snapshot.data}'),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }

  // Widget build(BuildContext context) {
  //   return FutureBuilder<List<WorkoutTable>>(
  //       future: loadWorkouts(filename),
  //       builder: (context, snapshot) {
  //         if (snapshot.hasData) {
  //           return SimpleObjectView(
  //               simpleObjects: snapshot.data, filename: filename);
  //         } else if (snapshot.hasError) {
  //           return Text('${snapshot.error}');
  //         }
  //         return const CircularProgressIndicator();
  //       });
}
