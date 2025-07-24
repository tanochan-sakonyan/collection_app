import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ユーザー操作イベント
  static const String screenView = 'screen_view';
  static const String buttonTap = 'button_tap';
  static const String textInput = 'text_input';
  static const String itemSelect = 'item_select';
  static const String swipeAction = 'swipe_action';
  static const String longPress = 'long_press';
  static const String tabSwitch = 'tab_switch';
  static const String checkboxToggle = 'checkbox_toggle';
  static const String dialogOpen = 'dialog_open';
  static const String dialogClose = 'dialog_close';
  static const String externalLinkTap = 'external_link_tap';
  static const String navigationBack = 'navigation_back';

  // ログイン・認証関連
  Future<void> logLogin(String method) async {
    await _logEvent('login', {'method': method});
  }

  Future<void> logLogout() async {
    await _logEvent('logout', {});
  }

  Future<void> logSignUp(String method) async {
    await _logEvent('sign_up', {'method': method});
  }

  // 画面遷移
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // ボタンタップ
  Future<void> logButtonTap(String buttonName, {String? screen, Map<String, Object>? parameters}) async {
    final params = <String, Object>{
      'button_name': buttonName,
      if (screen != null) 'screen': screen,
      ...?parameters,
    };
    await _logEvent(buttonTap, params);
  }

  // テキスト入力
  Future<void> logTextInput(String fieldName, {String? screen, int? length}) async {
    final params = <String, Object>{
      'field_name': fieldName,
      if (screen != null) 'screen': screen,
      if (length != null) 'input_length': length,
    };
    await _logEvent(textInput, params);
  }

  // アイテム選択
  Future<void> logItemSelect(String itemType, String itemId, {String? screen}) async {
    final params = <String, Object>{
      'item_type': itemType,
      'item_id': itemId,
      if (screen != null) 'screen': screen,
    };
    await _logEvent(itemSelect, params);
  }

  // スワイプアクション
  Future<void> logSwipeAction(String action, String itemType, {String? screen}) async {
    final params = <String, Object>{
      'action': action,
      'item_type': itemType,
      if (screen != null) 'screen': screen,
    };
    await _logEvent(swipeAction, params);
  }

  // 長押し
  Future<void> logLongPress(String element, {String? screen}) async {
    final params = <String, Object>{
      'element': element,
      if (screen != null) 'screen': screen,
    };
    await _logEvent(longPress, params);
  }

  // タブ切り替え
  Future<void> logTabSwitch(String fromTab, String toTab, {String? screen}) async {
    final params = <String, Object>{
      'from_tab': fromTab,
      'to_tab': toTab,
      if (screen != null) 'screen': screen,
    };
    await _logEvent(tabSwitch, params);
  }

  // チェックボックス操作
  Future<void> logCheckboxToggle(String checkboxName, bool isChecked, {String? screen}) async {
    final params = <String, Object>{
      'checkbox_name': checkboxName,
      'is_checked': isChecked,
      if (screen != null) 'screen': screen,
    };
    await _logEvent(checkboxToggle, params);
  }

  // ダイアログ操作
  Future<void> logDialogOpen(String dialogName, {String? screen}) async {
    final params = <String, Object>{
      'dialog_name': dialogName,
      if (screen != null) 'screen': screen,
    };
    await _logEvent(dialogOpen, params);
  }

  Future<void> logDialogClose(String dialogName, String action, {String? screen}) async {
    final params = <String, Object>{
      'dialog_name': dialogName,
      'action': action,
      if (screen != null) 'screen': screen,
    };
    await _logEvent(dialogClose, params);
  }

  // 外部リンク
  Future<void> logExternalLinkTap(String linkName, String url, {String? screen}) async {
    final params = <String, Object>{
      'link_name': linkName,
      'url': url,
      if (screen != null) 'screen': screen,
    };
    await _logEvent(externalLinkTap, params);
  }

  // 戻るナビゲーション
  Future<void> logNavigationBack(String fromScreen, {String? toScreen}) async {
    final params = <String, Object>{
      'from_screen': fromScreen,
      if (toScreen != null) 'to_screen': toScreen,
    };
    await _logEvent(navigationBack, params);
  }

  // イベント関連
  Future<void> logEventCreate(String eventName, {int? memberCount}) async {
    final params = <String, Object>{
      'event_name': eventName,
      if (memberCount != null) 'member_count': memberCount,
    };
    await _logEvent('event_create', params);
  }

  Future<void> logEventEdit(String eventId, {String? newName}) async {
    final params = <String, Object>{
      'event_id': eventId,
      if (newName != null) 'new_name': newName,
    };
    await _logEvent('event_edit', params);
  }

  Future<void> logEventDelete(String eventId) async {
    await _logEvent('event_delete', {'event_id': eventId});
  }

  // メンバー関連
  Future<void> logMemberAdd(String eventId, int memberCount) async {
    final params = <String, Object>{
      'event_id': eventId,
      'member_count': memberCount,
    };
    await _logEvent('member_add', params);
  }

  Future<void> logMemberEdit(String memberId, {String? newName}) async {
    final params = <String, Object>{
      'member_id': memberId,
      if (newName != null) 'new_name': newName,
    };
    await _logEvent('member_edit', params);
  }

  Future<void> logMemberDelete(String memberId) async {
    await _logEvent('member_delete', {'member_id': memberId});
  }

  Future<void> logMemberStatusChange(String memberId, String newStatus) async {
    final params = <String, Object>{
      'member_id': memberId,
      'new_status': newStatus,
    };
    await _logEvent('member_status_change', params);
  }

  // 金額関連
  Future<void> logAmountInput(String eventId, int amount) async {
    final params = <String, Object>{
      'event_id': eventId,
      'amount': amount,
    };
    await _logEvent('amount_input', params);
  }

  Future<void> logAmountSplit(String eventId, String splitType, int memberCount) async {
    final params = <String, Object>{
      'event_id': eventId,
      'split_type': splitType,
      'member_count': memberCount,
    };
    await _logEvent('amount_split', params);
  }

  // LINE関連
  Future<void> logLineMessage(String eventId, {bool? includePaypay}) async {
    final params = <String, Object>{
      'event_id': eventId,
      if (includePaypay != null) 'include_paypay': includePaypay,
    };
    await _logEvent('line_message_send', params);
  }

  Future<void> logLineGroupUpdate(String eventId) async {
    await _logEvent('line_group_update', {'event_id': eventId});
  }

  // 役割関連
  Future<void> logRoleCreate(String roleName, int amount) async {
    final params = <String, Object>{
      'role_name': roleName,
      'amount': amount,
    };
    await _logEvent('role_create', params);
  }

  Future<void> logRoleAssign(String memberId, String roleName) async {
    final params = <String, Object>{
      'member_id': memberId,
      'role_name': roleName,
    };
    await _logEvent('role_assign', params);
  }

  // 設定関連
  Future<void> logPaypaySetup(bool hasUrl) async {
    await _logEvent('paypay_setup', {'has_url': hasUrl});
  }

  Future<void> logSurveyResponse(String question, String answer) async {
    final params = <String, Object>{
      'question': question,
      'answer': answer,
    };
    await _logEvent('survey_response', params);
  }

  // プライベートヘルパーメソッド
  Future<void> _logEvent(String name, Map<String, Object> parameters) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      if (kDebugMode) {
        debugPrint('Analytics Event: $name, Parameters: $parameters');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Analytics Error: $e');
      }
    }
  }

  // ユーザープロパティ設定
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}