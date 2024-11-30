import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/screen/home_screen.dart';
import 'package:mr_collection/ui/screen/login_screen.dart';

// FIXME: Screenという名前がついているが、実際はスクリーンとして機能していないため、名前を変えたほうが良いかも。
class AccessTokenScreen extends ConsumerWidget {
  const AccessTokenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessToken = ref.watch(accessTokenProvider);
    final user = ref.watch(userProvider);

    if (accessToken != null) {
      debugPrint('accessToken: $accessToken');
      return HomeScreen(
        title: '集金くん',
        user: user,
      );
    } else {
      return const LoginScreen();
    }
  }
}
