# 集金くん Firebase Analytics イベント仕様（AnalyticsLogger）

最終更新: 2026-01-07

このドキュメントは `AnalyticsLogger` に実装されている Firebase Analytics（GA4）ログを、人間が管理しやすいように「役割（責務/機能領域）」ごとに整理したものです。

---

## 共通ルール

- 送信先: Firebase Analytics（GA4）
- 送信方法:
  - `FirebaseAnalytics.instance.logEvent(...)`
  - `FirebaseAnalytics.instance.logScreenView(...)`
  - `FirebaseAnalytics.instance.setUserId(...)`
- 例外時: `try/catch` で握りつぶし、`debugPrint` に出力
- パラメータ: `int / String` のプリミティブのみ推奨（実装は `Map<String, Object>`）

---

# 1. ユーザー識別（User）

## setUserId

- **目的**: ログイン後のユーザー単位でイベントを紐付ける
- **メソッド**: `setUserId(String? userId)`
- **パラメータ**
  - `userId` (String?): 内部ユーザーID（ログアウト時は `null`）

---

# 2. 画面計測（Screen Tracking）

## logScreenView

- **目的**: 画面表示の記録（手動で screenName/screenClass を指定）
- **メソッド**: `logScreenView({required screenName, required screenClass})`
- **パラメータ**
  - `screenName` (String): 画面名
  - `screenClass` (String): 画面クラス名

---

# 3. オンボーディング / 公式LINE導線（Onboarding）

## invite_official_account_screen_viewed

- **イベント名**: `invite_official_account_screen_viewed`
- **タイミング**: 公式LINE招待画面の表示
- **パラメータ**: なし

---

# 4. 認証（Auth）

## login

- **イベント名**: `login`
- **タイミング**: ログイン完了
- **パラメータ**
  - `method` (String): ログイン方法（例: `line`）
  - `is_new` (int): 新規ユーザーか（1/0）

## logout

- **イベント名**: `logout`
- **タイミング**: ログアウト
- **パラメータ**
  - `method` (String): ログアウト方法

## login_failed

- **イベント名**: `login_failed`
- **タイミング**: ログイン失敗
- **パラメータ**
  - `method` (String): ログイン方法

---

# 5. イベント（集金イベント）管理（Event CRUD）

## add_event_button_pressed

- **イベント名**: `add_event_button_pressed`
- **タイミング**: イベント追加ボタン押下
- **パラメータ**
  - `source` (String): 押下元（例: `home` など）

## event_created

- **イベント名**: `event_created`
- **タイミング**: イベント追加成功
- **パラメータ**
  - `event_id` (String): イベントID
  - `mode` (String): 作成モード（アプリ側定義）

## event_edited

- **イベント名**: `event_edited`
- **タイミング**: イベント編集成功
- **パラメータ**
  - `event_id` (String)

## event_deleted

- **イベント名**: `event_deleted`
- **タイミング**: イベント削除成功
- **パラメータ**
  - `event_id` (String)

## event_add_failed

- **イベント名**: `event_add_failed`
- **タイミング**: イベント追加失敗
- **パラメータ**
  - `mode` (String)

---

# 6. メンバー管理（Member CRUD / 操作）

## member_added

- **イベント名**: `member_added`
- **タイミング**: メンバー追加成功
- **パラメータ**
  - `event_id` (String)
  - `member_count` (int): 人数（意味はアプリ側で統一すること）

## member_name_edited

- **イベント名**: `member_name_edited`
- **タイミング**: メンバー名編集
- **パラメータ**
  - `event_id` (String)
  - `member_id` (String)

## member_deleted

- **イベント名**: `member_deleted`
- **タイミング**: メンバー削除
- **パラメータ**
  - `event_id` (String)
  - `is_bulk` (int): 一括操作か（1/0）
  - `member_id` (String, optional): 個別削除の場合など
  - `member_count` (int, optional): 人数

## member_long_pressed

- **イベント名**: `member_long_pressed`
- **タイミング**: メンバー長押し
- **パラメータ**: なし

## duplicate_member_warning_shown

- **イベント名**: `duplicate_member_warning_shown`
- **タイミング**: 重複メンバー警告表示
- **パラメータ**: なし

## member_add_failed

- **イベント名**: `member_add_failed`
- **タイミング**: メンバー追加失敗
- **パラメータ**: なし

---

# 7. 支払いステータス（Payment Status）

## status_changed

