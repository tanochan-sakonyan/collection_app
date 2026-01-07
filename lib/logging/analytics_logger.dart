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

  // アカウント削除ログを送信する。
  static Future<void> logAccountDeleted({
    required String method,
  }) async {
    final parameters = <String, Object>{
      'method': method,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'account_deleted',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

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

  // Home画面表示ログを送信する。
  static Future<void> logHomeScreenViewed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'home_screen_viewed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // メモ入力ボトムシート表示ログを送信する。
  static Future<void> logMemoBottomSheetOpened() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'memo_bottom_sheet_opened',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // Home画面のヘルプボタン押下ログを送信する。
  static Future<void> logHomeHelpPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'home_help_pressed',
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

  // タブ長押しログを送信する。
  static Future<void> logTabLongPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'tab_long_pressed',
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

  // 重複メンバー警告表示ログを送信する。
  static Future<void> logDuplicateMemberWarningShown() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'duplicate_member_warning_shown',
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

  // バナー広告表示ログを送信する。
  static Future<void> logBannerAdShown() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'banner_ad_shown',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // インターステイシャル広告表示ログを送信する。
  static Future<void> logInterstitialAdShown() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'interstitial_ad_shown',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // メモ保存ログを送信する。
  static Future<void> logMemoSaved() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'memo_saved',
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

  // ログイン失敗ログを送信する。
  static Future<void> logLoginFailed({
    required String method,
  }) async {
    final parameters = <String, Object>{
      'method': method,
    };
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'login_failed',
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // LINEグループ追加ボタン押下ログを送信する。
  static Future<void> logLineGroupAddPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'line_group_add_button_pressed',
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
        name: 'transfer_members_button_pressed',
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
