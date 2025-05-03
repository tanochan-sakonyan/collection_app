import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class _SplitAmountScreenState extends State<SplitAmountScreen>
    with SingleTickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<bool> _locked;
  late TabController _tabController;
  final _numFmt = NumberFormat.decimalPattern();

  @override
  void initState() {
    super.initState();
    final evenShare = (widget.amount / widget.members.length).ceil();
    _controllers = widget.members
        .map((_) => TextEditingController(text: _numFmt.format(evenShare)))
        .toList();
    _focusNodes = List.generate(
      widget.members.length,
      (i) {
        final node = FocusNode();
        node.addListener(() {
          if (!node.hasFocus) {
            _handleSubmitted(i, _controllers[i].text);
          }
        });
        return node;
      },
    );
    _locked = List<bool>.filled(widget.members.length, false);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    _tabController.dispose();
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

    if (_tabController.index == 0) {
      final evenShare = (widget.amount / widget.members.length).ceil();
      for (final m in widget.members) {
        amountMap[m.memberId] = evenShare;
      }
    } else if (_tabController.index == 1) {
      for (var i = 0; i < widget.members.length; i++) {
        amountMap[widget.members[i].memberId] =
            int.tryParse(_controllers[i].text.replaceAll(',', '')) ?? 0;
      }
    }

    debugPrint('送信する金額マップ: $amountMap');
  }

  void _handleSubmitted(int index, String rawText) {
    if (_tabController.index != 1) _tabController.animateTo(1);

    int input = int.tryParse(rawText.replaceAll(',', '')) ?? 0;

    int lockedSum = 0;
    for (int i = 0; i < widget.members.length; i++) {
      if (_locked[i] && i != index) {
        lockedSum +=
            int.tryParse(_controllers[i].text.replaceAll(',', '')) ?? 0;
      }
    }

    int remaining = widget.amount - lockedSum;

    final bool wasTrimmed = input > remaining;
    if (wasTrimmed) {
      input = remaining;
    }

    setState(() {
      _controllers[index].text = _numFmt.format(input);
      _locked[index] = true;

      if (wasTrimmed) {
        for (int j = 0; j < widget.members.length; j++) {
          if (j != index && !_locked[j]) {
            _controllers[j].text = _numFmt.format(0);
          }
        }
      }

      _recalculateAmounts();
    });
  }

  void _toggleLock(int index) {
    setState(() {
      _locked[index] = !_locked[index];
      _recalculateAmounts();
    });
  }

  void _recalculateAmounts() {
    int lockedSum = 0;
    for (int i = 0; i < widget.members.length; i++) {
      if (_locked[i]) {
        lockedSum +=
            int.tryParse(_controllers[i].text.replaceAll(',', '')) ?? 0;
      }
    }

    if (lockedSum >= widget.amount) {
      setState(() {});
      return;
    }

    final adjustables = <int>[];
    for (int i = 0; i < widget.members.length; i++) {
      if (!_locked[i]) adjustables.add(i);
    }

    int remaining = widget.amount - lockedSum;

    if (adjustables.isEmpty) {
      for (int i = widget.members.length - 1; i >= 0; i--) {
        if (_locked[i]) {
          int val = int.tryParse(_controllers[i].text.replaceAll(',', '')) ?? 0;
          _controllers[i].text = _numFmt.format(val + remaining);
          break;
        }
      }
      setState(() {});
      return;
    }

    int share = (remaining / adjustables.length).ceil();

    for (int idx in adjustables) {
      _controllers[idx].text = _numFmt.format(share);
    }

    setState(() {});
  }

  TextInputFormatter _buildAmountFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text;
      if (text.isEmpty) return newValue;

      String digitsOnly = text.replaceAll(',', '');
      final int? value = int.tryParse(digitsOnly);
      if (value == null) return oldValue;
      if (value > 9990000) return oldValue;
      String newText = _numFmt.format(value);
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

    return Scaffold(
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
                  controller: _tabController,
                  indicatorPadding:
                      const EdgeInsets.symmetric(horizontal: -48, vertical: 2),
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
                  controller: _tabController,
                  children: [
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
                    ListView.builder(
                      padding: const EdgeInsets.only(left: 34, right: 20),
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
                                width: 140,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 28,
                                        child: TextField(
                                          controller: _controllers[i],
                                          focusNode: _focusNodes[i],
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
                                          onSubmitted: (v) =>
                                              _handleSubmitted(i, v),
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
                                    const SizedBox(width: 24),
                                    GestureDetector(
                                      onTap: () => _toggleLock(i),
                                      child: SvgPicture.asset(
                                        _locked[i]
                                            ? 'assets/icons/ic_rock_close.svg'
                                            : 'assets/icons/ic_rock_open.svg',
                                        width: 24,
                                        height: 24,
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
          ],
        ),
      ),
      bottomNavigationBar: MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 60, bottom: 30, right: 141, left: 141),
          child: SizedBox(
            width: 108,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF75DCC6),
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
        ),
      ),
    );
  }
}
