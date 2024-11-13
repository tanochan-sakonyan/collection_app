import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: Container(
        width: 296,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 44.0, bottom: 50.0),
              child: Column(
                children: [
                  Text(
                    'ログアウトしますか？',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black),
            Stack(
              children: [
                Container(
                    height: 80,
                    alignment: Alignment.center,
                    child:
                        const VerticalDivider(width: 1, color: Colors.black)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: _signOut,
                      child: Container(
                        height: 80,
                        alignment: Alignment.center,
                        child: const Text(
                          'はい',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 80,
                        alignment: Alignment.center,
                        child: const Text(
                          'いいえ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final _lineSdk = LineSDK.instance;
Future<void> _signOut() async {
  await _lineSdk.logout();
}
