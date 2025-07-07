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

  /// No description provided for @paymentStatus.
  ///
  /// In ja, this message translates to:
  /// **'支払い状況'**
  String get paymentStatus;

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

  /// No description provided for @person.
  ///
  /// In ja, this message translates to:
  /// **'人'**
  String get person;

  /// No description provided for @settlePayment.
  ///
  /// In ja, this message translates to:
  /// **'精 算'**
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
  /// **'PayPayリンクを入力してください。'**
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
  /// **'目安箱'**
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
  /// **'「集金くん」にあったらいいなと思う機能があれば、ご意見いただけると幸いです。'**
  String get questionnaireDescription;

  /// No description provided for @feedbackThanks.
  ///
  /// In ja, this message translates to:
  /// **'今後のアップデートの参考にさせていただきます。'**
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
  /// **'決定'**
  String get confirm;

  /// No description provided for @addEvent.
  ///
  /// In ja, this message translates to:
  /// **'イベント追加'**
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
  /// **'LINEグループから追加'**
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
  /// **'このメンバーを引継ぎますか？'**
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
  /// **'メンバー自動削除まで'**
  String get autoDeleteMemberCountdown;

  /// No description provided for @memberDeletedAfter24h.
  ///
  /// In ja, this message translates to:
  /// **'24時間が経過したためメンバー情報が削除されました'**
  String get memberDeletedAfter24h;

  /// No description provided for @lineGroupExpireTitle.
  ///
  /// In ja, this message translates to:
  /// **'メンバー情報有効期限が\nもうすぐ切れます'**
  String get lineGroupExpireTitle;

  /// No description provided for @lineGroupExpireDesc.
  ///
  /// In ja, this message translates to:
  /// **'LINEの利用規約に則り、メンバー情報有効期限を過ぎる\nと、メンバーと支払い状況の情報が削除されます。\n再取得をし、有効期限をリセットしてください。'**
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
