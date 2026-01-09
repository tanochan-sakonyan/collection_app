import 'dart:io';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/ui/components/collection_rate_chart.dart';
import 'package:mr_collection/ui/components/dialog/paypay_dialog.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/provider/theme_color_provider.dart';
import 'package:mr_collection/theme/theme_color.dart';
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
  final GlobalKey _anonymousCardKey = GlobalKey();
  final GlobalKey _detailCardKey = GlobalKey();
  bool _includePayPayLink = false;

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
        centerTitle: true,
        leadingWidth: 88,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 4),
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
        title: Text(
          '集金状況の共有',
          style: GoogleFonts.notoSansJp(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final logoAssetPath = _logoAssetPath(ref.watch(themeColorProvider));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPayPayCheckbox(ref),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                // 匿名版カード
                const Row(
                  children: [
                    SizedBox(width: 16),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: '匿名カード ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: 'メンバーの名前は共有されません',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _handleCardTap(ref, _anonymousCardKey),
                  child: RepaintBoundary(
                    key: _anonymousCardKey,
                    child: SummaryCardPreview(
                      event: widget.event,
                      totalMoney: totalMoney,
                      statusIcon: _statusIcon,
                      logoAssetPath: logoAssetPath,
                      showMembers: false,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'カードをタップして共有',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    SizedBox(width: 20)
                  ],
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                // メンバー付きカード
                const Row(
                  children: [
                    SizedBox(width: 16),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: 'カード ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: 'メンバーの名前と集金状況も共有されます',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _handleCardTap(ref, _detailCardKey),
                  child: RepaintBoundary(
                    key: _detailCardKey,
                    child: SummaryCardPreview(
                      event: widget.event,
                      totalMoney: totalMoney,
                      statusIcon: _statusIcon,
                      logoAssetPath: logoAssetPath,
                      showMembers: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'カードをタップして共有',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    SizedBox(width: 20)
                  ],
                ),
                const SizedBox(
                  height: 100,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // テーマカラーに応じたロゴを返す。
  String _logoAssetPath(ThemeColorOption option) {
    switch (option.keyName) {
      case 'sakura':
        return 'assets/icons/logo_pink.svg';
      case 'ajisai':
        return 'assets/icons/logo_blue.svg';
      case 'ichou':
        return 'assets/icons/logo_yellow.svg';
      case 'default':
      default:
        return 'assets/icons/logo_default.svg';
    }
  }

  // PayPay共有チェックを描画する。
  Widget _buildPayPayCheckbox(WidgetRef ref) {
    return Row(
      children: [
        Checkbox(
          value: _includePayPayLink,
          onChanged: (value) {
            if (value == null) return;
            _handlePayPayToggle(ref, value);
          },
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).primaryColor;
            }
          }),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'PayPayリンクも一緒に共有する',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // PayPayリンク共有の状態を切り替える。
  Future<void> _handlePayPayToggle(WidgetRef ref, bool value) async {
    if (!value) {
      setState(() => _includePayPayLink = false);
      return;
    }

    final user = ref.read(userProvider);
    final paypayUrl = user?.paypayUrl;
    if (paypayUrl == null || paypayUrl.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => const PayPayDialog(),
      );
      final updated = ref.read(userProvider)?.paypayUrl;
      if (updated == null || updated.isEmpty) {
        if (!mounted) return;
        setState(() => _includePayPayLink = false);
        return;
      }
    }

    if (!mounted) return;
    setState(() => _includePayPayLink = true);
  }

  // カードの画像化を試す。
  Future<void> _handleCardTap(WidgetRef ref, GlobalKey cardKey) async {
    try {
      final file = await _captureCardImage(cardKey);
      if (!mounted) return;
      final shareText = _buildShareText(ref);
      final origin = _buildShareOrigin(context);
      await Share.shareXFiles(
        [file],
        text: shareText,
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

  // 共有テキストを作る。
  String? _buildShareText(WidgetRef ref) {
    if (!_includePayPayLink) return null;
    final paypayUrl = ref.read(userProvider)?.paypayUrl;
    if (paypayUrl == null || paypayUrl.isEmpty) return null;
    return 'お支払いをお願いいたします。PayPayリンク：$paypayUrl';
  }

  // 共有シートの基準位置を作る。
  Rect _buildShareOrigin(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width.clamp(1.0, size.width);
    final height = size.height.clamp(1.0, size.height);
    return Rect.fromLTWH(0, 0, width, height);
  }

  // カードを画像化してXFileにする。
  Future<XFile> _captureCardImage(GlobalKey cardKey) async {
    await WidgetsBinding.instance.endOfFrame;
    final boundaryContext = cardKey.currentContext;
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
  final String logoAssetPath;
  final bool showMembers;

  const SummaryCardPreview({
    super.key,
    required this.event,
    required this.totalMoney,
    required this.statusIcon,
    required this.logoAssetPath,
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
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.2,
                child: SvgPicture.asset(
                  logoAssetPath,
                  width: 120,
                  height: 120,
                ),
              ),
            ),
          ),
          Column(
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
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
                        '回収率 $collectedCount/$totalCount人',
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
                              : '— 円',
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
        ],
      ),
    );
  }
}
