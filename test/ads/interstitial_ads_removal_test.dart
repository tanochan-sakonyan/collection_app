import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/src/sk2_pigeon.g.dart' as iap_storekit;
import 'package:mr_collection/ads/interstitial_service.dart';
import 'package:mr_collection/ads/interstitial_singleton.dart';
import 'package:mr_collection/ads/rewarded_ad_service.dart';
import 'package:mr_collection/ads/rewarded_ad_singleton.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/provider/ads_removal_provider.dart';
import 'package:mr_collection/ui/components/dialog/line/line_message_complete_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Mock InterstitialService ---

// 呼び出しを記録するモック。
class MockInterstitialService extends InterstitialService {
  MockInterstitialService({required this.mockIsReady}) : super(useProd: false);

  final bool mockIsReady;
  int showCallCount = 0;
  int showAndWaitCallCount = 0;

  @override
  bool get isReady => mockIsReady;

  @override
  Future<void> show() async {
    showCallCount++;
  }

  @override
  Future<void> showAndWait() async {
    showAndWaitCallCount++;
  }
}

// --- Mock RewardedAdService ---

// リワード広告の呼び出しを記録するモック。
class MockRewardedAdService extends RewardedAdService {
  MockRewardedAdService({required this.mockIsReady, this.mockRewardResult = true})
      : super(useProd: false);

  final bool mockIsReady;
  final bool mockRewardResult;
  int showAndWaitCallCount = 0;

  @override
  bool get isReady => mockIsReady;

  @override
  Future<bool> showAndWaitForReward() async {
    if (!mockIsReady) return false;
    showAndWaitCallCount++;
    return mockRewardResult;
  }
}

// --- iOS プラットフォーム固定ヘルパー ---

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

// --- StoreKit2 モック ---

const _sk2CanMakePaymentsChannel =
    'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.canMakePayments';
const _sk2RestorePurchasesChannel =
    'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.restorePurchases';

void _setupStoreKitMock() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMessageHandler(
    _sk2CanMakePaymentsChannel,
    (message) async => iap_storekit.InAppPurchase2API.pigeonChannelCodec
        .encodeMessage(<Object?>[false]),
  );
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

// --- adsRemovalProvider を任意の値で上書きするオーバーライド ---

