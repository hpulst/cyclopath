import 'dart:async';

import 'package:cyclopath/pages/login_page.dart';
import 'package:cyclopath/theme.dart';
import 'package:flutter/material.dart';

import 'pages/map_page.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      title: 'Cyclopath',
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/map': (context) => MapView()
      },
    );
  }
}
