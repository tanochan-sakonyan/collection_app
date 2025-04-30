import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmountInputScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  const AmountInputScreen(
      {super.key, required this.eventId, required this.eventName});

  @override
  State<AmountInputScreen> createState() => _AmountInputScreenState();
}

class _AmountInputScreenState extends State<AmountInputScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 数字を3桁区切りの文字列にフォーマット
  String get _formattedAmount {
    final text = _controller.text.replaceAll(',', '');
    if (text.isEmpty) return '0';
    final value = int.tryParse(text) ?? 0;
    // simple number format
    return value
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }

  @override
  Widget build(BuildContext context) {
    final kbHeight = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: Column(
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
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 40,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixText: '円',
                suffixStyle: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            width: 108,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                //次の画面に遷移
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                '次へ',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: kbHeight,
          ),
        ],
      ),
    );
  }
}
