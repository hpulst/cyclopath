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
        )
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        title: 'Cyclopath',
        home: LoginPage(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => LoginPage(),
          '/map': (context) => MapView()
        },
      ),
    );
  }
}
