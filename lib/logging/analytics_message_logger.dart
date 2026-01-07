import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsMessageLogger {
  // FAB押下ログを送信する。
  static Future<void> logFabPressed({
    required String state,
  }) async {
    final parameters = <String, Object>{
      'state': state,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'fab_pressed',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 催促メッセージ入力画面遷移ログを送信する。
  static Future<void> logReminderMessageInputOpened() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'reminder_message_input_opened',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 催促メッセージ送信確認画面表示ログを送信する。
  static Future<void> logReminderMessageConfirmOpened() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'reminder_message_confirm_opened',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 催促メッセージ送信完了ログを送信する。
  static Future<void> logReminderMessageCompleted({
    required bool includesPayPayLink,
  }) async {
    final parameters = <String, Object>{
      'includes_paypay_link': includesPayPayLink ? 1 : 0,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'reminder_message_completed',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }
}
