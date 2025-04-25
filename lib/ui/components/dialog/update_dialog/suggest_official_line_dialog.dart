import 'package:flutter/material.dart';

class SuggestOfficialLineDialog extends StatelessWidget {
  const SuggestOfficialLineDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'LINE公式アカウントを追加して\n集金くんを便利にしませんか？',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            '現在、LINE公式アカウントの認証通過を目指して\n取り組んでいます！認証通過には友だち数も重要です。',
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: const Icon(Icons.add),
            label: const Text('友だち追加'),
            onPressed: () {
              // TODO: LINE 友だち追加リンクへ
            },
          ),
          const SizedBox(height: 16),
          const Column(
            children: [
              ListTile(
                leading: Icon(Icons.check, color: Colors.green),
                title: Text('LINEグループから自動メンバー追加'),
              ),
              ListTile(
                leading: Icon(Icons.check, color: Colors.green),
                title: Text('グループ内に自動メッセージ送信'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