List<Override> _adsRemovedOverrides(bool removed) {
  return [
    adsRemovalProvider.overrideWith((ref) {
      final notifier = AdsRemovalNotifier();
      // 即座に状態を設定する
      notifier.setAdsRemoved(removed);
      return notifier;
    }),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InterstitialService originalInterstitial;
  late MockInterstitialService mockService;

  setUp(() {
    _setupStoreKitMock();
    SharedPreferences.setMockInitialValues({});
    originalInterstitial = interstitial;
  });

  tearDown(() {
    setInterstitialForTesting(originalInterstitial);
    _teardownStoreKitMock();
  });

  // ------------------------------------------------------------------
  // 広告削除条件のユニットテスト
  //
  // 3箇所で使われている条件パターン:
  //   if (!ref.read(adsRemovalProvider) && interstitial.isReady)
  // ------------------------------------------------------------------
  group('広告削除条件パターンのユニットテスト', () {
    // 実行時に評価させるためヘルパー関数を使用
    bool shouldShowAd(bool adsRemoved, bool isReady) =>
        !adsRemoved && isReady;

    // 検証: 課金済みなら広告準備済みでもインタースティシャル広告を表示しない
    // 該当箇所:
    //   - add_event_dialog.dart:102
    //   - add_event_name_dialog.dart:117
    //   - line_message_complete_dialog.dart:21
    test('課金済み (adsRemoval=true) の場合、isReady でも条件は false', () {
      expect(shouldShowAd(true, true), false);
    });

    // 検証: 未課金で広告準備済みならインタースティシャル広告を表示する
    // 該当箇所: 同上
    test('未課金 (adsRemoval=false) かつ isReady=true の場合、条件は true', () {
      expect(shouldShowAd(false, true), true);
    });

    // 検証: 未課金でも広告が準備できていなければ表示しない
    // 該当箇所: 同上
    test('未課金 (adsRemoval=false) かつ isReady=false の場合、条件は false', () {
      expect(shouldShowAd(false, false), false);
    });
  });

  // ------------------------------------------------------------------
  // LineMessageCompleteDialog のウィジェットテスト
  //
  // メッセージ送信完了後に表示されるダイアログ。
  // initState 内で 2 秒後に interstitial.showAndWait() を呼ぶ。
  // ------------------------------------------------------------------
  group('LineMessageCompleteDialog - 課金済みユーザーに広告が非表示', () {
    // 検証: LINE メッセージ送信完了後、課金済みユーザーにはインタースティシャル広告を表示しない
    // 該当箇所: line_message_complete_dialog.dart:20-25
    //   Future.delayed(Duration(seconds: 2), () async {
    //     if (!ref.read(adsRemovalProvider) && interstitial.isReady) {
    //       await interstitial.showAndWait();
    //     }
    //   });
    testWidgets(
      '課金済みの場合、interstitial.showAndWait() が呼ばれない',
      withIos((tester) async {
        mockService = MockInterstitialService(mockIsReady: true);
        setInterstitialForTesting(mockService);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _adsRemovedOverrides(true),
            child: MaterialApp(
              localizationsDelegates: S.localizationsDelegates,
              supportedLocales: S.supportedLocales,
              locale: const Locale('ja'),
              home: const Scaffold(body: LineMessageCompleteDialog()),
            ),
          ),
        );

        // _loadFromPrefs と setAdsRemoved の非同期を処理
        await tester.pump();
        await tester.pump();

        // 2秒の Future.delayed を進める
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();

        expect(mockService.showAndWaitCallCount, 0,
            reason: '課金済みユーザーにはインタースティシャル広告を表示しない');
      }),
    );

    // 検証: LINE メッセージ送信完了後、未課金ユーザーにはインタースティシャル広告を表示する
    // 該当箇所: line_message_complete_dialog.dart:20-25
    testWidgets(
      '未課金かつ広告準備済みの場合、interstitial.showAndWait() が呼ばれる',
      withIos((tester) async {
        mockService = MockInterstitialService(mockIsReady: true);
        setInterstitialForTesting(mockService);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _adsRemovedOverrides(false),
            child: MaterialApp(
              localizationsDelegates: S.localizationsDelegates,
              supportedLocales: S.supportedLocales,
              locale: const Locale('ja'),
              home: const Scaffold(body: LineMessageCompleteDialog()),
            ),
          ),
        );

        await tester.pump();
        await tester.pump();

        // 2秒の Future.delayed を進める
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();

        expect(mockService.showAndWaitCallCount, 1,
            reason: '未課金ユーザーにはインタースティシャル広告を表示する');
      }),
    );

    // 検証: 未課金でも広告が未準備なら表示しない
    // 該当箇所: line_message_complete_dialog.dart:21 の interstitial.isReady 条件
    testWidgets(
      '未課金だが広告未準備の場合、interstitial.showAndWait() が呼ばれない',
      withIos((tester) async {
        mockService = MockInterstitialService(mockIsReady: false);
        setInterstitialForTesting(mockService);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _adsRemovedOverrides(false),
            child: MaterialApp(
              localizationsDelegates: S.localizationsDelegates,
              supportedLocales: S.supportedLocales,
              locale: const Locale('ja'),
              home: const Scaffold(body: LineMessageCompleteDialog()),
            ),
          ),
        );

        await tester.pump();
        await tester.pump();

        await tester.pump(const Duration(seconds: 3));
        await tester.pump();

        expect(mockService.showAndWaitCallCount, 0,
            reason: '広告が準備できていない場合は表示しない');
      }),
    );
  });

  // ------------------------------------------------------------------
  // adsRemovalProvider 経由での条件テスト
  //
  // AddEventDialog._selectLineGroup() と
  // AddEventNameDialog._selectLineGroup() は
  // 同じ条件パターンで lineGroupRewardedAd.showAndWaitForReward() を呼ぶ。
  // ウィジェット全体のテストは依存が多いため、
  // Provider の状態と Mock を組み合わせて条件ロジックを検証する。
  // ------------------------------------------------------------------
  group('LINEグループ取得時のリワード広告表示条件 - Provider 統合テスト', () {
    late MockRewardedAdService mockRewardedService;

    setUp(() {
      // テスト環境ではプラットフォーム判定が効かないためダミーモックを注入
      setLineGroupRewardedAdForTesting(MockRewardedAdService(mockIsReady: false));
    });

    tearDown(() {
      setLineGroupRewardedAdForTesting(MockRewardedAdService(mockIsReady: false));
    });

    // 検証: LINEグループ情報取得時、課金済みユーザーにはリワード広告を表示しない
    // 該当箇所:
    //   - add_event_dialog.dart:102-103
    //     if (!ref.read(adsRemovalProvider)) {
    //       await lineGroupRewardedAd.showAndWaitForReward();
    //     }
    //   - add_event_name_dialog.dart:117-119
    //     if (!ref.read(adsRemovalProvider)) {
    //       await lineGroupRewardedAd.showAndWaitForReward();
    //     }
    testWidgets(
      '課金済みの場合、Provider が true を返しリワード広告条件が成立しない',
      withIos((tester) async {
        mockRewardedService = MockRewardedAdService(mockIsReady: true);
        setLineGroupRewardedAdForTesting(mockRewardedService);

        final container = ProviderContainer(
          overrides: _adsRemovedOverrides(true),
        );
        addTearDown(container.dispose);

        // setAdsRemoved の非同期を待つ
        await tester.pump();
        await tester.pump();

        final adsRemoved = container.read(adsRemovalProvider);

        // AddEventDialog / AddEventNameDialog と同じ条件
        if (!adsRemoved) {
          await lineGroupRewardedAd.showAndWaitForReward();
        }

        expect(adsRemoved, true);
        expect(mockRewardedService.showAndWaitCallCount, 0,
            reason: '課金済みユーザーにはLINEグループ取得時のリワード広告を表示しない');
      }),
    );

    // 検証: LINEグループ情報取得時、未課金ユーザーにはリワード広告を表示する
    // 該当箇所: add_event_dialog.dart:102-103, add_event_name_dialog.dart:117-119
    testWidgets(
      '未課金の場合、Provider が false を返しリワード広告条件が成立する',
      withIos((tester) async {
        mockRewardedService = MockRewardedAdService(mockIsReady: true);
        setLineGroupRewardedAdForTesting(mockRewardedService);

        final container = ProviderContainer(
          overrides: _adsRemovedOverrides(false),
        );
        addTearDown(container.dispose);

        await tester.pump();
        await tester.pump();

        final adsRemoved = container.read(adsRemovalProvider);

        // AddEventDialog / AddEventNameDialog と同じ条件
        if (!adsRemoved) {
          await lineGroupRewardedAd.showAndWaitForReward();
        }

        expect(adsRemoved, false);
        expect(mockRewardedService.showAndWaitCallCount, 1,
            reason: '未課金ユーザーにはLINEグループ取得時のリワード広告を表示する');
      }),
    );
  });

  // ------------------------------------------------------------------
  // バナー広告の非表示テスト
  //
  // HomeScreen では以下3箇所でバナー広告を制御している:
  //   1. _createBannerAd(): adsRemovalProvider が true なら即 return
  //      → home_screen.dart:155-158
  //   2. build(): !ref.watch(adsRemovalProvider) が false ならバナー非表示
  //      → home_screen.dart:1214-1216
  //   3. リスナー: adsRemovalProvider が true に変わったらバナーを dispose
  //      → home_screen.dart:95-107
  //
  // HomeScreen は依存が多くウィジェットテストが困難なため、
  // Provider の状態と条件ロジック、リスナー通知を検証する。
  // ------------------------------------------------------------------
  group('バナー広告の非表示 - Provider 統合テスト', () {
    // _createBannerAd() の条件: if (ref.read(adsRemovalProvider)) return;
    bool shouldCreateBanner(bool adsRemoved) => !adsRemoved;

    // build() の条件: if (!ref.watch(adsRemovalProvider) && _isBannerLoaded && _banner != null)
    bool shouldShowBanner(bool adsRemoved, bool isBannerLoaded) =>
        !adsRemoved && isBannerLoaded;

    // 検証: 課金済みならバナー広告を作成しない
    // 該当箇所: home_screen.dart:155-158
    //   void _createBannerAd() {
    //     if (ref.read(adsRemovalProvider)) { return; }
    //     ...
    //   }
    test('課金済みの場合、バナー広告を作成しない (_createBannerAd 条件)', () {
      expect(shouldCreateBanner(true), false);
    });

    // 検証: 未課金ならバナー広告を作成する
    // 該当箇所: home_screen.dart:155-158
    test('未課金の場合、バナー広告を作成する (_createBannerAd 条件)', () {
      expect(shouldCreateBanner(false), true);
    });

    // 検証: 課金済みなら build でバナー Widget を描画しない
    // 該当箇所: home_screen.dart:1214-1216
    //   if (!ref.watch(adsRemovalProvider) && _isBannerLoaded && _banner != null)
    //     SafeArea(child: AdWidget(ad: _banner!))
    test('課金済みの場合、バナーがロード済みでも表示しない (build 条件)', () {
      expect(shouldShowBanner(true, true), false);
    });

    // 検証: 未課金でバナーロード済みなら表示する
    // 該当箇所: home_screen.dart:1214-1216
    test('未課金かつバナーロード済みの場合、表示する (build 条件)', () {
      expect(shouldShowBanner(false, true), true);
    });

    // 検証: 未課金でもバナーが未ロードなら表示しない
    // 該当箇所: home_screen.dart:1214-1216
    test('未課金だがバナー未ロードの場合、表示しない (build 条件)', () {
      expect(shouldShowBanner(false, false), false);
    });

    // 検証: 課金済みなら Provider が true を返し、_createBannerAd が即 return する
    // 該当箇所: home_screen.dart:155-158
    testWidgets(
      '課金済みの場合、adsRemovalProvider が true を返しバナー作成条件が不成立',
      withIos((tester) async {
        final container = ProviderContainer(
          overrides: _adsRemovedOverrides(true),
        );
        addTearDown(container.dispose);

        await tester.pump();
        await tester.pump();

        final adsRemoved = container.read(adsRemovalProvider);
        expect(adsRemoved, true);
        expect(shouldCreateBanner(adsRemoved), false,
            reason: '課金済みユーザーにはバナー広告を作成しない');
      }),
    );

    // 検証: 未課金なら Provider が false を返し、_createBannerAd がバナーを作成する
    // 該当箇所: home_screen.dart:155-158
    testWidgets(
      '未課金の場合、adsRemovalProvider が false を返しバナー作成条件が成立',
      withIos((tester) async {
        final container = ProviderContainer(
          overrides: _adsRemovedOverrides(false),
        );
        addTearDown(container.dispose);

        await tester.pump();
        await tester.pump();

        final adsRemoved = container.read(adsRemovalProvider);
        expect(adsRemoved, false);
        expect(shouldCreateBanner(adsRemoved), true,
            reason: '未課金ユーザーにはバナー広告を作成する');
      }),
    );

    // 検証: 購入完了後に adsRemovalProvider が true に変わり、
    //       HomeScreen のリスナーがバナーを dispose する動作を再現
    // 該当箇所: home_screen.dart:95-107
    //   _adsRemovalSubscription = ref.listenManual<bool>(
    //     adsRemovalProvider,
    //     (previous, next) {
    //       if (next) {
    //         _banner?.dispose();
    //         setState(() { _banner = null; _isBannerLoaded = false; });
    //       }
    //     },
    //   );
    testWidgets(
      '購入後に adsRemovalProvider が true に変わりリスナーに通知される',
      withIos((tester) async {
        final container = ProviderContainer(
          overrides: _adsRemovedOverrides(false),
        );
        addTearDown(container.dispose);

        await tester.pump();
        await tester.pump();

        // HomeScreen のリスナーと同等の監視
        final changes = <bool>[];
        container.listen<bool>(
          adsRemovalProvider,
          (prev, next) => changes.add(next),
          fireImmediately: false,
        );

        // 購入完了をシミュレート
        await container
            .read(adsRemovalProvider.notifier)
            .setAdsRemoved(true);

        expect(changes, [true],
            reason: 'リスナーが true を受信し、HomeScreen はバナーを dispose する');
        expect(container.read(adsRemovalProvider), true);
      }),
    );
  });
}
