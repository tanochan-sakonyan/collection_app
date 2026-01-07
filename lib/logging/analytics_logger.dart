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

  // ドロワー表示ログを送信する。
  static Future<void> logDrawerOpened() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'drawer_opened',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // ドロワー閉鎖ログを送信する。
  static Future<void> logDrawerClosed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'drawer_closed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // PayPay登録ボタン押下ログを送信する。
  static Future<void> logPayPayRegisterPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'paypay_register_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // PayPayダイアログ表示ログを送信する。
  static Future<void> logPayPayDialogOpened() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'paypay_dialog_opened',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // PayPayリンク説明ボタン押下ログを送信する。
  static Future<void> logPayPayHelpPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'paypay_help_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // テーマカラー変更ボタン押下ログを送信する。
  static Future<void> logThemeColorChangePressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'theme_color_change_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // テーマカラー選択ログを送信する。
  static Future<void> logThemeColorSelected({
    required String colorKey,
  }) async {
    final parameters = <String, Object>{
      'color_key': colorKey,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'theme_color_selected',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // アンケート表示ログを送信する。
  static Future<void> logQuestionnairePressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'questionnaire_dialog_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 機能提案ボタン押下ログを送信する。
  static Future<void> logSuggestionPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'suggestion_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // Xリンク押下ログを送信する。
  static Future<void> logXLinkPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'x_link_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // アップデート情報押下ログを送信する。
  static Future<void> logUpdateInfoPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'update_info_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 開発者支援ボタン押下ログを送信する。
  static Future<void> logDonationPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'donation_dialog_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 公式サイト押下ログを送信する。
  static Future<void> logOfficialSitePressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'official_site_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 利用規約押下ログを送信する。
  static Future<void> logTermsPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'terms_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // プライバシーポリシー押下ログを送信する。
  static Future<void> logPrivacyPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'privacy_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

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

  // 金額をバケット化する。
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
