import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';

class Destination {
  const Destination({
    required this.type,
    required this.textLabel,
    required this.locationButton,
    required this.navigationButton,
    required this.panelSnapping,
    required this.panelHeightClosed,
    this.showIcon,
    this.widget,
    this.panelHeightOpen,
  });

  // Which drawer to display
  final UserSessionType type;
  final String? textLabel;
  final bool locationButton;
  final bool navigationButton;
  final bool? showIcon;
  final Widget? widget;
  final bool panelSnapping;
  final double panelHeightClosed;
  final double? panelHeightOpen;
}
