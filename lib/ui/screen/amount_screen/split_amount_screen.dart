import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui' show FontFeature;

import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/ui/components/dialog/amount_guide_dialog.dart';

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 28,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF75DCC6) : Colors.white,
            borderRadius: BorderRadius.circular(48),
            boxShadow: selected
                ? []
                : [
                    const BoxShadow(
                      blurRadius: 4,
                      offset: Offset(0, 2),
                      color: Color(0x1A000000),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(48),
              onTap: onTap,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
  late int _currentTab;

  @override
  void initState() {
    super.initState();
    final activeMembers =
        widget.members.where((m) => m.status != PaymentStatus.absence).toList();
    final evenShare = (widget.amount / activeMembers.length).ceil();
    _controllers = widget.members
        .map(
          (m) => TextEditingController(
            text: _numFmt.format(
                m.status == PaymentStatus.absence ? 0 : evenShare), // ★修正
          ),
        )
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
    _locked =
        widget.members.map((m) => m.status == PaymentStatus.absence).toList();
    _tabController = TabController(length: 2, vsync: this);
    _currentTab = 0;
    _tabController.addListener(() {
      if (_currentTab != _tabController.index && mounted) {
        setState(() => _currentTab = _tabController.index);
      }
    });
  }

  @override
  void _showGuideDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'guide',
      barrierColor: Colors.black38,
      pageBuilder: (_, __, ___) => AmountGuideDialog(
        onPageChanged: (index) {},
      ),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    );
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
      final activeMembers = widget.members
          .where((m) => m.status != PaymentStatus.absence)
          .toList();
      final evenShare = (widget.amount / activeMembers.length).ceil();
      for (final m in widget.members) {
        amountMap[m.memberId] =
            m.status == PaymentStatus.absence ? 0 : evenShare;
      }
    } else if (_tabController.index == 1) {
      for (var i = 0; i < widget.members.length; i++) {
        amountMap[widget.members[i].memberId] =
            widget.members[i].status == PaymentStatus.absence // ★修正
                ? 0
                : int.tryParse(_controllers[i].text.replaceAll(',', '')) ?? 0;
      }
    }

    debugPrint('送信する金額マップ: $amountMap');
  }

  void _handleSubmitted(int index, String rawText) {
    int input = int.tryParse(rawText.replaceAll(',', '')) ?? 0;
    int lockedSum = 0;
    for (int i = 0; i < widget.members.length; i++) {
      if (widget.members[i].status == PaymentStatus.absence) continue;
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
      if (widget.members[i].status == PaymentStatus.absence) continue;
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
      if (widget.members[i].status == PaymentStatus.absence) continue;
      if (!_locked[i]) adjustables.add(i);
    }

    int remaining = widget.amount - lockedSum;

    if (adjustables.isEmpty) {
      for (int i = widget.members.length - 1; i >= 0; i--) {
        if (widget.members[i].status == PaymentStatus.absence) continue;
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
    final activeCount =
        widget.members.where((m) => m.status != PaymentStatus.absence).length;
    final evenShare =
        activeCount == 0 ? 0 : (widget.amount / activeCount).ceil();

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
              ),
              Text(
                '戻る',
                style: GoogleFonts.notoSansJp(
                    color: const Color(0xFF76DCC6),
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text(
              widget.eventName,
              style: GoogleFonts.notoSansJp(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 10),
                Text(
                  '個別金額の設定',
                  style: GoogleFonts.notoSansJp(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                IconButton(
                    onPressed: () => _showGuideDialog(),
                    icon: SvgPicture.asset(
                      'assets/icons/question_circle.svg',
                      width: 24,
                      height: 24,
                    )),
                const Spacer(flex: 8),
              ],
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _TabPill(
                    label: '割り勘',
                    selected: _currentTab == 0,
                    onTap: () {
                      if (_currentTab == 0) return;
                      setState(() => _currentTab = 0);
                      _tabController.animateTo(0);
                    },
                  ),
                  const SizedBox(width: 12),
                  _TabPill(
                    label: '金額の調整',
                    selected: _currentTab == 1,
                    onTap: () {
                      if (_currentTab == 1) return;
                      setState(() => _currentTab = 1);
                      _tabController.animateTo(1);
                    },
                  ),
                ],
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
                    // 割り勘
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: m.status == PaymentStatus.absence
                                            ? const Color(0xFFC0C0C0)
                                            : Colors.black,
                                      )),
                              trailing: IntrinsicWidth(
                                child: m.status == PaymentStatus.absence
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "欠席",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      const Color(0xFFC0C0C0),
                                                ),
                                          ),
                                          const SizedBox(
                                            width: 24,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Text(
                                            _numFmt.format(evenShare),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w500),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '円',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
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
                    // 金額の調整
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: m.status == PaymentStatus.absence
                                            ? const Color(0xFFC0C0C0)
                                            : Colors.black,
                                      )),
                              trailing: SizedBox(
                                width: 140,
                                child: m.status == PaymentStatus.absence
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "欠席",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      const Color(0xFFC0C0C0),
                                                ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 28,
                                              child: TextField(
                                                controller: _controllers[i],
                                                focusNode: _focusNodes[i],
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.right,
                                                inputFormatters: [
                                                  _buildAmountFormatter()
                                                ],
                                                decoration: InputDecoration(
                                                  isCollapsed: true,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFC6C6C8)),
                                                  ),
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      fontSize: 16,
                                                      fontWeight: _locked[i]
                                                          ? FontWeight.w700
                                                          : FontWeight
                                                              .w400, // ★変更
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
                                                  ? 'assets/icons/ic_lock_close.svg'
                                                  : 'assets/icons/ic_lock_open.svg',
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
              const EdgeInsets.only(top: 30, bottom: 60, right: 141, left: 141),
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
