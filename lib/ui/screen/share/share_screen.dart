import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/data/model/freezed/event.dart';

class ShareScreen extends StatelessWidget {
  final Event event;

  const ShareScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final totalMoney = event.totalMoney ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '集金状況の共有',
          style:
              GoogleFonts.notoSansJp(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'イベント名: ${event.eventName}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'メンバー数: ${event.members.length}人',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '合計金額: $totalMoney円',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'イベントID: ${event.eventId}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            const Text('共有機能はこれから実装します'),
          ],
        ),
      ),
    );
  }
}
