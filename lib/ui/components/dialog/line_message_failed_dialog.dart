import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/services/analytics_service.dart';

class LineMessageFailedDialog extends StatelessWidget {
  const LineMessageFailedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // ダイアログ表示をログに記録
    AnalyticsService().logDialogOpen('line_message_failed_dialog');
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
      child: SizedBox(
        width: 320,
        height: 191,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '送信に失敗しました',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              'お手数ですが再度お試しください',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 40,
              width: 272,
              child: ElevatedButton(
                onPressed: () {
                  AnalyticsService().logButtonTap(
                    'close',
                    screen: 'line_message_failed_dialog'
                  );
                  AnalyticsService().logDialogClose(
                    'line_message_failed_dialog',
                    'close'
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5C5C5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '閉じる',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
