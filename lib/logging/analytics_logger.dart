import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsLogger {
  // ユーザーIDを設定する。
  static Future<void> setUserId(String? userId) async {
    try {
      await FirebaseAnalytics.instance.setUserId(id: userId);
    } catch (error) {
      debugPrint('AnalyticsユーザーID設定に失敗しました: $error');
    }
  }

  // 画面表示ログを送信する。
  static Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  }) async {
    try {
      await FirebaseAnalytics.instance.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (error) {
      debugPrint('Analytics画面ログ送信に失敗しました: $error');
    }
  }

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

  // ステータス変更ログを送信する。
  static Future<void> logMemberStatusChanged({
    required String eventId,
    String? memberId,
    required int status,
    required bool isBulk,
    int? memberCount,
  }) async {
    final parameters = <String, Object>{
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

  // イベント追加ボタンのログを送信する。
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
}
