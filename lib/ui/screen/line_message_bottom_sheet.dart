import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/paypay_dialog.dart';

class LineMessageBottomSheet extends ConsumerStatefulWidget {
  final Event event;
  final List<Member> unpaidMembers;
  final String defaultPaypayUrl;

  const LineMessageBottomSheet.lineMessageBottomSheet({
    super.key,
    required this.event,
    required this.unpaidMembers,
    this.defaultPaypayUrl = "https://paypay.link/XXXXXX",
  });

  @override
  ConsumerState<LineMessageBottomSheet> createState() =>
      _UnpaidMessageBottomSheetState();
}

class _UnpaidMessageBottomSheetState
    extends ConsumerState<LineMessageBottomSheet> {
  late TextEditingController _controller;
  bool _includePaypayLink = false;
  String? _paypayUrl;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _generateDefaultMessage());
  }

  String _generateDefaultMessage() {
    final maxNameLength = widget.unpaidMembers
        .map((m) => m.memberName.length)
        .fold<int>(0, (prev, l) => l > prev ? l : prev);

    final namesAndMoney = widget.unpaidMembers.map((m) {
      final spaceCount = maxNameLength - m.memberName.length + 2;
      final spaces = ' ' * spaceCount;
      return '@${m.memberName}$spaces${m.memberMoney ?? ""}円';
    }).join('\n');

    return '下記の方は、まだ${widget.event.eventName}の支払いが完了していません。\n'
        '以下のPaypayリンクから\n'
        'お支払いをお願いいたします。\n'
        '$namesAndMoney\n';
  }

  Future<void> _onCheckChanged(BuildContext context, bool value) async {
    final user = ref.read(userProvider);
    String? paypayUrl = user?.paypayUrl;

    if (value && (paypayUrl == null || paypayUrl.isEmpty)) {
      await showDialog(
        context: context,
        builder: (context) => const PayPayDialog(),
      );
      paypayUrl = ref.read(userProvider)?.paypayUrl;
      if (paypayUrl == null || paypayUrl.isEmpty) return;
    }
    setState(() {
      _includePaypayLink = value;
      _paypayUrl = paypayUrl ?? widget.defaultPaypayUrl;
      final paypayLine = '\nPayPayリンク：$_paypayUrl';
      var currentText = _controller.text;

      if (_includePaypayLink) {
        if (!currentText.contains('PayPayリンク：')) {
          if (!currentText.endsWith('\n')) currentText += '\n';
          currentText += paypayLine.trim();
        }
      } else {
        final paypayLineReg = RegExp(r'\n?PayPayリンク：.*');
        currentText = currentText.replaceAll(paypayLineReg, '');
        currentText = currentText.replaceFirst(RegExp(r'\n+$'), '\n');
      }

      _controller.text = currentText;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: mq.viewInsets.bottom + 12,
          top: 16,
        ),
        child: Column(
          children: [
            Text("催促メッセージの送信",
                style: GoogleFonts.notoSansJp(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color(0xFF179394), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      style: GoogleFonts.notoSansJp(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _onCheckChanged(context, !_includePaypayLink),
                  child: SvgPicture.asset(
                    _includePaypayLink
                        ? 'assets/icons/ic_check_circle_teal.svg'
                        : 'assets/icons/ic_check_circle_off.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 4),
                Text("PayPayリンクの送付",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 108,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 次のポップアップに遷移
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF75DCC6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("次へ",
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
