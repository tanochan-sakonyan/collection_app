import 'package:flutter/material.dart';
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
    final evenShare = widget.amount ~/ widget.members.length;
    _controllers = widget.members
        .map((_) => TextEditingController(text: evenShare.toString()))
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

  @override
  Widget build(BuildContext context) {
    final evenShare = (widget.amount / widget.members.length).ceil();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                widget.eventName,
                style: GoogleFonts.notoSansJp(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '合計金額の入力',
                style: GoogleFonts.notoSansJp(
                    fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black45,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tabs: const [
                    Tab(text: '割り勘'),
                    Tab(text: '金額の調整'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: TabBarView(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: widget.members.length,
                        itemBuilder: (context, i) {
                          final m = widget.members[i];
                          return ListTile(
                            title: Text(m.memberName,
                                style: GoogleFonts.inter(fontSize: 16)),
                            trailing: Text(
                              '${_numFmt.format(evenShare)} 円',
                              style: GoogleFonts.notoSansJp(fontSize: 16),
                            ),
                          );
                        },
                      ),
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: widget.members.length,
                        itemBuilder: (context, i) {
                          final m = widget.members[i];
                          return ListTile(
                            title: Text(m.memberName,
                                style: GoogleFonts.inter(fontSize: 16)),
                            trailing: SizedBox(
                              width: 110,
                              child: TextField(
                                controller: _controllers[i],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 8),
                                  border: OutlineInputBorder(),
                                  suffixText: '円',
                                ),
                                style: GoogleFonts.inter(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAEAEB2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _onConfirm,
              child: Text('確定',
                  style: GoogleFonts.notoSansJp(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
