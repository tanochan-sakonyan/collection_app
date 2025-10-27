import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PayPayStatusExplanationDialog extends StatelessWidget {
  const PayPayStatusExplanationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.notoSansJp(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );

    final bodyStyle = GoogleFonts.notoSansJp(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF303030),
      height: 1.6,
    );

    final questionStyle = GoogleFonts.notoSansJp(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '「PayPayで支払い済み」とは？',
                  style: titleStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'PayPayで受け取った支払いを管理しやすくするためのステータスです。\n'
                '現金で受け取った場合と区別して記録できます。',
                style: GoogleFonts.notoSansJp(
                    fontSize: 12, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildQA(
                question: 'Q. PayPayで支払ったら、自動で反映されますか？',
                answer: 'A. いいえ。PayPayの仕組み上、自動反映はできません。\n'
                    'PayPayで受け取ったことを確認したら、手動で「PayPayで支払い済み」を選んでください。',
                questionStyle: questionStyle,
                answerStyle: bodyStyle,
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF76DCC6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      '閉じる',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQA({
    required String question,
    required String answer,
    required TextStyle questionStyle,
    required TextStyle answerStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: questionStyle),
        const SizedBox(height: 4),
        Text(answer, style: answerStyle),
      ],
    );
  }
}
