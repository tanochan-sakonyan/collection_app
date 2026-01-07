import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsAuthLogger {
  // ユーザーIDを設定する。
  static Future<void> setUserId(String? userId) async {
    try {
      await FirebaseAnalytics.instance.setUserId(id: userId);
    } catch (error) {
      debugPrint('AnalyticsユーザーID設定に失敗しました: $error');
    }
  }

  // ログインログを送信する。
  static Future<void> logLogin({
    required String method,
    required bool isNew,
  }) async {
    final parameters = <String, Object>{
      'method': method,
      'is_new': isNew ? 1 : 0,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'login',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // ログイン失敗ログを送信する。
  static Future<void> logLoginFailed({
    required String method,
  }) async {
    final parameters = <String, Object>{
      'method': method,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'login_failed',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // ログアウトログを送信する。
  static Future<void> logLogout({
    required String method,
  }) async {
    final parameters = <String, Object>{
      'method': method,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'logout',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // アカウント削除ログを送信する。
  static Future<void> logAccountDeleted({
    required String method,
  }) async {
    final parameters = <String, Object>{
      'method': method,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'account_deleted',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }
}
