import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AmountInputScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  const AmountInputScreen(
      {super.key, required this.eventId, required this.eventName});

  @override
  AmountInputScreenState createState() => AmountInputScreenState();
}

class AmountInputScreenState extends State<AmountInputScreen> {
  bool _isEditing = false;

  late TextEditingController _controller;
  late FocusNode _focusNode;

  int _amount = 10000;

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

      if (value > 9990000) {
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

  @override
  Widget build(BuildContext context) {
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
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              suffixText: '円',
              suffixStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
          children: const [
            TextSpan(
                text: ' 円',
                style: TextStyle(
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
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 92),
            Text(
              widget.eventName,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '合計金額の入力',
              style: GoogleFonts.notoSansJp(
                  fontSize: 24, fontWeight: FontWeight.w500),
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
            const SizedBox(height: 150),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                if (_isEditing) {
                  _finishEditing();
                }
              },
              child: const Text(
                '次へ',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
