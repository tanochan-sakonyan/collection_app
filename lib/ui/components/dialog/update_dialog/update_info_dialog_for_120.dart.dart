import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UpdateInfoDialogFor120 extends StatelessWidget {
  const UpdateInfoDialogFor120({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        right: 16,
        left: 16,
      ),
      child: Column(
        children: [
          Text(
            'アップデートのお知らせ🎉',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ① 中心の丸アイコン
                ClipOval(
                  child: SvgPicture.asset(
                    'assets/icons/reverse_icon.svg',
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                  ),
                ),
                // ② 左下のキラキラ
                const Positioned(
                  left: 0,
                  bottom: 0,
                  child: Text(
                    '✨',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                // ③ 右上のキラキラ
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
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 30),
                  SvgPicture.asset(
                    'assets/icons/ic_check_circle_teal.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'チュートリアルの追加',
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
                    'assets/icons/ic_check_circle_teal.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'スワイプでメンバー名編集',
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
                    'assets/icons/ic_check_circle_teal.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '設定画面に目安箱を設置',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'ご意見・ご要望は「目安箱」からいつでも\nお気軽にお寄せください📮',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
