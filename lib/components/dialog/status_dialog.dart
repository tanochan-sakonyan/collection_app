import 'package:flutter/material.dart';

class StatusDialog extends StatelessWidget {
  final String member;

  const StatusDialog({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // メンバー名表示
            Text(
              '$memberは',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            // 支払い済みボタン
            _buildStatusButton(
              context,
              label: '支払い済み',
              icon: Icons.check,
              iconColor: Colors.green,
            ),
            const SizedBox(height: 10),
            // 未払いボタン
            _buildStatusButton(
              context,
              label: '未払い',
              icon: Icons.close,
              iconColor: Colors.red,
            ),
            const SizedBox(height: 10),
            // 欠席ボタン
            _buildStatusButton(
              context,
              label: '欠席',
              icon: Icons.remove,
              iconColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color iconColor}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
            Icon(icon, color: iconColor),
          ],
        ),
      ),
    );
  }
}
