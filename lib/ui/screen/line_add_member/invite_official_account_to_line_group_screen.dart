import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class CheckSelectedLineGroupScreen extends ConsumerStatefulWidget {
  const CheckSelectedLineGroupScreen({super.key});
  @override
  ConsumerState<CheckSelectedLineGroupScreen> createState() =>
      CheckSelectedLineGroupScreenState();
}

class CheckSelectedLineGroupScreenState
    extends ConsumerState<CheckSelectedLineGroupScreen> {

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
          const SizedBox(height: 32),
          Text(
            "「集金くん」が参加しているLINEグループのみ、\nメンバーを取得することができます。",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0x006A6A6A),
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
        ],
      ),
    );
  }
}
