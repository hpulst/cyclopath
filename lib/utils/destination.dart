import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';

class Destination {
  const Destination({
    required this.type,
    required this.textLabel,
    this.iconIsVisible,
    this.color,
  });

  // Which drawer to display
  final UserSessionType? type;
  final String? textLabel;
  final bool? iconIsVisible;
  final Color? color;
}
