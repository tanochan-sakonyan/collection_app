import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuggestOfficialLineDialog extends StatelessWidget {
  const SuggestOfficialLineDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'LINE公式アカウントを追加して\n集金くんを便利にしませんか？',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '現在、LINE公式アカウントの認証通過を目指して\n取り組んでいます！認証通過には友だち数も重要です。',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF6A6A6A),
                ),
          ),
          const SizedBox(height: 24),
          IconButton(
              onPressed: () {},
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: SvgPicture.asset(
                'assets/icons/suggest_official_line.svg',
                width: 180,
                height: 56,
              )),
          const SizedBox(height: 24),
          Text(
            "アカウントが認証されたらできること",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 30),
                  SvgPicture.asset(
                    'assets/icons/ic_check_badge_green.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LINEグループから自動メンバー追加',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 30),
                  SvgPicture.asset(
                    'assets/icons/ic_check_badge_green.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'グループ内に自動メッセージ送信',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
