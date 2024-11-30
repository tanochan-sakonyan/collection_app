import 'package:flutter/material.dart';
import 'package:mr_collection/components/dialog/paypay_dialog.dart';
import 'package:mr_collection/data/mock/mock_user.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      child: Container(
        width: 310,
        height: 252,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text(
                  "どちらの催促LINEを",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  "送信しますか？",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 40,
                  width: 272,
                  child: ElevatedButton(
                    onPressed: () {
                      if (mockUser.paypayUrl == null) {
                        showDialog(
                          context: context,
                          builder: (context) => PayPayDialog(),
                        );
                      } else {
                        // TODO LINEでメッセージを送信
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F2F2),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'PayPayリンクあり',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 40,
                  width: 272,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO LINEでメッセージを送信
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD7D7D7),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'PayPayリンクなし',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showConfirmationPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const ConfirmationDialog();
    },
  );
}
