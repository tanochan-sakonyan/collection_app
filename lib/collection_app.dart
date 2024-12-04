import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mr_collection/ui/screen/home_screen.dart';
import 'package:mr_collection/ui/screen/login_screen.dart';

class CollectionApp extends ConsumerWidget {
  const CollectionApp({super.key});

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          } else {
            final isLoggedIn = snapshot.data ?? false;
            final user = ref.watch(userProvider);
            if (isLoggedIn) {
              return HomeScreen(
                title: '集金くん',
                user: user,
              );
            } else {
              return const LoginScreen();
            }
          }
        },
      ),
    );
  }
}
