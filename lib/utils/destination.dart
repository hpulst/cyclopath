import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';

class Destination {
  const Destination({
    required this.type,
    required this.textLabel,
    this.icon,
  });

  // Which drawer to display
  final UserSessionType? type;
  final String? textLabel;
  final String? icon;
}
