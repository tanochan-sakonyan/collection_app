import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/screen/home_screen.dart';
import 'package:mr_collection/screen/privacy_policy_screen.dart';
import 'package:mr_collection/screen/terms_of_service_screen.dart';

final checkboxProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isChecked = ref.watch(checkboxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06C755),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: isChecked
                  ? () async {
                      try {
                        final result = await LineSDK.instance.login();
                        final accessToken = result.accessToken;
                        ref.read(accessTokenProvider.notifier).state =
                            accessToken.value;

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                const HomeScreen(title: '集金くん'),
                          ),
                        );
                      } on PlatformException catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('ログイン失敗'),
                            content:
                                Text('エラーコード: ${e.code}\nメッセージ: ${e.message}'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  : null,
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    ref.read(checkboxProvider.notifier).state = value!;
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TermsOfServiceScreen()),
                    );
                  },
                  child: const Text(
                    '利用規約',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
                const Text(' と '),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen()),
                    );
                  },
                  child: const Text(
                    'プライバシーポリシー',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
                const Text(' に同意します。'),
              ],
            ),
            const SizedBox(height: 100)
          ],
        ),
      ),
    );
  }
}
