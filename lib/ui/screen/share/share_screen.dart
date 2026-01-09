import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/generated/s.dart';

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
                colorFilter: ColorFilter.mode(
                  Theme.of(context).primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              Text(
                S.of(context)!.back,
                style: GoogleFonts.notoSansJp(
                  color: Theme.of(context).primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '集金状況の共有',
              style: GoogleFonts.notoSansJp(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
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
            Text(
              'メンバー詳細',
              style: GoogleFonts.notoSansJp(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: event.members.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final member = event.members[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      member.memberName.isNotEmpty
                          ? member.memberName
                          : S.of(context)!.member,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      _statusLabel(member.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _statusColor(member.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Text(
                      member.memberMoney != null
                          ? '${member.memberMoney}円'
                          : '—',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ステータスの文言を返す。
  String _statusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return '支払い済み';
      case PaymentStatus.paypay:
        return '支払い済み';
      case PaymentStatus.unpaid:
        return '未払い';
      case PaymentStatus.absence:
        return '欠席';
    }
  }

  // ステータスの色を返す。
  Color _statusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Color(0xFF35C759);
      case PaymentStatus.paypay:
        return const Color(0xFF35C759);
      case PaymentStatus.unpaid:
        return const Color(0xFFE67E22);
      case PaymentStatus.absence:
        return Colors.grey;
    }
  }
}
