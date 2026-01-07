import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsMemberLogger {
  // メンバー追加ログを送信する。
  static Future<void> logMemberAdded({
    required String eventId,
    required int memberCount,
  }) async {
    final parameters = <String, Object>{
      'event_id': eventId,
      'member_count': memberCount,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'member_added',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // メンバー追加失敗ログを送信する。
  static Future<void> logMemberAddFailed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'member_add_failed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // メンバー名編集ログを送信する。
  static Future<void> logMemberNameEdited({
    required String eventId,
    required String memberId,
  }) async {
    final parameters = <String, Object>{
      'event_id': eventId,
      'member_id': memberId,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'member_name_edited',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // メンバー削除ログを送信する。
  static Future<void> logMemberDeleted({
    required String eventId,
    String? memberId,
    required bool isBulk,
    int? memberCount,
  }) async {
    final parameters = <String, Object>{
      'event_id': eventId,
      'is_bulk': isBulk ? 1 : 0,
    };
    if (memberId != null && memberId.isNotEmpty) {
      parameters['member_id'] = memberId;
    }
    if (memberCount != null) {
      parameters['member_count'] = memberCount;
    }
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'member_deleted',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // メンバーステータス変更ログを送信する。
  static Future<void> logMemberStatusChanged({
    required String eventId,
    String? memberId,
    required int status,
    required bool isBulk,
    int? memberCount,
  }) async {
    final parameters = <String, Object>{
      'event_id': eventId,
      'status': status,
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

  // ステータス変更失敗ログを送信する。
  static Future<void> logStatusChangeFailed({
    required bool isBulk,
  }) async {
    final parameters = <String, Object>{
      'is_bulk': isBulk ? 1 : 0,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'status_change_failed',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 一括編集画面遷移ログを送信する。
  static Future<void> logBulkEditOpened({
    required String eventId,
  }) async {
    final parameters = <String, Object>{
      'event_id': eventId,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'bulk_edit_opened',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 並び替えボタン押下ログを送信する。
  static Future<void> logSortPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'sort_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // メンバー長押しログを送信する。
  static Future<void> logMemberLongPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'member_long_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }
}
