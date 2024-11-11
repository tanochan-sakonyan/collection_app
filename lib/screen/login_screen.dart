import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_svg/svg.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF06C755),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () async {
            try {
              // LINEログイン処理
              final result = await LineSDK.instance.login();
              final userProfile = result.userProfile;
              final displayName = userProfile?.displayName ?? 'No Name';
              final userId = userProfile?.userId ?? 'No ID';

              // ログイン成功時の処理
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ログイン成功'),
                  content: Text('ようこそ、$displayName さん！\nユーザーID: $userId'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } on PlatformException catch (e) {
              // エラーハンドリング
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ログイン失敗'),
                  content: Text('エラーコード: ${e.code}\nメッセージ: ${e.message}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/line-login.svg',
              ),
              const SizedBox(width: 8),
              const Text(
                'LINEでログイン',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
