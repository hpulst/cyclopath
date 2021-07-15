import 'dart:async';

import 'package:flutter/material.dart';

class OrderTimer extends StatefulWidget {
  const OrderTimer({Key? key, required this.duration}) : super(key: key);

  final Duration duration;

  @override
  _OrderTimerState createState() => _OrderTimerState();
}

class _OrderTimerState extends State<OrderTimer> {
  late Timer _timer;
  late Duration _diff;

  @override
  void initState() {
    super.initState();

    startTimer(
      widget.duration,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void startTimer(Duration duration) {
    _diff = duration;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => setState(
        () {
          _diff = _diff - const Duration(seconds: 1);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final sDuration =
        '${twoDigits(_diff.inMinutes.abs())}:${twoDigits(_diff.inSeconds.remainder(60).abs())}';

    return Text(
      _diff.isNegative ? 'vor ' + sDuration : 'in ' + sDuration,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: _diff.isNegative
            ? Colors.red.shade600
            : Theme.of(context).primaryColor,
      ),
    );
  }
}
