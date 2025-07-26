import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsPrivacyUpdateDialog extends StatelessWidget {
  const TermsPrivacyUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'プライバシーポリシーを\n一部変更しました',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansJp(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'コンテンツ利用に当たっては、\n本利用規約・プライバシーポリシー双方に\n同意したものとみなします。',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansJp(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF888888),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}