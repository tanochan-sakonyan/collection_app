import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// 端数切り上げ金額が300円以上の場合に広告削除を提案するダイアログ。
/// true: 広告削除へ進む、false: 広告を見て金額確定
class SuggestRemoveAdsDialog extends StatelessWidget {
  final int changeAmount;

  const SuggestRemoveAdsDialog({
    super.key,
    required this.changeAmount,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat('#,###').format(changeAmount);
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        width: 360,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF37F3BE), Color(0xFF6BE8F0)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // タイトル
              Text(
                '広告を0にしませんか？',
                style: GoogleFonts.notoSansJp(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // サブタイトル
              Text(
                '300円で、広告を永久に削除できます！',
                style: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // 説明文（金額部分を太字で表示）
              Text.rich(
                TextSpan(
                  style: GoogleFonts.notoSansJp(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  children: [
                    const TextSpan(text: '端数切り上げにより、'),
                    TextSpan(
                      text: '￥$formattedAmount',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const TextSpan(
                        text: '円お得になったので、そのうちの300円を使って広告を削除できます。'),
                    const TextSpan(
                      text: 'あなたの負担額は0円です！',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // 「広告を削除する」ボタン（メイン）
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    '広告を削除する',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 「広告を見て金額確定」ボタン（サブ）
              GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text(
                  '広告を見て金額確定',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
