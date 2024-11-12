import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const ToggleButton({
    super.key,
    this.initialValue = true,
    required this.onChanged,
  });

  @override
  ToggleButtonState createState() => ToggleButtonState();
}

class ToggleButtonState extends State<ToggleButton>
    with SingleTickerProviderStateMixin {
  late bool isOn;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialValue;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );
    _animation = Tween<double>(
      begin: 3.0,
      end: 27.0,
    ).animate(_controller);
    if (isOn) {
      _controller.forward();
    }
  }

  void toggleSwitch() {
    setState(() {
      isOn = !isOn;
      widget.onChanged(isOn);
      if (isOn) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSwitch,
      child: Container(
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          color: isOn ? const Color(0xFF5AFF9C) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  left: _animation.value,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
