import 'package:flutter/material.dart';
import 'package:mr_collection/ui/screen/home_screen.dart';

class MemberEmptyErrorDialog extends StatelessWidget {
  const MemberEmptyErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'エラー',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'イベントにメンバーを一人以上追加してください。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 140,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'OK',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
