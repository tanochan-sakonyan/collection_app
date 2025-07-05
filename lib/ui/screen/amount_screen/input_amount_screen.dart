import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' show FontFeature;
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/screen/amount_screen/split_amount_screen.dart';

class InputAmountScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String eventName;
  final List<Member> members;

  const InputAmountScreen(
      {super.key,
      required this.eventId,
      required this.eventName,
      required this.members});

  @override
  InputAmountScreenState createState() => InputAmountScreenState();
}

class InputAmountScreenState extends ConsumerState<InputAmountScreen> {
  bool _isEditing = false;

  late TextEditingController _controller;
  late FocusNode _focusNode;

  int _amount = 10000;

  final _numberStyle = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatWithCommas(int value) {
    final digits = value.toString();

    StringBuffer buf = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      buf.write(digits[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buf.write(',');
      }
    }

    return buf.toString().split('').reversed.join('');
  }

  TextInputFormatter _buildAmountFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text;
      if (text.isEmpty) {
        return newValue;
      }

      String digitsOnly = text.replaceAll(',', '');
      final int? value = int.tryParse(digitsOnly);
      if (value == null) {
        return oldValue;
      }

      if (value > 9999999) {
        return oldValue;
      }

      String newText = _formatWithCommas(value);

      int oldSelectionIndex = newValue.selection.end;
      int nonDigitCountBeforeCursor =
          text.substring(0, oldSelectionIndex).replaceAll(',', '').length;

      int newCursorIndex = 0;
      int digitCount = 0;
      for (int i = 0;
          i < newText.length && digitCount < nonDigitCountBeforeCursor;
          i++) {
        if (newText[i] != ',') {
          digitCount++;
        }
        newCursorIndex++;
      }
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorIndex),
      );
    });
  }

  void _finishEditing() {
    String text = _controller.text.replaceAll(',', '');
    if (text.isEmpty) {
      _amount = 0;
    } else {
      _amount = int.tryParse(text) ?? 0;
    }

    setState(() {
      _isEditing = false;
    });
    _focusNode.unfocus();
  }

  Future<void> _inputTotalMoney(
    String userId,
    String eventId,
    int totalMoney,
  ) async {
    try {
      debugPrint("_inputTotalMoney関数が呼ばれました。金額： $totalMoney");
      await ref.read(userProvider.notifier).inputTotalMoney(
            userId,
            eventId,
            totalMoney,
          );
    } catch (e) {
      debugPrint('Error inputting total money: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userProvider)!.userId;
    final yenStyle = _numberStyle.copyWith(fontSize: 36);
    Widget amountDisplay;
    if (_isEditing) {
      amountDisplay = IntrinsicWidth(
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionColor: Colors.black26,
              selectionHandleColor: Colors.black,
            ),
          ),
          child: TextField(
            focusNode: _focusNode,
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: _numberStyle,
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              suffixText: S.of(context)!.currencyUnit ?? "USD",
              suffixStyle: yenStyle,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [_buildAmountFormatter()],
            onSubmitted: (_) => _finishEditing(),
          ),
        ),
      );
    } else {
      String formatted = _formatWithCommas(_amount);
      amountDisplay = Text.rich(
        TextSpan(
          text: formatted,
          style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black),
          children: [
            TextSpan(
                text: S.of(context)!.currencyUnit ?? "USD",
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

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
                S.of(context)!.back ?? "Back",
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
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              widget.eventName,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              S.of(context)!.enterTotalAmount ?? "Enter total amount",
              style: GoogleFonts.notoSansJp(
                  fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (!_isEditing) {
                  setState(() {
                    _isEditing = true;

                    _controller.text = _formatWithCommas(_amount);
                  });
                  Future.delayed(Duration.zero, () {
                    _focusNode.requestFocus();
                  });
                }
              },
              child: amountDisplay,
            ),
            const SizedBox(height: 100),
            SizedBox(
              width: 108,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF75DCC6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_isEditing) _finishEditing();
                  _inputTotalMoney(
                    userId,
                    widget.eventId,
                    _amount,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SplitAmountScreen(
                        eventId: widget.eventId,
                        eventName: widget.eventName,
                        members: widget.members,
                        amount: _amount,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context)!.next ?? "Next",
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
