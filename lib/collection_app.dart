import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mr_collection/ui/screen/home_screen.dart';
import 'package:mr_collection/ui/screen/login_screen.dart';

class CollectionApp extends ConsumerStatefulWidget {
  const CollectionApp({super.key});

  @override
  ConsumerState<CollectionApp> createState() => _CollectionAppState();
}

class _CollectionAppState extends ConsumerState<CollectionApp> {
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

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.montserratTextTheme();

    final collectionAppTextTheme = baseTextTheme.copyWith(
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 16.0),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 14.0),
      bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: 12.0),
      labelLarge: baseTextTheme.labelLarge?.copyWith(fontSize: 11.0),
      labelSmall: baseTextTheme.labelSmall?.copyWith(fontSize: 10.0),
    );

    return MaterialApp(
      title: '集金くん',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
        ),
        brightness: Brightness.light,
        textTheme: collectionAppTextTheme,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Map<String, bool>>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: const Color(0xFF75DCC6),
              child: Center(
                  child: SvgPicture.asset('assets/images/loading_image.svg')),
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
                      color: const Color(0xFF75DCC6),
                      child: Center(
                          child: SvgPicture.asset(
                              'assets/images/loading_image.svg')),
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
                              color: const Color(0xFF75DCC6),
                              child: Center(
                                  child: SvgPicture.asset(
                                      'assets/images/loading_image.svg')),
                            );
                          } else if (userSnapshot.hasError) {
                            return Center(
                                child:
                                    Text('ユーザー取得エラー: ${userSnapshot.error}'));
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
                      color: const Color(0xFF75DCC6),
                      child: Center(
                          child: SvgPicture.asset(
                              'assets/images/loading_image.svg')),
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
                              color: const Color(0xFF75DCC6),
                              child: Center(
                                  child: SvgPicture.asset(
                                      'assets/images/loading_image.svg')),
                            );
                          } else if (userSnapshot.hasError) {
                            return Center(
                                child:
                                    Text('ユーザー取得エラー: ${userSnapshot.error}'));
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
    );
  }
}
