import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/src/sk2_pigeon.g.dart' as iap_storekit;
import 'package:mr_collection/provider/ads_removal_provider.dart';
import 'package:mr_collection/ui/components/dialog/ads/remove_ads_dialog.dart';
import 'package:mr_collection/ui/components/dialog/ads/remove_ads_thanks_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// iOS に固定することで InAppPurchaseAndroidPlatform の BillingClientManager が
// startConnection を呼び出して pumpAndSettle を無限ループさせる問題を防ぐ。
// try/finally で必ずリセットするため testWidgets が戻る前（_verifyInvariants 前）に null に戻る。
// setUp 内の addTearDown は _verifyInvariants より後に実行されるため、
// ラッパー方式で test 本体内にリセットを入れる必要がある。
Future<void> Function(WidgetTester) withIos(
  Future<void> Function(WidgetTester) callback,
) =>
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await callback(tester);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    };

// StoreKit2 (InAppPurchase2API) pigeon チャンネルをモックする。
// canMakePayments → false: isAvailable() が即時 false を返し _initializeStore を早期終了させる。
// restorePurchases → void: restorePurchases() を即時完了させる
//                          (購入なしのため _restoreCompleter は 3 秒タイムアウトで完了する)。
const _sk2CanMakePaymentsChannel =
    'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.canMakePayments';
const _sk2RestorePurchasesChannel =
    'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.restorePurchases';

void _setupStoreKitMock() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  // canMakePayments → false (isAvailable()=false → _initializeStore が早期 return)
  messenger.setMockMessageHandler(
    _sk2CanMakePaymentsChannel,
    (message) async => iap_storekit.InAppPurchase2API.pigeonChannelCodec
        .encodeMessage(<Object?>[false]),
  );
  // restorePurchases → void (即時完了、3 秒後にタイムアウト)
  messenger.setMockMessageHandler(
    _sk2RestorePurchasesChannel,
    (message) async => iap_storekit.InAppPurchase2API.pigeonChannelCodec
        .encodeMessage(<Object?>[null]),
  );
}

void _teardownStoreKitMock() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMessageHandler(_sk2CanMakePaymentsChannel, null);
  messenger.setMockMessageHandler(_sk2RestorePurchasesChannel, null);
}

Widget buildDialogWidget() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: RemoveAdsDialog(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _setupStoreKitMock();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    _teardownStoreKitMock();
  });

  group('RemoveAdsDialog - 表示', () {
    testWidgets('説明テキストが表示される', withIos((tester) async {
      await tester.pumpWidget(buildDialogWidget());

      expect(
        find.text(
            '300円で広告を永久に削除できます！\n(端数繰り上げ機能を使えば簡単に元が取れます。)'),
        findsOneWidget,
      );
    }));

    testWidgets('"広告を削除" ボタンと "購入を復元" ボタンが表示される', withIos((tester) async {
      await tester.pumpWidget(buildDialogWidget());

      expect(find.text('広告を削除'), findsOneWidget);
      expect(find.text('購入を復元'), findsOneWidget);
    }));

    testWidgets('初期表示でローディングインジケーターが表示される (_isLoading=true)',
        withIos((tester) async {
      await tester.pumpWidget(buildDialogWidget());
      // 非同期 _initializeStore が完了する前の状態を確認
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    }));

    testWidgets('ストア初期化完了後にローディングインジケーターが消える', withIos((tester) async {
      await tester.pumpWidget(buildDialogWidget());
      // pumpAndSettle は SnackBar アニメーションで無限ループするため pump + Duration を使用。
      // _initializeStore の非同期チェーン（チャンネル呼び出し含む）が完了するのに十分な時間を進める。
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    }));
  });

  group('RemoveAdsDialog - 購入を復元', () {
    testWidgets('タイムアウト後にスナックバーが表示される', withIos((tester) async {
      await tester.pumpWidget(buildDialogWidget());
      // _initializeStore の完了を待つ。SnackBar アニメーションを避けるため Duration 指定。
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('購入を復元'));
      await tester.pump(); // タップ処理 (_isProcessing = true, チャンネル呼び出し開始)
      await tester.pump(); // restorePurchases チャンネル応答処理、タイムアウトタイマー登録

      // 3秒タイムアウトを超える時間を進める
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(); // タイムアウト後の setState 処理

      // 購入なし or 復元失敗のスナックバーが表示される
      expect(find.byType(SnackBar), findsAtLeastNWidgets(1));
    }));

    testWidgets('タイムアウト後に _isProcessing が false に戻りボタンが再度有効になる',
        withIos((tester) async {
      await tester.pumpWidget(buildDialogWidget());
      await tester.pump(const Duration(seconds: 1)); // init complete

      await tester.tap(find.text('購入を復元'));
      await tester.pump(); // タップ処理 (_isProcessing = true)

      // 処理中はボタンが無効
      final processingButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, '購入を復元'),
      );
      expect(processingButton.onPressed, isNull);

      await tester.pump(); // restorePurchases チャンネル応答処理、タイムアウトタイマー登録

      // タイムアウト後にボタンが再び有効
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(); // タイムアウト後の setState 処理

      final restoredButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, '購入を復元'),
      );
      expect(restoredButton.onPressed, isNotNull);
    }));
  });

  group('RemoveAdsDialog - adsRemovalProvider との連携 (ドロワーのタップロジック)', () {
    // ドロワーのタップは ref.read(adsRemovalProvider) に基づいてダイアログを選択する。
    // この挙動を Consumer ウィジェットで再現して検証する。
    // pumpAndSettle は IAP バックグラウンドタイマーで無限ループする可能性があるため、
    // プロバイダーのロード待ちには pump + Duration を使用する。

    testWidgets('adsRemovalProvider が true のとき RemoveAdsThanksDialog を表示する',
        withIos((tester) async {
      // キャッシュで広告削除済み状態を設定
      SharedPreferences.setMockInitialValues({'ads_removed': true});

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  // ref.watch でプロバイダーをビルド時に購読し、
                  // _loadFromPrefs が完了して true になるまで再ビルドさせる。
                  // これにより tap 前に AdsRemovalNotifier が初期化される。
                  ref.watch(adsRemovalProvider);
                  return ElevatedButton(
                    onPressed: () {
                      // ドロワーのタップロジックを再現
                      final isAdsRemoved = ref.read(adsRemovalProvider);
                      showDialog<void>(
                        context: context,
                        builder: (_) => isAdsRemoved
                            ? const RemoveAdsThanksDialog()
                            : const RemoveAdsDialog(),
                      );
                    },
                    child: const Text('open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // _loadFromPrefs が完了して adsRemovalProvider が true になるまで待つ。
      // pump を複数回呼んでマイクロタスクと再ビルドを処理する。
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(RemoveAdsThanksDialog), findsOneWidget);
      expect(find.byType(RemoveAdsDialog), findsNothing);
    }));

    testWidgets('adsRemovalProvider が false のとき RemoveAdsDialog を表示する',
        withIos((tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  ref.watch(adsRemovalProvider);
                  return ElevatedButton(
                    onPressed: () {
                      final isAdsRemoved = ref.read(adsRemovalProvider);
                      showDialog<void>(
                        context: context,
                        builder: (_) => isAdsRemoved
                            ? const RemoveAdsThanksDialog()
                            : const RemoveAdsDialog(),
                      );
                    },
                    child: const Text('open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(RemoveAdsDialog), findsOneWidget);
      expect(find.byType(RemoveAdsThanksDialog), findsNothing);
    }));
  });
}
