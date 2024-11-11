import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/screen/home_screen.dart';
import 'package:mr_collection/screen/login_screen.dart';

class AccessTokenScreen extends ConsumerWidget {
  const AccessTokenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessToken = ref.watch(accessTokenProvider);

    if (accessToken != null) {
      return const HomeScreen(
        title: '集金くん',
      );
    } else {
      return const LoginScreen();
    }
  }
}