- **イベント名**: `status_changed`
- **タイミング**: メンバーの支払いステータス変更
- **パラメータ**
  - `event_id` (String)
  - `status` (int):
    - 1: 支払い済み
    - 2: 未払い
    - 3: 欠席
    - 4: PayPayで支払い済み
  - `is_bulk` (int): 一括変更か（1/0）
  - `member_id` (String, optional)
  - `member_count` (int, optional)

## status_change_failed

- **イベント名**: `status_change_failed`
- **タイミング**: ステータス変更失敗
- **パラメータ**
  - `is_bulk` (int): 一括操作か（1/0）

---

# 8. 一括編集（Bulk Edit）

## bulk_edit_opened

- **イベント名**: `bulk_edit_opened`
- **タイミング**: 一括編集画面へ遷移
- **パラメータ**
  - `event_id` (String)

---

# 9. ドロワー（Drawer）

## drawer_opened

- **イベント名**: `drawer_opened`
- **タイミング**: ドロワー表示
- **パラメータ**: なし

## drawer_closed

- **イベント名**: `drawer_closed`
- **タイミング**: ドロワー閉鎖
- **パラメータ**: なし

---

# 10. 催促（Reminder）

## reminder_message_input_opened

- **イベント名**: `reminder_message_input_opened`
- **タイミング**: 催促メッセージ入力画面へ遷移
- **パラメータ**: なし

## reminder_message_confirm_opened

- **イベント名**: `reminder_message_confirm_opened`
- **タイミング**: 催促メッセージ送信確認画面表示
- **パラメータ**: なし

## reminder_message_completed

- **イベント名**: `reminder_message_completed`
- **タイミング**: 催促メッセージ送信完了
- **パラメータ**
  - `includes_paypay_link` (int): PayPayリンクを含むか（1/0）

---

# 11. Home / 主要UI操作（Home & UI）

## home_screen_viewed

- **イベント名**: `home_screen_viewed`
- **タイミング**: Home画面表示
- **パラメータ**: なし

## memo_bottom_sheet_opened

- **イベント名**: `memo_bottom_sheet_opened`
- **タイミング**: メモ入力ボトムシート表示
- **パラメータ**: なし

## home_help_pressed

- **イベント名**: `home_help_pressed`
- **タイミング**: Home画面ヘルプボタン押下
- **パラメータ**: なし

## sort_pressed

- **イベント名**: `sort_pressed`
- **タイミング**: 並び替えボタン押下
- **パラメータ**: なし

## tab_long_pressed

- **イベント名**: `tab_long_pressed`
- **タイミング**: タブ長押し
- **パラメータ**: なし

## memo_saved

- **イベント名**: `memo_saved`
- **タイミング**: メモ保存
- **パラメータ**: なし

---

# 12. 端数処理（Rounding）

## round_up_option_pressed

- **イベント名**: `round_up_option_pressed`
- **タイミング**: 端数切り上げオプション選択
- **パラメータ**
  - `option` (String): 選択したオプション

---

# 13. 金額入力（Amount Input）

## total_amount_entered

- **イベント名**: `total_amount_entered`
- **タイミング**: 合計金額入力（確定/フォーカスアウトなど）
- **パラメータ**
  - `member_count` (int)
  - `total_amount_bucket` (String): 合計金額バケット（`bucketTotalAmount`で生成）

## individual_amounts_completed

- **イベント名**: `individual_amounts_completed`
- **タイミング**: 個別金額確定（次へ進む瞬間）
- **パラメータ**
  - `member_count` (int)
  - `total_amount_bucket` (String)
  - `per_person_bucket` (String): 1人あたり金額バケット（`bucketPerPersonAmount`で生成）
  - `weight_type` (String): 傾斜タイプ（例: `none/role/individual/mixed`）
  - `role_count` (int): 役割数
  - `max_min_ratio_bucket` (String): 最大/最小の比率バケット（`bucketRatio`で生成）
  - `round_up_option` (String): 端数処理オプション
  - `change` (int): お釣り（円）

### バケット関数

#### bucketTotalAmount(amount)

- `<10000`
- `10000-29999`
- `30000-49999`
- `50000-99999`
- `100000+`

#### bucketPerPersonAmount(amount)

- `<1000`
- `1000-2999`
- `3000-4999`
- `5000-9999`
- `10000+`

#### bucketRatio(ratio)

- `1.0`
- `1.1-1.5`
- `1.6-2.0`
- `2.0+`

