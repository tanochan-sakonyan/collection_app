import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

//公式LINEが認証された後のダイアログ
class SuggestOfficialLineDialogAfter extends StatelessWidget {
  const SuggestOfficialLineDialogAfter({super.key});

  Future<void> _launchLine() async {
    final uri = Uri.parse('https://lin.ee/cLwUgQtP');
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint('LINE を起動できませんでした');
    }
  }

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
            'おかげさまで、LINE公式アカウントが認証されました！\nLINEと連携した機能を7月に実装予定です！',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF6A6A6A),
                ),
          ),
          const SizedBox(height: 24),
          IconButton(
              onPressed: () {
                _launchLine();
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: SvgPicture.asset(
                'assets/icons/suggest_official_line.svg',
                width: 180,
                height: 56,
              )),
          const SizedBox(height: 24),
          Text(
            "次回アップデート(2.0.0)からできること",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 20),
                  SvgPicture.asset(
                    'assets/icons/ic_check_badge_green.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LINEグループからメンバーを一括追加',
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
                  const SizedBox(width: 20),
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
