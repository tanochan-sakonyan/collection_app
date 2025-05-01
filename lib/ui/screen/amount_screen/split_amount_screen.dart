import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui' show FontFeature;

import 'package:mr_collection/data/model/freezed/member.dart';

class SplitAmountScreen extends StatefulWidget {
  final String eventName;
  final int amount;
  final List<Member> members;

  const SplitAmountScreen({
    super.key,
    required this.eventName,
    required this.amount,
    required this.members,
  });

  @override
  State<SplitAmountScreen> createState() => _SplitAmountScreenState();
}

class _SplitAmountScreenState extends State<SplitAmountScreen> {
  late List<TextEditingController> _controllers;
  final _numFmt = NumberFormat.decimalPattern();

  @override
  void initState() {
    super.initState();
    final evenShare = (widget.amount / widget.members.length).ceil();
    _controllers = widget.members
        .map((_) => TextEditingController(text: _numFmt.format(evenShare)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  TextStyle get _numberStyle => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  TextStyle get _yenStyle => _numberStyle.copyWith(fontSize: 36);

  Future<void> _onConfirm() async {
    final Map<String, int> amountMap = {};
    for (var i = 0; i < widget.members.length; i++) {
      amountMap[widget.members[i].memberId] =
          int.tryParse(_controllers[i].text.replaceAll(',', '')) ?? 0;
    }
    debugPrint('金額マップ: $amountMap');
  }

  TextInputFormatter _buildAmountFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text;
      if (text.isEmpty) return newValue;

      // 既存カンマを除去して数値だけ取り出し
      String digitsOnly = text.replaceAll(',', '');
      final int? value = int.tryParse(digitsOnly);
      if (value == null) return oldValue;

      // 上限チェック（必要なら）
      if (value > 9990000) return oldValue;

      // カンマ付き文字列を作る
      String newText = _numFmt.format(value);

      // カーソル位置を維持するロジック
      int oldCursor = newValue.selection.end;
      int nonCommaBefore =
          text.substring(0, oldCursor).replaceAll(',', '').length;
      int cursor = 0, count = 0;
      for (int i = 0; i < newText.length && count < nonCommaBefore; i++) {
        if (newText[i] != ',') count++;
        cursor++;
      }

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursor),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final evenShare = (widget.amount / widget.members.length).ceil();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 44),
              Text(
                widget.eventName,
                style: GoogleFonts.notoSansJp(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '合計金額の入力',
                style: GoogleFonts.notoSansJp(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  text: _numFmt.format(widget.amount),
                  style: _numberStyle,
                  children: [
                    TextSpan(text: ' 円', style: _yenStyle),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 370,
                  height: 32,
                  child: TabBar(
                    indicatorPadding: const EdgeInsets.symmetric(
                        horizontal: -48, vertical: 2),
                    dividerColor: Colors.transparent,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      fontSize: 16,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Inter',
                      fontSize: 16,
                    ),
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 2,
                          offset: Offset(0, 2),
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    tabs: const [
                      Tab(text: '割り勘'),
                      Tab(text: '金額の調整'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: TabBarView(
                    children: [
                      // 割り勘タブ
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 44),
                        itemCount: widget.members.length,
                        itemBuilder: (context, i) {
                          final m = widget.members[i];
                          return Column(
                            children: [
                              ListTile(
                                minTileHeight: 44,
                                title: Text(m.memberName,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                trailing: IntrinsicWidth(
                                  child: Row(
                                    children: [
                                      Text(
                                        _numFmt.format(evenShare),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '円',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 1,
                                color: Color(0xFFE8E8E8),
                              ),
                            ],
                          );
                        },
                      ),
                      // 金額の調整タブ
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 44),
                        itemCount: widget.members.length,
                        itemBuilder: (context, i) {
                          final m = widget.members[i];
                          return Column(
                            children: [
                              ListTile(
                                minTileHeight: 44,
                                title: Text(m.memberName,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                trailing: SizedBox(
                                  width: 110,
                                  child: Row(
                                    children: [
                                      const Spacer(),
                                      SizedBox(
                                        height: 28,
                                        width: 68,
                                        child: Expanded(
                                          child: TextField(
                                            controller: _controllers[i],
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.right,
                                            inputFormatters: [
                                              _buildAmountFormatter()
                                            ],
                                            decoration: InputDecoration(
                                              isCollapsed: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: const BorderSide(
                                                    color: Color(0xFFC6C6C8)),
                                              ),
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '円',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 1,
                                color: Color(0xFFE8E8E8),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                width: 108,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAEAEB2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _onConfirm,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('確',
                          style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(width: 8),
                      Text('定',
                          style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
