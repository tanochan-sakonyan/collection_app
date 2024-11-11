import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/screen/home_screen.dart';
import 'package:mr_collection/screen/login_screen.dart';

class AccessTokenScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessTokenAsyncValue = ref.watch(accessTokenProvider);

    return accessTokenAsyncValue.when(
      data: (accessToken) {
        if (accessToken != null) {
          return HomeScreen(
            title: '集金くん',
          ); // アクセストークンが取得できた場合
        } else {
          return LoginScreen(); // アクセストークンがnullの場合
        }
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()), // ローディング中
      error: (error, stack) => Center(child: Text('Error: $error')), // エラー発生時
    );
  }
}
