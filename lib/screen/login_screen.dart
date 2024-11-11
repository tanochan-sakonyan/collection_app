import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/screen/home_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              final accessToken = result.accessToken;

              ref.read(accessTokenProvider.notifier).state = accessToken.value;

              // ログイン成功時の処理
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const HomeScreen(title: '集金くん')),
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
