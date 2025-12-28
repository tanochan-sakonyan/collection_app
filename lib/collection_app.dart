import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/provider/theme_color_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mr_collection/ui/screen/home_screen.dart';
import 'package:mr_collection/ui/screen/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:upgrader/upgrader.dart';
import 'package:mr_collection/widgets/custom_upgrade_alert.dart';

class CollectionApp extends ConsumerStatefulWidget {
  const CollectionApp({super.key});

  @override
  ConsumerState<CollectionApp> createState() => _CollectionAppState();
}

class _CollectionAppState extends ConsumerState<CollectionApp> {
  // ここで言語を指定(デバッグ時のみ)
  // final _locale = const Locale('en');

  Future<Map<String, bool>> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLineLoggedIn = prefs.getBool('isLineLoggedIn') ?? false;
    bool isAppleLoggedIn = prefs.getBool('isAppleLoggedIn') ?? false;
    return {
      'isLineLoggedIn': isLineLoggedIn,
      'isAppleLoggedIn': isAppleLoggedIn,
    };
  }

  Future<String?> _getLineUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("lineUserId");
  }

  Future<String?> _getAppleUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("appleUserId");
  }

  Future<void> _updateCurrentLoginMedia(String media) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentLoginMedia', media);
    debugPrint('currentLoginMedia: $media');
  }

  Future<User?> _loadUser(WidgetRef ref, String userId) async {
    final stored = await LineSDK.instance.currentAccessToken;
    final lineAccessToken = stored?.value;

    if (lineAccessToken != null) {
      return ref
          .read(userProvider.notifier)
          .fetchLineUserById(userId, lineAccessToken);
    } else {
      debugPrint("エラー：アクセストークンがnullです。");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(themeColorProvider);
    final textTheme = Theme.of(context).textTheme.apply(
      fontFamily: 'Montserrat',
      fontFamilyFallback: ['Noto Sans JP'],
    );

    return MaterialApp(
        // locale: _locale, //デバッグ時のみ 本番環境ではこの行をコメントアウト
        title: '集金くん',
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        ],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: themeColor.color,
          ),
          brightness: Brightness.light,
          fontFamily: 'Montserrat',
          fontFamilyFallback: const ['Noto Sans JP'],
          textTheme: textTheme,
          primaryColor: themeColor.color,
          primaryTextTheme: textTheme,
          tabBarTheme: const TabBarThemeData(
            indicator: BoxDecoration(),
            indicatorColor: Colors.transparent,
            dividerColor: Colors.transparent,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Montserrat',
            ),
            contentTextStyle: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontFamily: 'Montserrat',
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.supportedLocales,
        home: CustomUpgradeAlert(
          upgrader: Upgrader(
            debugDisplayAlways: false,
            debugLogging: false,
          ),
          child: FutureBuilder<Map<String, bool>>(
            future: _checkLoginStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: themeColor.color,
                  child: Center(
                      child: SvgPicture.asset('assets/icons/reverse_icon.svg')),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
              } else {
                final data = snapshot.data ?? {};
                final isLineLoggedIn = data['isLineLoggedIn'] ?? false;
                final isAppleLoggedIn = data['isAppleLoggedIn'] ?? false;

                if (isLineLoggedIn) {
                  // LINEログインの場合の処理
                  return FutureBuilder<String?>(
                    future: _getLineUserId(),
                    builder: (context, userIdSnapshot) {
                      if (userIdSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                          color: themeColor.color,
                          child: Center(
                              child: SvgPicture.asset(
                                  'assets/icons/reverse_icon.svg')),
                        );
                      } else if (userIdSnapshot.hasError) {
                        return Center(
                            child: Text('エラーが発生しました: ${userIdSnapshot.error}'));
                      } else {
                        final userId = userIdSnapshot.data;
                        debugPrint('userId: $userId');
                        if (userId != null) {
                          return FutureBuilder<User?>(
                            future: _loadUser(ref, userId),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  color: themeColor.color,
                                  child: Center(
                                      child: SvgPicture.asset(
                                          'assets/icons/reverse_icon.svg')),
                                );
                              } else if (userSnapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'ユーザー取得エラー: ${userSnapshot.error}'));
                              } else {
                                final user = userSnapshot.data;
                                if (user != null) {
                                  _updateCurrentLoginMedia('line');
                                  return HomeScreen(user: user);
                                } else {
                                  return const LoginScreen();
                                }
                              }
                            },
                          );
                        } else {
                          debugPrint('userIdが存在しないため、LoginScreenに遷移します。');
                          return const LoginScreen();
                        }
                      }
                    },
                  );
                } else if (isAppleLoggedIn) {
                  // Appleログインの場合の処理
                  return FutureBuilder<String?>(
                    future: _getAppleUserId(),
                    builder: (context, userIdSnapshot) {
                      if (userIdSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                          color: themeColor.color,
                          child: Center(
                              child: SvgPicture.asset(
                                  'assets/icons/reverse_icon.svg')),
                        );
                      } else if (userIdSnapshot.hasError) {
                        return Center(
                            child: Text('エラーが発生しました: ${userIdSnapshot.error}'));
                      } else {
                        final userId = userIdSnapshot.data;
                        debugPrint('userId: $userId');
                        if (userId != null) {
                          return FutureBuilder<User?>(
                            future: ref
                                .read(userProvider.notifier)
                                .fetchUserById(userId),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  color: themeColor.color,
                                  child: Center(
                                      child: SvgPicture.asset(
                                          'assets/icons/reverse_icon.svg')),
                                );
                              } else if (userSnapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'ユーザー取得エラー: ${userSnapshot.error}'));
                              } else {
                                final user = userSnapshot.data;
                                if (user != null) {
                                  _updateCurrentLoginMedia('apple');
                                  return HomeScreen(user: user);
                                } else {
                                  return const LoginScreen();
                                }
                              }
                            },
                          );
                        } else {
                          debugPrint('userIdが存在しないため、LoginScreenに遷移します。');
                          return const LoginScreen();
                        }
                      }
                    },
                  );
                } else {
                  // どちらもログイン状態でなければ、LoginScreenに遷移
                  return const LoginScreen();
                }
              }
            },
          ),
        ));
  }
}
