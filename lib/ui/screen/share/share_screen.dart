import 'dart:io';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:path_provider/path_provider.dart';

class ShareScreen extends StatefulWidget {
  final Event event;

  const ShareScreen({
    super.key,
    required this.event,
  });

  @override
  // Share画面の状態を作成する。
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final GlobalKey _cardKey = GlobalKey();

  @override
  // Share画面を描画する。
  Widget build(BuildContext context) {
    final totalMoney = widget.event.totalMoney ?? 0;
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
      body: SingleChildScrollView(
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
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _handleCardTap,
              child: RepaintBoundary(
                key: _cardKey,
                child: SummaryCardPreview(
                  event: widget.event,
                  totalMoney: totalMoney,
                  statusLabel: _statusLabel,
                  statusColor: _statusColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'カードをタップすると画像を作成します',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // カードの画像化を試す。
  Future<void> _handleCardTap() async {
    try {
      await _captureCardImage();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像を作成しました')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像の作成に失敗しました')),
      );
      debugPrint('カード画像化エラー: $error');
    }
  }

  // カードを画像化してXFileにする。
  Future<XFile> _captureCardImage() async {
    await WidgetsBinding.instance.endOfFrame;
    final boundaryContext = _cardKey.currentContext;
    if (boundaryContext == null) {
      throw Exception('カードの描画が取得できませんでした');
    }
    final boundary =
        boundaryContext.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('RenderRepaintBoundaryが見つかりませんでした');
    }
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('PNG変換に失敗しました');
    }
    final bytes = byteData.buffer.asUint8List();
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/summary_card_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);
    return XFile(file.path);
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

class SummaryCardPreview extends StatelessWidget {
  final Event event;
  final int totalMoney;
  final String Function(PaymentStatus status) statusLabel;
  final Color Function(PaymentStatus status) statusColor;

  const SummaryCardPreview({
    super.key,
    required this.event,
    required this.totalMoney,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  // サマリーカードのプレビューを描画する。
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.eventName,
            style: GoogleFonts.notoSansJp(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'メンバー数: ${event.members.length}人',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '合計金額: $totalMoney円',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'イベントID: ${event.eventId}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            'メンバー詳細',
            style: GoogleFonts.notoSansJp(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final member in event.members)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      member.memberName.isNotEmpty
                          ? member.memberName
                          : S.of(context)!.member,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(
                    statusLabel(member.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor(member.status),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    member.memberMoney != null ? '${member.memberMoney}円' : '—',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
