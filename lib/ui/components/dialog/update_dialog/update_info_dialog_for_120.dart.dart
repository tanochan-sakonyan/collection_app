import 'package:flutter/material.dart';

class UpdateInfoDialogFor120 extends StatelessWidget {
  const UpdateInfoDialogFor120({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'アップデートのお知らせ🎉',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Icon(Icons.auto_awesome, size: 64, color: Colors.teal),
          const SizedBox(height: 12),
          const Column(
            children: [
              ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('チュートリアルの追加'),
              ),
              ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('スワイプでメンバー名編集'),
              ),
              ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('設定画面に目安箱を設置'),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'ご意見・ご要望は「目安箱」から\nいつでもお気軽にお寄せください📮',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
