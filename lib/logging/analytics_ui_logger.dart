import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsUiLogger {
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

  // Home画面の共有ボタン押下ログを送信する。
  static Future<void> logShareButtonPressed() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'share_button_pressed',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 匿名カード共有ログを送信する。
  static Future<void> logShareAnonymousCard() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'share_anonymous_card',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // 詳細カード共有ログを送信する。
  static Future<void> logShareDetailCard() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'share_detail_card',
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
}