---

# 14. LINEグループ連携（LINE Group Integration）

## line_group_add_button_pressed

- **イベント名**: `line_group_add_button_pressed`
- **タイミング**: LINEグループ追加ボタン押下
- **パラメータ**: なし

## line_group_add_screen_viewed

- **イベント名**: `line_group_add_screen_viewed`
- **タイミング**: LINEグループ追加画面表示
- **パラメータ**: なし

## line_group_create_event_pressed

- **イベント名**: `line_group_create_event_pressed`
- **タイミング**: このメンバーでイベント作成ボタン押下
- **パラメータ**: なし

---

# 15. メンバー引き継ぎ（Transfer）

## transfer_members_button_pressed

- **イベント名**: `transfer_members_button_pressed`
- **タイミング**: 他イベントから引継ぎボタン押下
- **パラメータ**: なし

## transfer_this_members_pressed

- **イベント名**: `transfer_this_members_pressed`
- **タイミング**: このメンバーを引き継ぐボタン押下
- **パラメータ**: なし

---

# 16. PayPay（PayPay）

## paypay_register_pressed

- **イベント名**: `paypay_register_pressed`
- **タイミング**: PayPay登録ボタン押下
- **パラメータ**: なし

## paypay_dialog_opened

- **イベント名**: `paypay_dialog_opened`
- **タイミング**: PayPayダイアログ表示
- **パラメータ**: なし

## paypay_help_pressed

- **イベント名**: `paypay_help_pressed`
- **タイミング**: PayPayリンク説明ボタン押下
- **パラメータ**: なし

---

# 17. テーマ/外観設定（Theme）

## theme_color_change_pressed

- **イベント名**: `theme_color_change_pressed`
- **タイミング**: テーマカラー変更ボタン押下
- **パラメータ**: なし

## theme_color_selected

- **イベント名**: `theme_color_selected`
- **タイミング**: テーマカラー選択
- **パラメータ**
  - `color_key` (String)

---

# 18. フィードバック/外部リンク（Feedback & Links）

## questionnaire_dialog_pressed

- **イベント名**: `questionnaire_dialog_pressed`
- **タイミング**: アンケート表示（押下）
- **パラメータ**: なし

## suggestion_pressed

- **イベント名**: `suggestion_pressed`
- **タイミング**: 機能提案ボタン押下
- **パラメータ**: なし

## x_link_pressed

- **イベント名**: `x_link_pressed`
- **タイミング**: Xリンク押下
- **パラメータ**: なし

## update_info_pressed

- **イベント名**: `update_info_pressed`
- **タイミング**: アップデート情報押下
- **パラメータ**: なし

## official_site_pressed

- **イベント名**: `official_site_pressed`
- **タイミング**: 公式サイト押下
- **パラメータ**: なし

---

# 19. 法務（Legal）

## terms_pressed

- **イベント名**: `terms_pressed`
- **タイミング**: 利用規約押下
- **パラメータ**: なし

## privacy_pressed

- **イベント名**: `privacy_pressed`
- **タイミング**: プライバシーポリシー押下
- **パラメータ**: なし

---

# 20. 収益（Ads / Donation）

## banner_ad_shown

- **イベント名**: `banner_ad_shown`
- **タイミング**: バナー広告表示
- **パラメータ**: なし

## interstitial_ad_shown

- **イベント名**: `interstitial_ad_shown`
- **タイミング**: インターステイシャル広告表示
- **パラメータ**: なし

## donation_dialog_pressed

- **イベント名**: `donation_dialog_pressed`
- **タイミング**: 開発者支援ボタン押下
- **パラメータ**: なし

---

# 21. アカウント（Account）

## account_deleted

- **イベント名**: `account_deleted`
- **タイミング**: アカウント削除
- **パラメータ**
  - `method` (String)

---

# 22. 役割設定（Role Setup）

## role_setup_confirmed

- **イベント名**: `role_setup_confirmed`
- **タイミング**: ロール割設定確定
- **パラメータ**
  - `role_count` (int)

---

# 23. アプリライフサイクル（App Lifecycle）

## app_task_ended

- **イベント名**: `app_task_ended`
- **タイミング**: アプリ終了（タスク終了扱い）
- **パラメータ**: なし

---

# 24. その他UI（Floating Action Button）

## fab_pressed

- **イベント名**: `fab_pressed`
- **タイミング**: FAB押下
- **パラメータ**
  - `state` (String)

---
