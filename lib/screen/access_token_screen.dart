import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/screen/home_screen.dart';
import 'package:mr_collection/screen/login_screen.dart';

class AccessTokenScreen extends ConsumerWidget {
  const AccessTokenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessToken = "AdWzO3Z7T3BIpOGI6SMxNkm0UBwqxAcBRkqCgbFb94C3kKGYWL4E4iU3ozmK83ATEt4+B94o8co+Z4OAPjxoTeXG7qtVHcDJPWfqQZKybziN9BIPTjrtNSpKf3Mtt9wOuxwqL+FFefNLVfqPulUrRgdB04t89/1O/w1cDnyilFU="; //mockTokenとして自分の持っているアカウントのトークンを食わせる

    if (accessToken != null) {
      return const HomeScreen(
        title: '集金くん',
      );
    } else {
      return const LoginScreen();
    }
  }
}
