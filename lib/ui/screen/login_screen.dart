import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final checkboxProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  get http => null;

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
                    final prefs = await SharedPreferences.getInstance();
                    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
                    debugPrint('isLoggedIn: $isLoggedIn');
                    final userId = prefs.getInt('userId');

                    if (isLoggedIn && userId != null) {
                      try {
                        await ref
                            .read(userProvider.notifier)
                            .fetchUserById(userId);

                        final user = ref.read(userProvider);
                        if (mounted && user != null) {
                          debugPrint('既存ユーザーでHomeScreenに遷移します。user: $user');
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  HomeScreen(title: '集金くん', user: user),
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint('ユーザー情報の取得に失敗しました。: $e');
                      }
                    } else {
                      try {
                        final result = await LineSDK.instance.login();
                        final accessToken = result.accessToken.value;
                        ref.read(accessTokenProvider.notifier).state =
                            accessToken;

                        final user = await ref
                            .read(userProvider.notifier)
                            .registerUser(accessToken);

                        if (user != null) {
                          prefs.setInt('userId', user.userId);
                          prefs.setBool('isLoggedIn', true);
                        } else {
                          debugPrint('ユーザー情報がnullです');
                        }

                        if (mounted && user != null) {
                          debugPrint(
                              'LoginScreenからHomeScreenに遷移します。user: $user');
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
                              content: Text(
                                  'エラーコード: ${e.code}\nメッセージ: ${e.message}'),
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
            ElevatedButton(
                onPressed: () async {
                  final credential = await SignInWithApple.getAppleIDCredential(
                    scopes: [
                      AppleIDAuthorizationScopes.email,
                      AppleIDAuthorizationScopes.fullName,
                    ],
                    webAuthenticationOptions: WebAuthenticationOptions(
                      clientId: 'com.tanotyan.syukinkun.service',
                      redirectUri: kIsWeb
                          ? Uri.parse('https://${Uri.base.host}/')
                          : Uri.parse(
                              'https://shukinkun-086ea89ed514.herokuapp.com/callbacks/sign_in_with_apple',
                            ),
                    ),
                    nonce: 'snrkANkbGRjnaLIwfIWEF9#(;)gerew',
                    state: 'gneigfoaie))82w#SknDewoi0{QW:be[0',
                  );

                  print(credential);

                  final signInWithAppleEndpoint = Uri(
                    scheme: 'https',
                    host: 'shukinkun-086ea89ed514.herokuapp.com',
                    path: '/sign_in_with_apple',
                    queryParameters: <String, String>{
                      'code': credential.authorizationCode,
                      if (credential.givenName != null)
                        'firstName': credential.givenName!,
                      if (credential.familyName != null)
                        'lastName': credential.familyName!,
                      'useBundleId':
                          !kIsWeb && (Platform.isIOS || Platform.isMacOS)
                              ? 'true'
                              : 'false',
                      if (credential.state != null) 'state': credential.state!,
                    },
                  );

                  final session = await http.Client().post(
                    signInWithAppleEndpoint,
                  );
                  debugPrint(session);
                },
                child: const Text('Appleでログイン')),
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
