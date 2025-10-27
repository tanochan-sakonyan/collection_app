import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/modules/features/admob/interstitial_singleton.dart';

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
    Future.delayed(const Duration(seconds: 2), () async {
      if (interstitial.isReady) {
        await interstitial.showAndWait(); // 広告を閉じるまで待機
      }
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✨', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 6),
                Text(S.of(context)!.completeSending,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                const Text('✨', style: TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 140,
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
                    left: 4,
                    bottom: 8,
                    child: Text(
                      '✨',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const Positioned(
                    right: 4,
                    top: 8,
                    child: Text(
                      '✨',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28)
          ],
        ),
      ),
    );
  }
}
