import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/generated/s.dart';

class PayPayLinkExplanationDialog extends StatelessWidget {
  const PayPayLinkExplanationDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
                  S.of(context)!.paypayLinkTitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context)!.paypayLinkDesc,
                style: GoogleFonts.notoSansJp(
                    fontSize: 12, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildQA(
                question: S.of(context)!.paypayLinkQ1,
                answer: S.of(context)!.paypayLinkA1,
                questionStyle: questionStyle,
                answerStyle: bodyStyle,
              ),
              const SizedBox(height: 16),
              _buildQA(
                question: S.of(context)!.paypayLinkQ2,
                answer: S.of(context)!.paypayLinkA2,
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
                      backgroundColor:
                          Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      S.of(context)!.close,
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
