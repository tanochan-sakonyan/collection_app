import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:url_launcher/url_launcher.dart';

class InviteOfficialAccountToLineGroupScreen extends ConsumerStatefulWidget {
  const InviteOfficialAccountToLineGroupScreen({super.key});
  @override
  ConsumerState<InviteOfficialAccountToLineGroupScreen> createState() =>
      CheckSelectedLineGroupScreenState();
}

class CheckSelectedLineGroupScreenState
    extends ConsumerState<InviteOfficialAccountToLineGroupScreen> {

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/icons/ic_back.svg',
                width: 44,
                height: 44,
              ),
              Text(
                '戻る',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF76DCC6),
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "LINE公式アカウントを\n集金対象のグループに招待しよう",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF06C755),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(
            "「集金くん」が参加しているLINEグループのみ、\nメンバーを取得することができます。",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6A6A6A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/ic_number_one.svg',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 12),
              Text(
                "LINE公式アカウントを追加",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              )
            ]
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 36),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/ic_number_two.svg',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 12),
                Text(
                  "LINE公式アカウントを\n集金対象のグループに招待",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                )
              ]
          ),
          const SizedBox(height: 24),
          Text(
            "「集金くん」がグループ内で\n宣伝メッセージ等を送ることはありません。",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6A6A6A),
            ),
            textAlign: TextAlign.center,
          ),
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
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/line_official_badge.png',
                        width: 12,
                        height: 12,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "集金くん",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                    ]
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
                      fontWeight: FontWeight.w700
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
