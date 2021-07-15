import 'package:cyclopath/models/map_model.dart';
import 'package:cyclopath/models/order_list_model.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:cyclopath/pages/login_page.dart';
import 'package:cyclopath/theme.dart';
import 'package:cyclopath/utils/json_parsing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_widgets/adaptive_navi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final user = prefs.getString('user');
  final isOnline = prefs.getString('isOnline');

  runApp(MyApp(user: user));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, this.user}) : super(key: key);

  final String? user;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => OrderListModel(repository: OrderRepository())
              ..createOfficeMarkers()
              ..getCurrentPosition()
            // ..loadOrders(),
            ),
        ChangeNotifierProvider(
          create: (_) => UserSession(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        title: 'Cyclopath',
        home: user == null ? LoginPage() : AdaptiveNav(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => LoginPage(),
          '/map': (context) => AdaptiveNav()
        },
      ),
    );
  }
}
