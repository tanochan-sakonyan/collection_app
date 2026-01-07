import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsAmountLogger {
  // 合計金額入力ログを送信する。
  static Future<void> logTotalAmountEntered({
    required int memberCount,
    required String totalAmountBucket,
  }) async {
    final parameters = <String, Object>{
      'member_count': memberCount,
      'total_amount_bucket': totalAmountBucket,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'total_amount_entered',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 個別金額確定ログを送信する。
  static Future<void> logIndividualAmountsCompleted({
    required int memberCount,
    required String totalAmountBucket,
    required String perPersonBucket,
    required String weightType,
    required int roleCount,
    required String maxMinRatioBucket,
    required String roundUpOption,
    required int change,
  }) async {
    final parameters = <String, Object>{
      'member_count': memberCount,
      'total_amount_bucket': totalAmountBucket,
      'per_person_bucket': perPersonBucket,
      'weight_type': weightType,
      'role_count': roleCount,
      'max_min_ratio_bucket': maxMinRatioBucket,
      'round_up_option': roundUpOption,
      'change': change,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'individual_amounts_completed',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 端数切り上げ選択ログを送信する。
  static Future<void> logRoundUpOptionPressed({
    required String option,
  }) async {
    final parameters = <String, Object>{
      'option': option,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'round_up_option_pressed',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // ロール割設定確定ログを送信する。
  static Future<void> logRoleSetupConfirmed({
    required int roleCount,
  }) async {
    final parameters = <String, Object>{
      'role_count': roleCount,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'role_setup_confirmed',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 合計金額をバケット化する。
  static String bucketTotalAmount(int amount) {
    if (amount < 10000) {
      return '<10000';
    }
    if (amount < 30000) {
      return '10000-29999';
    }
    if (amount < 50000) {
      return '30000-49999';
    }
    if (amount < 100000) {
      return '50000-99999';
    }
    return '100000+';
  }

  // 1人あたり金額をバケット化する。
  static String bucketPerPersonAmount(int amount) {
    if (amount < 1000) {
      return '<1000';
    }
    if (amount < 3000) {
      return '1000-2999';
    }
    if (amount < 5000) {
      return '3000-4999';
    }
    if (amount < 10000) {
      return '5000-9999';
    }
    return '10000+';
  }

  // 比率をバケット化する。
  static String bucketRatio(double ratio) {
    if (ratio <= 1.0) {
      return '1.0';
    }
    if (ratio <= 1.5) {
      return '1.1-1.5';
    }
    if (ratio <= 2.0) {
      return '1.6-2.0';
    }
    return '2.0+';
  }
}
