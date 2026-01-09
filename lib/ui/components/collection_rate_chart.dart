import 'dart:math';

import 'package:flutter/material.dart';

class CollectionRateChart extends StatelessWidget {
  final int collectedCount;
  final int totalCount;
  final double size;

  const CollectionRateChart({
    super.key,
    required this.collectedCount,
    required this.totalCount,
    this.size = 72,
  });

  @override
  // 回収率チャートを描画する。
  Widget build(BuildContext context) {
    final rate = _calculateRate();
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CollectionRatePainter(
          rate: rate,
          primaryColor: Theme.of(context).primaryColor,
        ),
        child: Center(
          child: Text(
            '$rate%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  // 回収率を計算する。
  int _calculateRate() {
    if (totalCount == 0) return 0;
    return ((collectedCount / totalCount) * 100).round();
  }
}

class _CollectionRatePainter extends CustomPainter {
  final int rate;
  final Color primaryColor;

  _CollectionRatePainter({
    required this.rate,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.16;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.black.withOpacity(0.08);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = primaryColor;

    canvas.drawCircle(center, radius, basePaint);

    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * (rate / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CollectionRatePainter oldDelegate) {
    return oldDelegate.rate != rate || oldDelegate.primaryColor != primaryColor;
  }
}
