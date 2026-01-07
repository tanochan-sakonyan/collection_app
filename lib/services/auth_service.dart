import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:mr_collection/logging/analytics_logger.dart';
import 'package:mr_collection/ui/screen/login_screen.dart';
import 'package:mr_collection/utils/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._(); // 外部からインスタンス化できないように。

  static final LineSDK _lineSdk = LineSDK.instance;

  static Future<void> signOut(BuildContext context) async {
    try {
      await _lineSdk.logout();
    } catch (_) {
      // Ignore logout failures and continue cleanup.
    }

    final prefs = await SharedPreferences.getInstance();
    final currentLoginMedia = prefs.getString('currentLoginMedia');
    if (currentLoginMedia != null && currentLoginMedia.isNotEmpty) {
      await AnalyticsLogger.logLogout(
        method: currentLoginMedia,
      );
    }
    await AnalyticsLogger.setUserId(null);
    await prefs.remove('currentLoginMedia');
    // ログアウトする場合はaccessTokenとrefreshTokenを削除
    await TokenStorage.clearTokens();

    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
