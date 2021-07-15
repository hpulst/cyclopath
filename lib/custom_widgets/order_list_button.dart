import 'package:cyclopath/pages/orderlist_page.dart';
import 'package:flutter/material.dart';

class OrderListButton extends StatelessWidget {
  const OrderListButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => {
            Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (context) => const OrderListPage(),
              ),
            ),
          },
          icon: const Icon(
            Icons.list_rounded,
            size: 35,
          ),
        ),
      ],
    );
  }
}
