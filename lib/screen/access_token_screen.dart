import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/screen/home_screen.dart';
import 'package:mr_collection/screen/login_screen.dart';

// FIXME: Screenという名前がついているが、実際はスクリーンとして機能していないため、名前を変えたほうが良いかも。
class AccessTokenScreen extends ConsumerWidget {
  const AccessTokenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessToken = ref.watch(accessTokenProvider);

    if (accessToken != null) {
      debugPrint('accessToken: $accessToken');
      return const HomeScreen(
        title: '集金くん',
      );
    } else {
      return const LoginScreen();
    }
  }
}
