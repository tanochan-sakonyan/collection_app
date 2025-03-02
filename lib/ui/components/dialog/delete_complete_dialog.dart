import 'package:flutter/material.dart';

class DeleteCompleteDialog extends StatelessWidget {
  const DeleteCompleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: 216,
        width: 320,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '削除が完了しました',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 40,
              width: 272,
              child: ElevatedButton(
                onPressed: () {
                  // LoginScreenに遷移
                  // isLoggedInをfalseにする
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2F2F2),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
