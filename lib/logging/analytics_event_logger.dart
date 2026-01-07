import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsEventLogger {
  // イベント追加ボタンログを送信する。
  static Future<void> logAddEventButtonPressed({
    required String source,
  }) async {
    final parameters = <String, Object>{
      'source': source,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'add_event_button_pressed',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // イベント追加ログを送信する。
  static Future<void> logEventCreated({
    required String eventId,
    required String mode,
  }) async {
    final parameters = <String, Object>{
      'event_id': eventId,
      'mode': mode,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'event_created',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // イベント編集ログを送信する。
  static Future<void> logEventEdited({
    required String eventId,
  }) async {
    final parameters = <String, Object>{
      'event_id': eventId,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'event_edited',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // イベント削除ログを送信する。
  static Future<void> logEventDeleted({
    required String eventId,
  }) async {
    final parameters = <String, Object>{
      'event_id': eventId,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'event_deleted',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // イベント追加失敗ログを送信する。
  static Future<void> logEventAddFailed({
    required String mode,
  }) async {
    final parameters = <String, Object>{
      'mode': mode,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'event_add_failed',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }
}
