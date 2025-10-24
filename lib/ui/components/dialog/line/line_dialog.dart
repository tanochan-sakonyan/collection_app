import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// TODO リリース初期段階ではLINEログイン必須のため、このポップアップは使わない
class LineDialog extends StatelessWidget {
  const LineDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          color: const Color(0xFFF2F2F2),
          height: 160,
          width: 296,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                "LINE公式アカウントを該当\nグループに招待して下さい",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: IconButton(
                      icon: SvgPicture.asset("assets/icons/line.svg"),
                      color: const Color(0xFF06C755),
                      iconSize: 64,
                      onPressed: () {
                        // TODO
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
