import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsLineLogger {
  // 公式LINE招待画面の表示ログを送信する。
  static Future<void> logInviteOfficialAccountScreenViewed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'invite_official_account_screen_viewed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // LINEグループ追加ボタン押下ログを送信する。
  static Future<void> logLineGroupAddPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'line_group_add_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // LINEグループ追加画面表示ログを送信する。
  static Future<void> logLineGroupAddScreenViewed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'line_group_add_screen_viewed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // このメンバーでイベント作成ボタン押下ログを送信する。
  static Future<void> logLineGroupCreateEventPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'line_group_create_event_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 他イベントから引継ぎボタン押下ログを送信する。
  static Future<void> logTransferMembersPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'transfer_members_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // このメンバーを引き継ぐボタン押下ログを送信する。
  static Future<void> logTransferThisMembersPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'transfer_this_members_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }
}
