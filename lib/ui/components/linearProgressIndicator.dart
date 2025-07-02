import 'package:flutter/material.dart';

class LinearMeterLoadingOverlay extends StatefulWidget {
  const LinearMeterLoadingOverlay({super.key});
  @override
  State<LinearMeterLoadingOverlay> createState() => _LinearMeterLoadingOverlayState();
}

class _LinearMeterLoadingOverlayState extends State<LinearMeterLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.85),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = _controller.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Loading...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF76DCC6),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 332,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF04E0B8)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Text(
                  //   "${(progress * 100).toInt()}%",
                  //   style: const TextStyle(
                  //       fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  // ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
