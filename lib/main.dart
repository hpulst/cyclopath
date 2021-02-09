import 'dart:async';

import 'package:cyclopath/pages/login_page.dart';
import 'package:flutter/material.dart';

import 'pages/map_page.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:
          ThemeData(accentColor: Colors.grey[100], primarySwatch: Colors.grey),
      title: 'Cyclopath',
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/map': (context) => MapView()
      },
    );
  }
}
