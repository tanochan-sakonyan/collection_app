import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/login_error_dialog.dart';
import 'package:mr_collection/ui/screen/home_screen.dart';
import 'package:mr_collection/ui/screen/privacy_policy_screen.dart';
import 'package:mr_collection/ui/screen/terms_of_service_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

final checkboxProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isAppleButtonEnabled = true;
  @override
  Widget build(BuildContext context) {
    bool isChecked = ref.watch(checkboxProvider);

    Future<void> _updateCurrentLoginMedia(String media) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentLoginMedia', media);
      debugPrint('currentLoginMedia: $media');
    }

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
                    final isLineLoggedIn =
                        prefs.getBool('isLineLoggedIn') ?? false;
                    debugPrint('isLineLoggedIn: $isLineLoggedIn');
                    final userId = prefs.getString('lineUserId');

                    if (isLineLoggedIn && userId != null) {
                      try {
                        await ref
                            .read(userProvider.notifier)
                            .fetchUserById(userId);

                        final user = ref.read(userProvider);
                        if (mounted && user != null) {
                          debugPrint('既存LINEユーザーでHomeScreenに遷移します。user: $user');
                          _updateCurrentLoginMedia('line');
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(user: user),
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint('ユーザー情報の取得に失敗しました。: $e');
                      }
                    } else {
                      try {
                        final result = await LineSDK.instance
                            .login(option: LoginOption(false, 'aggressive'));
                        final accessToken = result.accessToken.value;
                        ref.read(accessTokenProvider.notifier).state =
                            accessToken;

                        final user = await ref
                            .read(userProvider.notifier)
                            .registerUser(accessToken);

                        if (user != null) {
                          prefs.setString('lineUserId', user.userId);
                          prefs.setBool('isLineLoggedIn', true);
                        } else {
                          debugPrint('ユーザー情報がnullです');
                        }

                        if (mounted && user != null) {
                          debugPrint(
                              'LoginScreenからHomeScreenに遷移します。user: $user');
                          _updateCurrentLoginMedia('line');
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(user: user),
                            ),
                          );
                        }
                      } on PlatformException catch (e) {
                        if (mounted) {
                          debugPrint("エラーが発生: $e");
                          showDialog(
                              context: context,
                              builder: (context) => const LoginErrorDialog());
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
            const SizedBox(height: 12),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChecked
                      ? const Color(0xFF000000)
                      : const Color(0xFFD7D7D7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onPressed: () async {
                  if (!_isAppleButtonEnabled) return;
                  setState(() {
                    _isAppleButtonEnabled = false;
                  });

                  try {
                    if (isChecked) {
                      final prefs = await SharedPreferences.getInstance();
                      final isAppleLoggedIn =
                          prefs.getBool('isAppleLoggedIn') ?? false;
                      debugPrint('isAppleLoggedIn: $isAppleLoggedIn');
                      final userId = prefs.getString('appleUserId');

                      if (isAppleLoggedIn && userId != null) {
                        try {
                          await ref
                              .read(userProvider.notifier)
                              .fetchUserById(userId);
                          final user = ref.read(userProvider);
                          if (mounted && user != null) {
                            _updateCurrentLoginMedia('apple');
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(user: user),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint('ユーザー情報の取得に失敗しました。: $e');
                        }
                      } else {
                        try {
                          final credential =
                              await SignInWithApple.getAppleIDCredential(
                            scopes: [
                              AppleIDAuthorizationScopes.email,
                              AppleIDAuthorizationScopes.fullName,
                            ],
                            webAuthenticationOptions: WebAuthenticationOptions(
                              clientId: 'com.tanotyan.syukinkun.service',
                              redirectUri: kIsWeb
                                  ? Uri.parse('https://${Uri.base.host}/')
                                  : Uri.parse(
                                      'https://shukinkun-49fb12fd2191.herokuapp.com/auth/apple/callback',
                                    ),
                            ),
                          );

                          debugPrint("Appleサインイン認証情報: $credential");

                          final url = Uri.https(
                              'shukinkun-49fb12fd2191.herokuapp.com',
                              '/auth/apple');

                          final response = await http.get(
                            url,
                            headers: {'Content-Type': 'application/json'},
                          );

                          if (response.statusCode == 200 ||
                              response.statusCode == 201) {
                            final user = await ref
                                .read(userProvider.notifier)
                                .registerUser(response.body);

                            if (user != null) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString('appleUserId', user.userId);
                              prefs.setBool('isAppleLoggedIn', true);

                              if (mounted) {
                                debugPrint(
                                    'Appleサインイン成功。HomeScreenへ遷移します。user: $user');
                                _updateCurrentLoginMedia('apple');
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomeScreen(user: user),
                                  ),
                                );
                              }
                            } else {
                              debugPrint('ユーザー情報がnullです');
                            }
                          } else {
                            debugPrint(
                                'Appleサインインエンドポイントエラー: ${response.statusCode}');
                            if (mounted) {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const LoginErrorDialog());
                            }
                          }
                        } on PlatformException catch (e) {
                          if (mounted) {
                            debugPrint("エラーが発生 :$e");
                            showDialog(
                                context: context,
                                builder: (context) => const LoginErrorDialog());
                          }
                        } catch (e) {
                          debugPrint('Appleサインイン中にエラーが発生: $e');
                          if (mounted) {
                            showDialog(
                                context: context,
                                builder: (context) => const LoginErrorDialog());
                          }
                        }
                      }
                    }
                  } finally {
                    await Future.delayed(const Duration(seconds: 2));
                    setState(() {
                      _isAppleButtonEnabled = true;
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/apple_logo.svg',
                      height: 24,
                    ),
                    const SizedBox(width: 40),
                    const Text(
                      'Appleでサインイン',
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
          ],
        ),
      ),
    );
  }
}
