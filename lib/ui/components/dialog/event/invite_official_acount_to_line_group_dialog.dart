import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

//公式LINEが認証された後のダイアログ
class InviteOfficialAcountToLineGroupDialog extends StatelessWidget {
  const InviteOfficialAcountToLineGroupDialog({super.key});

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
    return
      Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
        padding: const EdgeInsets.only(
          top: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              "LINE公式アカウントを、\n集金対象のLINEグループに招待しよう",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "「集金くん」が参加しているLINEグループのみ、\nメンバーを取得することができます。",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF6A6A6A),
              ),
            ),
            const SizedBox(height: 36),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    ClipOval(
                     child: Image.asset(
                       'assets/icons/icon.png',
                       width: 48,
                       height: 48,
                       fit: BoxFit.cover,
                     ),
                    ),
                    Text(
                      "集金くん",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                SvgPicture.asset(
                  'assets/icons/ic_arrow_right.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 18),
                Column(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ic_default_group.svg',
                      width: 44,
                      height: 44,
                    ),
                    Text(
                      "グループ",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
