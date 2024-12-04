import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/screen/home_screen.dart';
import 'package:mr_collection/ui/screen/privacy_policy_screen.dart';
import 'package:mr_collection/ui/screen/terms_of_service_screen.dart';

final checkboxProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    bool isChecked = ref.watch(checkboxProvider);
    debugPrint('isChecked: $isChecked');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            const Text("集金くん",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 100),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChecked
                      ? const Color(0xFF06C755)
                      : const Color(0xFFD7D7D7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () async {
                  if (isChecked) {
                    try {
                      final result = await LineSDK.instance.login();
                      final accessToken = result.accessToken.value;
                      ref.read(accessTokenProvider.notifier).state =
                          accessToken;

                      User? user;
                      while (user == null && mounted) {
                        await Future.delayed(const Duration(milliseconds: 100));
                        user = ref.read(userProvider);
                      }

                      if (mounted && user != null) {
                        debugPrint('LoginScreenからHomeScreenに遷移します。user: $user');
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen(title: '集金くん', user: user),
                          ),
                        );
                      }
                    } on PlatformException catch (e) {
                      if (mounted) {
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
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // const SizedBox(width: 12),
                    SvgPicture.asset(
                      'assets/icons/line-login.svg',
                    ),
                    const SizedBox(width: 40),
                    const Text(
                      'LINEでログイン',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
                  activeColor: Colors.black,
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
