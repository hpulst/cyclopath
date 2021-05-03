import 'package:cyclopath/models/order_list_model.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:cyclopath/pages/login_page.dart';
import 'package:cyclopath/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/map_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderListModel()..loadOrders(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        title: 'Cyclopath',
        home: MapView(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => LoginPage(),
          '/map': (context) => MapView()
        },
      ),
    );
  }
}
