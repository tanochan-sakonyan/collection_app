import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsLogger {
  // ステータス変更ログを送信する。
  static Future<void> logMemberStatusChanged({
    required String userId,
    required String eventId,
    String? memberId,
    required int status,
    required bool isBulk,
    int? memberCount,
  }) async {
    final parameters = <String, Object>{
      'user_id': userId,
      'event_id': eventId,
      'status': status, // 1: 支払い済み, 2: 未払い, 3: 欠席, 4; PayPayで支払い済み
      'is_bulk': isBulk ? 1 : 0,
    };
    if (memberId != null) {
      parameters['member_id'] = memberId;
    }
    if (memberCount != null) {
      parameters['member_count'] = memberCount;
    }
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'status_changed',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // イベント追加ログを送信する。
  static Future<void> logEventCreated({
    required String userId,
    required String eventId,
    required String mode,
  }) async {
    final parameters = <String, Object>{
      'user_id': userId,
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

  // ログインログを送信する。
  static Future<void> logLogin({
    required String userId,
    required String method,
    required bool isNew,
  }) async {
    final parameters = <String, Object>{
      'user_id': userId,
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

  // ログアウトログを送信する。
  static Future<void> logLogout({
    String? userId,
    required String method,
  }) async {
    final parameters = <String, Object>{
      'method': method,
    };
    if (userId != null && userId.isNotEmpty) {
      parameters['user_id'] = userId;
    }
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'logout',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }
}
