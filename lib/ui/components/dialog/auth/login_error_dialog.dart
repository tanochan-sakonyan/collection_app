import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/services/analytics_service.dart';

class LoginErrorDialog extends StatelessWidget {
  const LoginErrorDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // ダイアログ表示をログに記録
    AnalyticsService().logDialogOpen('login_error_dialog');
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(23),
      ),
      child: Container(
        width: 320,
        height: 191,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'サインインに失敗しました',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'お手数ですが、再度お試しください',
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
                    screen: 'login_error_dialog'
                  );
                  AnalyticsService().logDialogClose(
                    'login_error_dialog',
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
