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
      'status': status,
      'is_bulk': isBulk,
    };
    if (memberId != null) {
      parameters['member_id'] = memberId;
    }
    if (memberCount != null) {
      parameters['member_count'] = memberCount;
    }
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'member_status_changed',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }
}
