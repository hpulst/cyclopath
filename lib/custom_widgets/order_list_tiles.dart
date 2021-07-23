import 'package:cyclopath/pages/orderlist_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

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

class OrderListTile extends StatelessWidget {
  const OrderListTile({
    Key? key,
    required this.listTileText,
    required this.icon,
    this.visible = true,
    this.listTileColor,
    this.iconColor = Colors.black,
  }) : super(key: key);

  final String listTileText;
  final Color? listTileColor;
  final IconData icon;
  final bool visible;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        color: listTileColor,
        elevation: 2,
        child: ListTile(
          minLeadingWidth: 20,
          leading: Icon(
            icon,
            color: iconColor,
          ),
          title: Text(
            listTileText,
            maxLines: 10,
          ),
        ),
      ),
    );
  }
}

class OrderPhone extends StatelessWidget {
  const OrderPhone({
    Key? key,
    required this.phone,
  }) : super(key: key);

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Material(
            color: Colors.white,
            child: Ink(
              decoration: const ShapeDecoration(
                color: Colors.black,
                shape: CircleBorder(),
              ),
              child: IconButton(
                padding: const EdgeInsets.all(15),
                onPressed: () => url_launcher.launch('tel://$phone'),
                enableFeedback: true,
                tooltip: phone,
                icon: const Icon(
                  Icons.phone,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          const Text('KundInnen anrufen'),
        ],
      ),
    );
  }
}
