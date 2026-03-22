import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 's_en.dart';
import 's_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/s.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('en')
  ];

  /// No description provided for @shukinkun.
  ///
  /// In ja, this message translates to:
  /// **'集金くん'**
  String get shukinkun;

  /// No description provided for @member.
  ///
  /// In ja, this message translates to:
  /// **'メンバー'**
  String get member;

  /// No description provided for @noMembers.
  ///
  /// In ja, this message translates to:
  /// **'メンバーがいません。'**
  String get noMembers;

  /// No description provided for @sort.
  ///
  /// In ja, this message translates to:
  /// **'並び替え'**
  String get sort;

  /// No description provided for @addMembers.
  ///
  /// In ja, this message translates to:
  /// **'メンバー追加'**
  String get addMembers;

  /// No description provided for @unpaid.
  ///
  /// In ja, this message translates to:
  /// **'未払い'**
  String get unpaid;

  /// No description provided for @paid.
  ///
  /// In ja, this message translates to:
  /// **'支払済'**
  String get paid;

  /// No description provided for @status_paid.
  ///
  /// In ja, this message translates to:
  /// **'支払い済み'**
  String get status_paid;

  /// No description provided for @status_unpaid.
  ///
  /// In ja, this message translates to:
  /// **'未払い'**
  String get status_unpaid;

  /// No description provided for @status_absence.
  ///
  /// In ja, this message translates to:
  /// **'欠席'**
  String get status_absence;

  /// No description provided for @status_paypay.
  ///
  /// In ja, this message translates to:
  /// **'PayPayで\n支払い済み'**
  String get status_paypay;

  /// No description provided for @person.
  ///
  /// In ja, this message translates to:
  /// **'人'**
  String get person;

  /// No description provided for @settlePayment.
  ///
  /// In ja, this message translates to:
  /// **'合計 ---円'**
  String get settlePayment;

  /// No description provided for @update_1.
  ///
  /// In ja, this message translates to:
  /// **'LINEとの連携機能を現在開発中です。'**
  String get update_1;

  /// No description provided for @update_2.
  ///
  /// In ja, this message translates to:
  /// **'アップデートをお待ちください。'**
  String get update_2;

  /// No description provided for @setting.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get setting;

  /// No description provided for @paypay.
  ///
  /// In ja, this message translates to:
  /// **'PayPayリンクを登録'**
  String get paypay;

  /// No description provided for @paypayDialogMessage1.
  ///
  /// In ja, this message translates to:
  /// **'PayPayリンクを\n入力してください。'**
  String get paypayDialogMessage1;

  /// No description provided for @paypayDialogMessage2.
  ///
  /// In ja, this message translates to:
  /// **'受け取りリンクを入力'**
  String get paypayDialogMessage2;

  /// No description provided for @paypayDialogMessage3.
  ///
  /// In ja, this message translates to:
  /// **'反映まで3~5ほどかかる場合があります。'**
  String get paypayDialogMessage3;

  /// No description provided for @paypayDialogSuccessMessage.
  ///
  /// In ja, this message translates to:
  /// **'PayPayリンクを送信しました。'**
  String get paypayDialogSuccessMessage;

  /// No description provided for @paypayDialogFailMessage.
  ///
  /// In ja, this message translates to:
  /// **'PayPayリンクの送信に失敗しました。'**
  String get paypayDialogFailMessage;

  /// No description provided for @questionnaire.
  ///
  /// In ja, this message translates to:
  /// **'アンケート'**
  String get questionnaire;

  /// No description provided for @logout.
  ///
  /// In ja, this message translates to:
  /// **'ログアウト'**
  String get logout;

  /// No description provided for @termsOfService.
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get privacyPolicy;

  /// No description provided for @deleteAccount.
  ///
  /// In ja, this message translates to:
  /// **'アカウントの削除'**
  String get deleteAccount;

  /// No description provided for @questionnaireDescription.
  ///
  /// In ja, this message translates to:
  /// **'「集金くん」に追加してほしい機能があれば、\nぜひご意見ください！'**
  String get questionnaireDescription;

  /// No description provided for @feedbackThanks.
  ///
  /// In ja, this message translates to:
  /// **'今後のアップデートの\n参考にさせていただきます。'**
  String get feedbackThanks;

  /// No description provided for @suggest.
  ///
  /// In ja, this message translates to:
  /// **'機能を提案する'**
  String get suggest;

  /// No description provided for @logoutMessage.
  ///
  /// In ja, this message translates to:
  /// **'ログアウトしますか？'**
  String get logoutMessage;

  /// No description provided for @no.
  ///
  /// In ja, this message translates to:
  /// **'いいえ'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In ja, this message translates to:
  /// **'はい'**
  String get yes;

  /// No description provided for @caution.
  ///
  /// In ja, this message translates to:
  /// **'注意'**
  String get caution;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In ja, this message translates to:
  /// **'アカウントを削除した場合、\nすべてのデータが初期化されます。\nデータの復旧を行うことは\nできません。'**
  String get deleteAccountMessage;

  /// No description provided for @confirmAction.
  ///
  /// In ja, this message translates to:
  /// **'本当によろしいですか？'**
  String get confirmAction;

  /// No description provided for @confirmDeleteAction.
  ///
  /// In ja, this message translates to:
  /// **'上記を確認し、削除を希望する'**
  String get confirmDeleteAction;

  /// No description provided for @deletionComplete.
  ///
  /// In ja, this message translates to:
  /// **'削除が完了しました。'**
  String get deletionComplete;

  /// No description provided for @ok.
  ///
  /// In ja, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @loginWithLine.
  ///
  /// In ja, this message translates to:
  /// **'LINEでログイン'**
  String get loginWithLine;

  /// No description provided for @signInWithApple.
  ///
  /// In ja, this message translates to:
  /// **'Appleでサインイン'**
  String get signInWithApple;

  /// No description provided for @termsAndPrivacyIntro.
  ///
  /// In ja, this message translates to:
  /// **''**
  String get termsAndPrivacyIntro;

  /// No description provided for @and.
  ///
  /// In ja, this message translates to:
  /// **'と'**
  String get and;

  /// No description provided for @termsAndPrivacySuffix.
  ///
  /// In ja, this message translates to:
  /// **'に同意します。'**
  String get termsAndPrivacySuffix;

  /// No description provided for @maxCharacterMessage_9.
  ///
  /// In ja, this message translates to:
  /// **'最大9文字まで入力可能です'**
  String get maxCharacterMessage_9;

  /// No description provided for @maxCharacterMessage_8.
  ///
  /// In ja, this message translates to:
  /// **'最大8文字まで入力可能です'**
  String get maxCharacterMessage_8;

  /// No description provided for @enterMemberPrompt.
  ///
  /// In ja, this message translates to:
  /// **'メンバーを入力してください'**
  String get enterMemberPrompt;

  /// No description provided for @multiMemberHint.
  ///
  /// In ja, this message translates to:
  /// **'メンバーを改行区切りでまとめて登録できます'**
  String get multiMemberHint;

  /// No description provided for @confirm.
  ///
  /// In ja, this message translates to:
  /// **'確 定'**
  String get confirm;

  /// No description provided for @addEvent.
  ///
  /// In ja, this message translates to:
  /// **'イベント作成'**
  String get addEvent;

  /// No description provided for @transferMembers.
  ///
  /// In ja, this message translates to:
  /// **'メンバー引継ぎ'**
  String get transferMembers;

  /// No description provided for @selectEvent.
  ///
  /// In ja, this message translates to:
  /// **'イベントを選択'**
  String get selectEvent;

  /// No description provided for @addFromLine.
  ///
  /// In ja, this message translates to:
  /// **'LINEグループ'**
  String get addFromLine;

  /// No description provided for @back.
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get back;

  /// No description provided for @selectEventToTransfer.
  ///
  /// In ja, this message translates to:
  /// **'メンバーを引継ぎたい\nイベントを選択してください'**
  String get selectEventToTransfer;

  /// No description provided for @confirmTransferFromEvent.
  ///
  /// In ja, this message translates to:
  /// **'のメンバーを引継ぎますか？'**
  String get confirmTransferFromEvent;

  /// No description provided for @transferThisMember.
  ///
  /// In ja, this message translates to:
  /// **'このメンバーを引継ぐ'**
  String get transferThisMember;

  /// No description provided for @enterEventName.
  ///
  /// In ja, this message translates to:
  /// **'イベント名を入力してください'**
  String get enterEventName;

  /// No description provided for @tapToAddEvent.
  ///
  /// In ja, this message translates to:
  /// **'こちらをタップでイベントを\n追加できます'**
  String get tapToAddEvent;

  /// No description provided for @longPressToDeleteEvent.
  ///
  /// In ja, this message translates to:
  /// **'タップでイベントを編集\n長押しでイベントを削除\nできます'**
  String get longPressToDeleteEvent;

  /// No description provided for @tapToAddMember.
  ///
  /// In ja, this message translates to:
  /// **'こちらをタップでメンバーを\n追加できます'**
  String get tapToAddMember;

  /// No description provided for @swipeToEditOrDeleteMember.
  ///
  /// In ja, this message translates to:
  /// **'スワイプでメンバーの削除及び\nメンバー名の変更ができます'**
  String get swipeToEditOrDeleteMember;

  /// No description provided for @tapToSortByPayment.
  ///
  /// In ja, this message translates to:
  /// **'こちらをタップで支払い状況順に\n並び変えることができます'**
  String get tapToSortByPayment;

  /// No description provided for @tapToSendReminder.
  ///
  /// In ja, this message translates to:
  /// **'こちらをタップで催促メッセージを\n送信できます'**
  String get tapToSendReminder;

  /// No description provided for @skip.
  ///
  /// In ja, this message translates to:
  /// **'スキップ'**
  String get skip;

  /// No description provided for @edit.
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// No description provided for @editMemberName.
  ///
  /// In ja, this message translates to:
  /// **'メンバー名編集'**
  String get editMemberName;

  /// No description provided for @editEventName.
  ///
  /// In ja, this message translates to:
  /// **'イベント名編集'**
  String get editEventName;

  /// No description provided for @confirmDeleteMember.
  ///
  /// In ja, this message translates to:
  /// **'このメンバーを削除しますか？'**
  String get confirmDeleteMember;

  /// No description provided for @enterTotalAmount.
  ///
  /// In ja, this message translates to:
  /// **'合計金額の入力'**
  String get enterTotalAmount;

  /// No description provided for @currencyUnit.
  ///
  /// In ja, this message translates to:
  /// **'円'**
  String get currencyUnit;

  /// No description provided for @next.
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get next;

  /// No description provided for @setIndividualAmounts.
  ///
  /// In ja, this message translates to:
  /// **'個別金額の設定'**
  String get setIndividualAmounts;

  /// No description provided for @splitEqually.
  ///
  /// In ja, this message translates to:
  /// **'割り勘'**
  String get splitEqually;

  /// No description provided for @adjustAmounts.
  ///
  /// In ja, this message translates to:
  /// **'金額の調整'**
  String get adjustAmounts;

  /// No description provided for @adjustByRole.
  ///
  /// In ja, this message translates to:
  /// **'役割から調整'**
  String get adjustByRole;

  /// No description provided for @roleBasedAmountSetting.
  ///
  /// In ja, this message translates to:
  /// **'役割別に金額を設定する'**
  String get roleBasedAmountSetting;

  /// No description provided for @roleSetupDescription.
  ///
  /// In ja, this message translates to:
  /// **'3年生は3000円、2年生は2000円、\n1年生は残りを割り勘....のように\n役割別で割り勘をしたいときにおすすめ！'**
  String get roleSetupDescription;

  /// No description provided for @inputRole.
  ///
  /// In ja, this message translates to:
  /// **'役割を入力する'**
  String get inputRole;

  /// No description provided for @roleSetup.
  ///
  /// In ja, this message translates to:
  /// **'役割設定'**
  String get roleSetup;

  /// No description provided for @roleNameInput.
  ///
  /// In ja, this message translates to:
  /// **'役割名を入力'**
  String get roleNameInput;

  /// No description provided for @assignRole.
  ///
  /// In ja, this message translates to:
  /// **'役割を一括割り当て'**
  String get assignRole;

  /// No description provided for @assign.
  ///
  /// In ja, this message translates to:
  /// **'割り当て'**
  String get assign;

  /// No description provided for @assignRoleToMembers.
  ///
  /// In ja, this message translates to:
  /// **'を一括割り当て'**
  String get assignRoleToMembers;

  /// No description provided for @modifyRole.
  ///
  /// In ja, this message translates to:
  /// **'役割を修正'**
  String get modifyRole;

  /// No description provided for @noRole.
  ///
  /// In ja, this message translates to:
  /// **'役割無し'**
  String get noRole;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @enterAmount.
  ///
  /// In ja, this message translates to:
  /// **'金額を入力'**
  String get enterAmount;

  /// No description provided for @seniorStudent.
  ///
  /// In ja, this message translates to:
  /// **'4年'**
  String get seniorStudent;

  /// No description provided for @freshmanStudent.
  ///
  /// In ja, this message translates to:
  /// **'新入生'**
  String get freshmanStudent;

  /// No description provided for @splitMode.
  ///
  /// In ja, this message translates to:
  /// **'割り勘モード'**
  String get splitMode;

  /// No description provided for @adjustMode.
  ///
  /// In ja, this message translates to:
  /// **'金額の調整モード'**
  String get adjustMode;

  /// No description provided for @sameAmountForAll.
  ///
  /// In ja, this message translates to:
  /// **'全員が同じ金額でのお支払い'**
  String get sameAmountForAll;

  /// No description provided for @lockMemberAmount.
  ///
  /// In ja, this message translates to:
  /// **'ロック🔒で特定のメンバーの金額を固定！'**
  String get lockMemberAmount;

  /// No description provided for @splitRemaining.
  ///
  /// In ja, this message translates to:
  /// **'残りのメンバーで割り勘！'**
  String get splitRemaining;

  /// No description provided for @example_1.
  ///
  /// In ja, this message translates to:
  /// **'田中さん'**
  String get example_1;

  /// No description provided for @example_2.
  ///
  /// In ja, this message translates to:
  /// **'鈴木さん'**
  String get example_2;

  /// No description provided for @example_3.
  ///
  /// In ja, this message translates to:
  /// **'進藤さん'**
  String get example_3;

  /// No description provided for @example_4.
  ///
  /// In ja, this message translates to:
  /// **'進藤部長'**
  String get example_4;

  /// No description provided for @example_5.
  ///
  /// In ja, this message translates to:
  /// **'斉藤ちゃん'**
  String get example_5;

  /// No description provided for @example_6.
  ///
  /// In ja, this message translates to:
  /// **'田中くん'**
  String get example_6;

  /// No description provided for @confirmDeleteEvent.
  ///
  /// In ja, this message translates to:
  /// **'このイベントを削除しますか？'**
  String get confirmDeleteEvent;

  /// No description provided for @suggestFeature.
  ///
  /// In ja, this message translates to:
  /// **'機能を提案する'**
  String get suggestFeature;

  /// No description provided for @xLink.
  ///
  /// In ja, this message translates to:
  /// **'Xリンク'**
  String get xLink;

  /// No description provided for @officialSite.
  ///
  /// In ja, this message translates to:
  /// **'公式サイト'**
  String get officialSite;

  /// No description provided for @openFailed.
  ///
  /// In ja, this message translates to:
  /// **'ページを開けませんでした'**
  String get openFailed;

  /// No description provided for @updateInformation.
  ///
  /// In ja, this message translates to:
  /// **'アップデート情報'**
  String get updateInformation;

  /// No description provided for @selectLineGroupTitle.
  ///
  /// In ja, this message translates to:
  /// **'LINEグループから\nメンバー追加'**
  String get selectLineGroupTitle;

  /// No description provided for @selectLineGroupDesc1.
  ///
  /// In ja, this message translates to:
  /// **'追加したいメンバーの\nLINEグループを選択してください'**
  String get selectLineGroupDesc1;

  /// No description provided for @notDisplayedQuestion.
  ///
  /// In ja, this message translates to:
  /// **'LINEグループが表示されない？'**
  String get notDisplayedQuestion;

  /// No description provided for @inviteOfficialAccountTitle.
  ///
  /// In ja, this message translates to:
  /// **'LINE公式アカウントを、\n集金対象のLINEグループに招待しよう'**
  String get inviteOfficialAccountTitle;

  /// No description provided for @inviteOfficialAccountDesc1.
  ///
  /// In ja, this message translates to:
  /// **'「集金くん」が参加しているLINEグループのみ、\nメンバーを取得することができます。\nLINEグループが表示されない場合には、\n一度「集金くん公式LINE」を退出させたのちに\n再度同じグループに追加してください。'**
  String get inviteOfficialAccountDesc1;

  /// No description provided for @inviteOfficialAccountStep1.
  ///
  /// In ja, this message translates to:
  /// **'LINE公式アカウントを追加'**
  String get inviteOfficialAccountStep1;

  /// No description provided for @inviteOfficialAccountStep2.
  ///
  /// In ja, this message translates to:
  /// **'LINE公式アカウントを\n集金対象のグループに招待'**
  String get inviteOfficialAccountStep2;

  /// No description provided for @inviteOfficialAccountNote1.
  ///
  /// In ja, this message translates to:
  /// **'「集金くん」がグループ内で\n宣伝メッセージ等を送ることはありません。'**
  String get inviteOfficialAccountNote1;

  /// No description provided for @inviteOfficialAccountNote2.
  ///
  /// In ja, this message translates to:
  /// **'Appleを利用してログインしている場合は、\n一度ログアウトした後に、LINEログインを利用してください'**
  String get inviteOfficialAccountNote2;

  /// No description provided for @group.
  ///
  /// In ja, this message translates to:
  /// **'グループ'**
  String get group;

  /// No description provided for @selectLineGroupDesc2.
  ///
  /// In ja, this message translates to:
  /// **'このメンバーでイベントを作成しますか？'**
  String get selectLineGroupDesc2;

  /// No description provided for @selectLineGroupButton.
  ///
  /// In ja, this message translates to:
  /// **'このメンバーでイベント作成'**
  String get selectLineGroupButton;

  /// No description provided for @selectLineGroupNote.
  ///
  /// In ja, this message translates to:
  /// **'※LINEグループから取得したメンバー情報は24時間で消去されるため、\n24時間が経過する前に再取得をするようお願いいたします。\n再取得の際、支払い状況は引き継がれます。'**
  String get selectLineGroupNote;

  /// No description provided for @autoDeleteMemberCountdown.
  ///
  /// In ja, this message translates to:
  /// **'メンバー自動削除まで '**
  String get autoDeleteMemberCountdown;

  /// No description provided for @memberDeletedAfter24h.
  ///
  /// In ja, this message translates to:
  /// **'24時間が経過したため\nメンバー情報が削除されました'**
  String get memberDeletedAfter24h;

  /// No description provided for @bulkEdit.
  ///
  /// In ja, this message translates to:
  /// **'一括編集'**
  String get bulkEdit;

  /// No description provided for @bulkStatusChange.
  ///
  /// In ja, this message translates to:
  /// **'ステータス変更'**
  String get bulkStatusChange;

  /// No description provided for @bulkSelectionCount.
  ///
  /// In ja, this message translates to:
  /// **'選択中: {count}人'**
  String bulkSelectionCount(int count);

  /// No description provided for @bulkDeleteConfirm.
  ///
  /// In ja, this message translates to:
  /// **'選択した{count}人を削除しますか？'**
  String bulkDeleteConfirm(int count);

  /// No description provided for @duplicateMemberWarningTitle.
  ///
  /// In ja, this message translates to:
  /// **'同じ名前のメンバーがいます'**
  String get duplicateMemberWarningTitle;

  /// No description provided for @duplicateMemberWarningMessage.
  ///
  /// In ja, this message translates to:
  /// **'次のメンバーが重複しています: {names}'**
  String duplicateMemberWarningMessage(Object names);

  /// No description provided for @lineGroupExpireTitle.
  ///
  /// In ja, this message translates to:
  /// **'メンバー情報有効期限が\nもうすぐ切れます'**
  String get lineGroupExpireTitle;

  /// No description provided for @lineGroupExpireDesc.
  ///
  /// In ja, this message translates to:
  /// **'LINEの利用規約に則り、メンバー情報有効期限を過ぎると、メンバーと支払い状況の情報が削除されます。\n再取得をし、有効期限をリセットしてください。'**
  String get lineGroupExpireDesc;

  /// No description provided for @doNotRefresh.
  ///
  /// In ja, this message translates to:
  /// **'取得しない'**
  String get doNotRefresh;

  /// No description provided for @refresh.
  ///
  /// In ja, this message translates to:
  /// **'再取得'**
  String get refresh;

  /// No description provided for @note.
  ///
  /// In ja, this message translates to:
  /// **'memo'**
  String get note;

  /// No description provided for @editNote.
  ///
  /// In ja, this message translates to:
  /// **'メモの編集'**
  String get editNote;

  /// No description provided for @memoPlaceholder.
  ///
  /// In ja, this message translates to:
  /// **'メモを入力できます'**
  String get memoPlaceholder;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @lineNotConnectedMessage1.
  ///
  /// In ja, this message translates to:
  /// **'イベントとLINEグループを連携し、\n催促メッセージを自動送信しよう！'**
  String get lineNotConnectedMessage1;

  /// No description provided for @lineNotConnectedMessage2.
  ///
  /// In ja, this message translates to:
  /// **'『LINEグループから追加』を使用すると、\nイベントとLINEグループを連携できます！'**
  String get lineNotConnectedMessage2;

  /// No description provided for @sendMessage.
  ///
  /// In ja, this message translates to:
  /// **'催促メッセージの送信'**
  String get sendMessage;

  /// No description provided for @sendPayPayLink.
  ///
  /// In ja, this message translates to:
  /// **'PayPayリンクの送付'**
  String get sendPayPayLink;

  /// No description provided for @send.
  ///
  /// In ja, this message translates to:
  /// **'送信'**
  String get send;

  /// No description provided for @sendConfirmation.
  ///
  /// In ja, this message translates to:
  /// **'送信確認'**
  String get sendConfirmation;

  /// No description provided for @completeSending.
  ///
  /// In ja, this message translates to:
  /// **'送信完了'**
  String get completeSending;

  /// No description provided for @loadingApologizeMessage.
  ///
  /// In ja, this message translates to:
  /// **'読み込みに10~20秒ほどかかる場合があります。\n次回アップデートで改善予定です。'**
  String get loadingApologizeMessage;

  /// No description provided for @remainingHour.
  ///
  /// In ja, this message translates to:
  /// **'時間'**
  String get remainingHour;

  /// No description provided for @remainingMinute.
  ///
  /// In ja, this message translates to:
  /// **'分'**
  String get remainingMinute;

  /// No description provided for @cannotreflesh.
  ///
  /// In ja, this message translates to:
  /// **'前回のメンバー情報更新から\n24時間以上経過しているため、\n再取得できません。'**
  String get cannotreflesh;

  /// No description provided for @upgradeTitle.
  ///
  /// In ja, this message translates to:
  /// **'新しいバージョンがあります'**
  String get upgradeTitle;

  /// No description provided for @notNow.
  ///
  /// In ja, this message translates to:
  /// **'今はしない'**
  String get notNow;

  /// No description provided for @update.
  ///
  /// In ja, this message translates to:
  /// **'アップデート'**
  String get update;

  /// No description provided for @updateDescription.
  ///
  /// In ja, this message translates to:
  /// **'アップデートをすると'**
  String get updateDescription;

  /// No description provided for @newFeatures.
  ///
  /// In ja, this message translates to:
  /// **'以下の新機能が使えるようになります'**
  String get newFeatures;

  /// No description provided for @changeThemeColor.
  ///
  /// In ja, this message translates to:
  /// **'テーマカラーの変更'**
  String get changeThemeColor;

  /// No description provided for @removeAds.
  ///
  /// In ja, this message translates to:
  /// **'広告を削除する'**
  String get removeAds;

  /// No description provided for @supportDeveloper.
  ///
  /// In ja, this message translates to:
  /// **'開発者に支援をする'**
  String get supportDeveloper;

  /// No description provided for @close.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get close;

  /// No description provided for @registerEvent.
  ///
  /// In ja, this message translates to:
  /// **'集金管理するイベントを'**
  String get registerEvent;

  /// No description provided for @tryRegistering.
  ///
  /// In ja, this message translates to:
  /// **'登録してみよう'**
  String get tryRegistering;

  /// No description provided for @eventExample.
  ///
  /// In ja, this message translates to:
  /// **'例) 飲み会、カラオケ、旅行 etc...'**
  String get eventExample;

  /// No description provided for @addEventButton.
  ///
  /// In ja, this message translates to:
  /// **'イベントを追加'**
  String get addEventButton;

  /// No description provided for @roundUp.
  ///
  /// In ja, this message translates to:
  /// **'端数切り上げ'**
  String get roundUp;

  /// No description provided for @change.
  ///
  /// In ja, this message translates to:
  /// **'お釣り'**
  String get change;

  /// No description provided for @shareCollectionStatus.
  ///
  /// In ja, this message translates to:
  /// **'集金状況の共有'**
  String get shareCollectionStatus;

  /// No description provided for @anonymousCard.
  ///
  /// In ja, this message translates to:
  /// **'匿名カード '**
  String get anonymousCard;

  /// No description provided for @memberNamesNotShared.
  ///
  /// In ja, this message translates to:
  /// **'メンバーの名前は共有されません'**
  String get memberNamesNotShared;

  /// No description provided for @tapCardToShare.
  ///
  /// In ja, this message translates to:
  /// **'カードをタップして共有'**
  String get tapCardToShare;

  /// No description provided for @card.
  ///
  /// In ja, this message translates to:
  /// **'カード '**
  String get card;

  /// No description provided for @memberNamesAndStatusShared.
  ///
  /// In ja, this message translates to:
  /// **'メンバーの名前と集金状況も共有されます'**
  String get memberNamesAndStatusShared;

  /// No description provided for @sharePayPayLink.
  ///
  /// In ja, this message translates to:
  /// **'PayPayリンクも一緒に共有する'**
  String get sharePayPayLink;

  /// No description provided for @imageCreationFailed.
  ///
  /// In ja, this message translates to:
  /// **'画像の作成に失敗しました'**
  String get imageCreationFailed;

  /// No description provided for @sharePaymentRequest.
  ///
  /// In ja, this message translates to:
  /// **'お支払いをお願いいたします。PayPayリンク：'**
  String get sharePaymentRequest;

  /// No description provided for @memberCount.
  ///
  /// In ja, this message translates to:
  /// **'メンバー数：'**
  String get memberCount;

  /// No description provided for @personUnit.
  ///
  /// In ja, this message translates to:
  /// **'人'**
  String get personUnit;

  /// No description provided for @totalAmount.
  ///
  /// In ja, this message translates to:
  /// **'合計金額：'**
  String get totalAmount;

  /// No description provided for @collectionRate.
  ///
  /// In ja, this message translates to:
  /// **'回収率'**
  String get collectionRate;

  /// No description provided for @memberDetail.
  ///
  /// In ja, this message translates to:
  /// **'メンバー詳細'**
  String get memberDetail;

  /// No description provided for @errorTitle.
  ///
  /// In ja, this message translates to:
  /// **'エラー'**
  String get errorTitle;

  /// No description provided for @addOneMemberError.
  ///
  /// In ja, this message translates to:
  /// **'イベントにメンバーを一人以上追加してください。'**
  String get addOneMemberError;

  /// No description provided for @signInFailed.
  ///
  /// In ja, this message translates to:
  /// **'サインインに失敗しました'**
  String get signInFailed;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In ja, this message translates to:
  /// **'お手数ですが、再度お試しください'**
  String get pleaseTryAgain;

  /// No description provided for @sendFailed.
  ///
  /// In ja, this message translates to:
  /// **'送信に失敗しました'**
  String get sendFailed;

  /// No description provided for @pleaseTryAgainShort.
  ///
  /// In ja, this message translates to:
  /// **'お手数ですが再度お試しください'**
  String get pleaseTryAgainShort;

  /// No description provided for @purchaseError.
  ///
  /// In ja, this message translates to:
  /// **'購入処理でエラーが発生しました。'**
  String get purchaseError;

  /// No description provided for @purchaseCancelledOrFailed.
  ///
  /// In ja, this message translates to:
  /// **'購入がキャンセルまたは失敗しました。'**
  String get purchaseCancelledOrFailed;

  /// No description provided for @purchaseUnavailable.
  ///
  /// In ja, this message translates to:
  /// **'現在購入を利用できません。'**
  String get purchaseUnavailable;

  /// No description provided for @productNotFound.
  ///
  /// In ja, this message translates to:
  /// **'商品情報が見つかりませんでした。'**
  String get productNotFound;

  /// No description provided for @purchaseStartFailed.
  ///
  /// In ja, this message translates to:
  /// **'購入処理を開始できませんでした。'**
  String get purchaseStartFailed;

  /// No description provided for @purchaseFailed.
  ///
  /// In ja, this message translates to:
  /// **'購入に失敗しました。'**
  String get purchaseFailed;

  /// No description provided for @productQueryFailed.
  ///
  /// In ja, this message translates to:
  /// **'商品情報の取得に失敗しました。'**
  String get productQueryFailed;

  /// No description provided for @purchasePrepareFailed.
  ///
  /// In ja, this message translates to:
  /// **'購入の準備に失敗しました。'**
  String get purchasePrepareFailed;

  /// No description provided for @purchaseCancelled.
  ///
  /// In ja, this message translates to:
  /// **'購入がキャンセルされました。'**
  String get purchaseCancelled;

  /// No description provided for @restoreFailed.
  ///
  /// In ja, this message translates to:
  /// **'購入の復元に失敗しました。'**
  String get restoreFailed;

  /// No description provided for @noRestorablePurchase.
  ///
  /// In ja, this message translates to:
  /// **'復元できる購入が見つかりませんでした。'**
  String get noRestorablePurchase;

  /// No description provided for @removeAdsDescription.
  ///
  /// In ja, this message translates to:
  /// **'全ての広告を永久に削除します。\n※ 金額設定で端数切り上げをすればすぐ元が取れます。'**
  String get removeAdsDescription;

  /// No description provided for @removeAdsPriceLabel.
  ///
  /// In ja, this message translates to:
  /// **'¥300 買い切り'**
  String get removeAdsPriceLabel;

  /// No description provided for @purchase.
  ///
  /// In ja, this message translates to:
  /// **'購入'**
  String get purchase;

  /// No description provided for @restorePurchase.
  ///
  /// In ja, this message translates to:
  /// **'購入を復元する'**
  String get restorePurchase;

  /// No description provided for @adsAlreadyRemoved.
  ///
  /// In ja, this message translates to:
  /// **'すでに広告は削除済みです。'**
  String get adsAlreadyRemoved;

  /// No description provided for @modifyMemberRole.
  ///
  /// In ja, this message translates to:
  /// **'{name}の役割を修正'**
  String modifyMemberRole(Object name);

  /// No description provided for @noRoleOption.
  ///
  /// In ja, this message translates to:
  /// **'役割なし'**
  String get noRoleOption;

  /// No description provided for @questionnaireDesc1.
  ///
  /// In ja, this message translates to:
  /// **'【集金くん】に追加してほしい\n機能があれば\nぜひご意見ください！'**
  String get questionnaireDesc1;

  /// No description provided for @questionnaireDesc2.
  ///
  /// In ja, this message translates to:
  /// **'匿名で提出できます。'**
  String get questionnaireDesc2;

  /// No description provided for @questionnaireDesc3.
  ///
  /// In ja, this message translates to:
  /// **'今後のアップデートの\n参考にさせていただきます。'**
  String get questionnaireDesc3;

  /// No description provided for @termsPrivacyUpdated.
  ///
  /// In ja, this message translates to:
  /// **'利用規約・プライバシーポリシーを\n一部変更しました'**
  String get termsPrivacyUpdated;

  /// No description provided for @termsPrivacyPrefix.
  ///
  /// In ja, this message translates to:
  /// **'コンテンツ利用に当たっては、\n本'**
  String get termsPrivacyPrefix;

  /// No description provided for @termsPrivacySuffix2.
  ///
  /// In ja, this message translates to:
  /// **'\n双方に同意したものとみなします。'**
  String get termsPrivacySuffix2;

  /// No description provided for @createFromLineGroup.
  ///
  /// In ja, this message translates to:
  /// **'LINEグループから作成'**
  String get createFromLineGroup;

  /// No description provided for @addEventFromLineDesc.
  ///
  /// In ja, this message translates to:
  /// **'「LINEグループから作成」をすると、\n自動でグループのメンバーを追加し、\nグループにメッセージを送信できます。'**
  String get addEventFromLineDesc;

  /// No description provided for @transferFromOtherEvent.
  ///
  /// In ja, this message translates to:
  /// **'他のイベントからメンバー引継ぎ'**
  String get transferFromOtherEvent;

  /// No description provided for @createEmptyEvent.
  ///
  /// In ja, this message translates to:
  /// **'空のイベントを作成'**
  String get createEmptyEvent;

  /// No description provided for @themeColor.
  ///
  /// In ja, this message translates to:
  /// **'テーマカラー'**
  String get themeColor;

  /// No description provided for @roleName.
  ///
  /// In ja, this message translates to:
  /// **'役割名'**
  String get roleName;

  /// No description provided for @changeCount.
  ///
  /// In ja, this message translates to:
  /// **'変更({count})'**
  String changeCount(int count);

  /// No description provided for @changeButton.
  ///
  /// In ja, this message translates to:
  /// **'変更'**
  String get changeButton;

  /// No description provided for @themeColorDefault.
  ///
  /// In ja, this message translates to:
  /// **'デフォルト'**
  String get themeColorDefault;

  /// No description provided for @themeColorSakura.
  ///
  /// In ja, this message translates to:
  /// **'サクラ'**
  String get themeColorSakura;

  /// No description provided for @themeColorAjisai.
  ///
  /// In ja, this message translates to:
  /// **'アジサイ'**
  String get themeColorAjisai;

  /// No description provided for @themeColorIchou.
  ///
  /// In ja, this message translates to:
  /// **'イチョウ'**
  String get themeColorIchou;

  /// No description provided for @donationTitle.
  ///
  /// In ja, this message translates to:
  /// **'開発者にドリンク１杯をご馳走する'**
  String get donationTitle;

  /// No description provided for @donationDescription.
  ///
  /// In ja, this message translates to:
  /// **'「集金くん」は学生エンジニアによって\n{deficit}開発されています。\nよりよい機能を継続的に届けられるよう、\nご支援いただけると幸いです。'**
  String donationDescription(Object deficit);

  /// No description provided for @deficit.
  ///
  /// In ja, this message translates to:
  /// **'赤字'**
  String get deficit;

  /// No description provided for @donationCoffeeName.
  ///
  /// In ja, this message translates to:
  /// **'カフェモカ'**
  String get donationCoffeeName;

  /// No description provided for @donationFrappeName.
  ///
  /// In ja, this message translates to:
  /// **'抹茶フラッペ'**
  String get donationFrappeName;

  /// No description provided for @donationSweetsName.
  ///
  /// In ja, this message translates to:
  /// **'スイーツセット'**
  String get donationSweetsName;

  /// No description provided for @donationThanksTitle.
  ///
  /// In ja, this message translates to:
  /// **'ご支援ありがとうございます！'**
  String get donationThanksTitle;

  /// No description provided for @donationThanksSmall1.
  ///
  /// In ja, this message translates to:
  /// **'ごちそうさまです！'**
  String get donationThanksSmall1;

  /// No description provided for @donationThanksSmall2.
  ///
  /// In ja, this message translates to:
  /// **'カフェモカでほっと一息ついて、'**
  String get donationThanksSmall2;

  /// No description provided for @donationThanksSmall3.
  ///
  /// In ja, this message translates to:
  /// **'また開発がんばります！'**
  String get donationThanksSmall3;

  /// No description provided for @donationThanksSmall4.
  ///
  /// In ja, this message translates to:
  /// **'応援してくれてありがとう🙌'**
  String get donationThanksSmall4;

  /// No description provided for @donationThanksMedium2.
  ///
  /// In ja, this message translates to:
  /// **'抹茶フラッペでリフレッシュして、'**
  String get donationThanksMedium2;

  /// No description provided for @donationThanksMedium3.
  ///
  /// In ja, this message translates to:
  /// **'次のアイデアにつなげます！'**
  String get donationThanksMedium3;

  /// No description provided for @donationThanksLarge1.
  ///
  /// In ja, this message translates to:
  /// **'ドーナツで当分補給ばっちり！'**
  String get donationThanksLarge1;

  /// No description provided for @donationThanksLarge2.
  ///
  /// In ja, this message translates to:
  /// **'集中モードに入ります！'**
  String get donationThanksLarge2;

  /// No description provided for @paypayLinkTitle.
  ///
  /// In ja, this message translates to:
  /// **'PayPayリンクとは？'**
  String get paypayLinkTitle;

  /// No description provided for @paypayLinkDesc.
  ///
  /// In ja, this message translates to:
  /// **'PayPayアプリで自分に送金してもらうためのリンクです。\n「集金くん」に登録しておくと、LINEで催促メッセージを送る際に、そのリンクから支払いをお願いできます。'**
  String get paypayLinkDesc;

  /// No description provided for @paypayLinkQ1.
  ///
  /// In ja, this message translates to:
  /// **'Q. PayPayリンクはどうやって取得するの？'**
  String get paypayLinkQ1;

  /// No description provided for @paypayLinkA1.
  ///
  /// In ja, this message translates to:
  /// **'A. PayPayアプリの「アカウント」→「マイコード」からコピーできます。'**
  String get paypayLinkA1;

  /// No description provided for @paypayLinkQ2.
  ///
  /// In ja, this message translates to:
  /// **'Q. PayPayリンクを登録すれば、自動で支払い状況が反映される？'**
  String get paypayLinkQ2;

  /// No description provided for @paypayLinkA2.
  ///
  /// In ja, this message translates to:
  /// **'A. いいえ。PayPayの仕様上、自動反映はできません。'**
  String get paypayLinkA2;

  /// No description provided for @paypayStatusTitle.
  ///
  /// In ja, this message translates to:
  /// **'「PayPayで支払い済み」とは？'**
  String get paypayStatusTitle;

  /// No description provided for @paypayStatusDesc.
  ///
  /// In ja, this message translates to:
  /// **'PayPayで受け取った支払いを管理しやすくするためのステータスです。\n現金で受け取った場合と区別して記録できます。'**
  String get paypayStatusDesc;

  /// No description provided for @paypayStatusQ.
  ///
  /// In ja, this message translates to:
  /// **'Q. PayPayで支払ったら、自動で反映されますか？'**
  String get paypayStatusQ;

  /// No description provided for @paypayStatusA.
  ///
  /// In ja, this message translates to:
  /// **'A. いいえ。PayPayの仕組み上、自動反映はできません。\nPayPayで受け取ったことを確認したら、手動で「PayPayで支払い済み」を選んでください。'**
  String get paypayStatusA;

  /// No description provided for @updateAnnouncement.
  ///
  /// In ja, this message translates to:
  /// **'アップデートのお知らせ🎉'**
  String get updateAnnouncement;

  /// No description provided for @updateShareFeature.
  ///
  /// In ja, this message translates to:
  /// **'集金状況の共有機能を実装！'**
  String get updateShareFeature;

  /// No description provided for @updateRoundUpFeature.
  ///
  /// In ja, this message translates to:
  /// **'金額設定時に端数を切り上げる機能'**
  String get updateRoundUpFeature;

  /// No description provided for @updateBulkEditFeature.
  ///
  /// In ja, this message translates to:
  /// **'一括編集機能を実装'**
  String get updateBulkEditFeature;

  /// No description provided for @updateFeedbackMessage.
  ///
  /// In ja, this message translates to:
  /// **'ご意見・ご要望はアンケートからいつでも\nお気軽にお寄せください📮'**
  String get updateFeedbackMessage;

  /// No description provided for @suggestOfficialLineTitle.
  ///
  /// In ja, this message translates to:
  /// **'LINE公式アカウントを追加して\n集金くんを便利にしませんか？'**
  String get suggestOfficialLineTitle;

  /// No description provided for @suggestOfficialLineDesc.
  ///
  /// In ja, this message translates to:
  /// **'おかげさまで、LINE公式アカウントが認証され、\nLINEと連携した超便利機能が使えるようになりました！'**
  String get suggestOfficialLineDesc;

  /// No description provided for @suggestOfficialLineAction.
  ///
  /// In ja, this message translates to:
  /// **'公式LINEをグループに追加すると...'**
  String get suggestOfficialLineAction;

  /// No description provided for @bulkAddMembers.
  ///
  /// In ja, this message translates to:
  /// **'メンバーを一括追加'**
  String get bulkAddMembers;

  /// No description provided for @autoSendGroupMessage.
  ///
  /// In ja, this message translates to:
  /// **'グループにメッセージを自動送信'**
  String get autoSendGroupMessage;

  /// No description provided for @addMemberFailed.
  ///
  /// In ja, this message translates to:
  /// **'メンバーの追加に失敗しました'**
  String get addMemberFailed;

  /// No description provided for @releaseNotesEmpty.
  ///
  /// In ja, this message translates to:
  /// **'リリースノートなし'**
  String get releaseNotesEmpty;

  /// No description provided for @roleBasedSplit.
  ///
  /// In ja, this message translates to:
  /// **'役割別で割り勘'**
  String get roleBasedSplit;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'ja':
      return SJa();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
