import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime expiretime;
  final TextStyle? textStyle;
  final VoidCallback? onExpired;

  const CountdownTimer({
    Key? key,
    required this.expiretime,
    this.textStyle,
    this.onExpired,
  }) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _calcRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calcRemaining();
    });
  }

    void _calcRemaining() {
      final now = DateTime.now();
      final diff = widget.expiretime.difference(now);
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
    }

    @override
    void dispose() {
      _timer?.cancel();
      super.dispose();
    }

    String _format(Duration d) {
      final hours = d.inHours.toString().padLeft(2, "0");
      final minutes = (d.inMinutes % 60).toString().padLeft(2, "0");
      return "$hours時間$minutes分";
    }

    @override
    Widget build(BuildContext context) {
      return Text(
        _format(_remaining),
        style: widget.textStyle ??
            Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize:10,
              color: Colors.black,
            ),
      );
    }
  }