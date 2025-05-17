import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AmountGuideDialog extends StatefulWidget {
  const AmountGuideDialog({
    super.key,
    required this.onPageChanged,
  });
  final void Function(int) onPageChanged;

  @override
  State<AmountGuideDialog> createState() => _AmountGuideDialogState();
}

class _AmountGuideDialogState extends State<AmountGuideDialog> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final double cardW = math.min(320, w * 0.90);
    final double cardH = math.min(392, h * 0.90);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: cardW,
              height: cardH,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    offset: Offset(0, 8),
                    color: Color(0x26000000),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 330,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: widget.onPageChanged,
                      children: const [
                        _SplitModePage(),
                        _AdjustModePage(),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: 2,
                      effect: const WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 8,
                        activeDotColor: Colors.black,
                        dotColor: Color(0xFFA7A7A7),
                      ),
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

class _SplitModePage extends StatelessWidget {
  const _SplitModePage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('割り勘モード',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MockPill(label: '割り勘', selected: true),
            SizedBox(width: 12),
            _MockPill(label: '金額の調整', selected: false),
          ],
        ),
        const SizedBox(height: 16),
        const _MockRow(
            name: '田中さん', amount: '2,000', isLockExist: false, isLocked: false),
        const _MockRow(
            name: '鈴木さん', amount: '2,000', isLockExist: false, isLocked: false),
        const _MockRow(
            name: '進藤さん', amount: '2,000', isLockExist: false, isLocked: false),
        const SizedBox(height: 24),
        const _CheckLine(text: '全員が同じ金額でのお支払い'),
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MockPill(label: '割り勘', selected: false),
            SizedBox(width: 12),
            _MockPill(label: '金額の調整', selected: true),
          ],
        ),
        const SizedBox(height: 16),
        const _MockRow(
            name: '進藤部長', amount: '5,000', isLockExist: true, isLocked: true),
        const _MockRow(
            name: '斎藤ちゃん', amount: '1,000', isLockExist: true, isLocked: false),
        const _MockRow(
            name: '田中くん', amount: '1,000', isLockExist: true, isLocked: false),
        const SizedBox(height: 24),
        const _CheckLine(text: 'ロック🔒で特定のメンバーの金額を固定！'),
        const _CheckLine(text: '残りのメンバーで割り勘！'),
      ],
    );
  }
}

class _MockPill extends StatelessWidget {
  const _MockPill({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 127,
      height: 25,
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
      {required this.name,
      required this.amount,
      required this.isLockExist,
      required this.isLocked});

  final String name;
  final String amount;
  final bool isLockExist;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          SizedBox(
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                Text(name, style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                Text(amount, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 4),
                Text('円', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFE8E8E8),
          ),
        ],
      ),
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
