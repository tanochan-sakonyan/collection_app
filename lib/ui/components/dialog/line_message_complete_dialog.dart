import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LineMessageCompleteDialog extends StatefulWidget {
  const LineMessageCompleteDialog({super.key});
  @override
  State<LineMessageCompleteDialog> createState() =>
      _LineMessageCompleteDialogState();
}

class _LineMessageCompleteDialogState extends State<LineMessageCompleteDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: SizedBox(
        width: 320,
        height: 240,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✨', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 6),
                Text('送信完了',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                const Text('✨', style: TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: SvgPicture.asset(
                      'assets/icons/reverse_icon.svg',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    bottom: 0,
                    child: Text(
                      '✨',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Text(
                      '✨',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
