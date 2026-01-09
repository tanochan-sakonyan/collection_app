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
import 'package:mr_collection/ui/components/collection_rate_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  statusIcon: _statusIcon,
                  showMembers: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'カードをタップすると画像を作成します',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            SummaryCardPreview(
              event: widget.event,
              totalMoney: totalMoney,
              statusIcon: _statusIcon,
              showMembers: false,
            ),
          ],
        ),
      ),
    );
  }

  // カードの画像化を試す。
  Future<void> _handleCardTap() async {
    try {
      final file = await _captureCardImage();
      if (!mounted) return;
      final origin = _buildShareOrigin(context);
      await Share.shareXFiles(
        [file],
        sharePositionOrigin: origin,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像の作成に失敗しました')),
      );
      debugPrint('カード画像化エラー: $error');
    }
  }

  // 共有シートの基準位置を作る。
  Rect _buildShareOrigin(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width.clamp(1.0, size.width);
    final height = size.height.clamp(1.0, size.height);
    return Rect.fromLTWH(0, 0, width, height);
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

  // ステータスのアイコンを返す。
  Widget _statusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Icon(Icons.check, color: Color(0xFF35C759));
      case PaymentStatus.paypay:
        return Image.asset(
          'assets/icons/ic_paypay.png',
          width: 20,
          height: 20,
        );
      case PaymentStatus.unpaid:
        return const Icon(Icons.close, color: Colors.red);
      case PaymentStatus.absence:
        return const Icon(Icons.remove, color: Color(0xFFC0C0C0));
    }
  }
}

class SummaryCardPreview extends StatelessWidget {
  final Event event;
  final int totalMoney;
  final Widget Function(PaymentStatus status) statusIcon;
  final bool showMembers;

  const SummaryCardPreview({
    super.key,
    required this.event,
    required this.totalMoney,
    required this.statusIcon,
    required this.showMembers,
  });

  @override
  // サマリーカードのプレビューを描画する。
  Widget build(BuildContext context) {
    final collectedCount = event.members
        .where((member) =>
            member.status == PaymentStatus.paid ||
            member.status == PaymentStatus.paypay)
        .length;
    final totalCount = event.members.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                    const SizedBox(height: 20),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'メンバー数：'),
                          TextSpan(
                            text: '${event.members.length}人',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: '合計金額：'),
                          TextSpan(
                            text: '$totalMoney円',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '回収率 $collectedCount/$totalCount',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CollectionRateChart(
                    collectedCount: collectedCount,
                    totalCount: totalCount,
                    size: 72,
                  ),
                ],
              ),
              const SizedBox(width: 12),
            ],
          ),
          if (showMembers) ...[
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
                    const SizedBox(width: 8),
                    Text(
                      member.memberMoney != null
                          ? '${member.memberMoney}円'
                          : '—-- 円',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    statusIcon(member.status),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
