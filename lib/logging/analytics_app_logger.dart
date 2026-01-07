import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsAppLogger {
  // アプリ終了ログを送信する。
  static Future<void> logAppTaskEnded() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'app_task_ended',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }
}
