import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmountGuideDialog extends StatefulWidget {
  const AmountGuideDialog({super.key});

  @override
  State<AmountGuideDialog> createState() => _AmountGuideDialogState();
}

class _AmountGuideDialogState extends State<AmountGuideDialog> {
  final _pageCtl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final double cardW = math.min(340, w * 0.88);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_drop_up, size: 64, color: Color(0xFF75DCC6)),
            Container(
              width: cardW,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 16,
                    offset: Offset(0, 8),
                    color: Color(0x26000000),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 420, // 必要に応じて調整
                    child: PageView(
                      controller: _pageCtl,
                      onPageChanged: (i) => setState(() => _page = i),
                      children: const [
                        _SplitModePage(),
                        _AdjustModePage(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ----- インジケーター -----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _page
                              ? Colors.black
                              : const Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 88,
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF75DCC6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('とじる',
                          style: GoogleFonts.notoSansJp(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------- 以下はページごとのレイアウト ------------------ */

class _SplitModePage extends StatelessWidget {
  const _SplitModePage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('割り勘モード',
            style: GoogleFonts.notoSansJp(
                fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        // キラキラ
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('✨', style: TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 4),
        // ---- モックのタブ（固定） ----
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _MockPill(label: '割り勘', selected: true),
            SizedBox(width: 12),
            _MockPill(label: '金額の調整', selected: false),
          ],
        ),
        const SizedBox(height: 16),
        // ---- メンバー行 ----
        _MockRow(name: '田中さん', amount: '2,000'),
        _MockRow(name: '鈴木さん', amount: '2,000'),
        _MockRow(name: '進藤さん', amount: '2,000'),
        const SizedBox(height: 24),
        // ---- チェック説明 ----
        _CheckLine(text: '全員が同じ金額でのお支払い'),
      ],
    );
  }
}

class _AdjustModePage extends StatelessWidget {
  const _AdjustModePage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('金額の調整モード',
            style: GoogleFonts.notoSansJp(
                fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _MockPill(label: '割り勘', selected: false),
            SizedBox(width: 12),
            _MockPill(label: '金額の調整', selected: true),
          ],
        ),
        const SizedBox(height: 8),
        // キラキラ
        const Text('✨', style: TextStyle(fontSize: 24)),
        // --- 固定ラベル ---
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 56, top: 4),
            child: Text('＼固定／',
                style: GoogleFonts.notoSansJp(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.green)),
          ),
        ),
        // ---- メンバー行 ----
        _MockRow(name: '進藤部長', amount: '5,000', locked: true),
        _MockRow(name: '斎藤ちゃん', amount: '1,000', locked: false),
        _MockRow(name: '田中くん', amount: '1,000', locked: false),
        const SizedBox(height: 24),
        _CheckLine(text: 'ロック🔒で特定のメンバーの金額を固定！'),
        _CheckLine(text: '残りのメンバーで割り勘！'),
      ],
    );
  }
}

/* ---------------- モック用パーツ ---------------- */

class _MockPill extends StatelessWidget {
  const _MockPill({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 28,
      child: DecoratedBox(
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
    );
  }
}

class _MockRow extends StatelessWidget {
  const _MockRow(
      {required this.name, required this.amount, this.locked = false});

  final String name;
  final String amount;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          title: Text(name,
              style: GoogleFonts.notoSansJp(fontSize: 16, height: 1.4)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(amount,
                  style: GoogleFonts.notoSansJp(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              const Text('円'),
              if (locked)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.lock, size: 20),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF75DCC6),
            ),
            child: const Icon(Icons.check, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: GoogleFonts.notoSansJp(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
