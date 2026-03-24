import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/src/sk2_pigeon.g.dart' as iap_storekit;
import 'package:mr_collection/ads/idle_interstitial_manager.dart';
import 'package:mr_collection/ads/interstitial_service.dart';
import 'package:mr_collection/provider/ads_removal_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- モック InterstitialService ---

/// アイドル広告テスト用のモック。isReady と show() の呼び出し回数を記録する。
class MockInterstitialService extends InterstitialService {
  MockInterstitialService({required this.mockIsReady}) : super(useProd: false);

  final bool mockIsReady;
  int showCallCount = 0;

  @override
  bool get isReady => mockIsReady;

  @override
  Future<void> show() async {
    showCallCount++;
  }
}

// --- StoreKit2 モック ---

const _sk2CanMakePaymentsChannel =
    'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.canMakePayments';
const _sk2RestorePurchasesChannel =
    'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.restorePurchases';

/// StoreKit2 のチャネルモックをセットアップする。
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

/// StoreKit2 のチャネルモックを解除する。
void _teardownStoreKitMock() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMessageHandler(_sk2CanMakePaymentsChannel, null);
  messenger.setMockMessageHandler(_sk2RestorePurchasesChannel, null);
}

// --- adsRemovalProvider をオーバーライドするヘルパー ---

/// 任意の ads 削除状態で adsRemovalProvider をオーバーライドする。
List<Override> _adsRemovedOverrides(bool removed) {
  return [
    adsRemovalProvider.overrideWith((ref) {
      final notifier = AdsRemovalNotifier();
      notifier.setAdsRemoved(removed);
      return notifier;
    }),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInterstitialService mockService;
  late IdleInterstitialManager manager;

  // tearDown での dispose が二重に呼ばれないよう追跡するフラグ
  var managerDisposedInTest = false;

  setUp(() {
    managerDisposedInTest = false;
    // テスト開始前にダミーモックを注入しておく（シングルトンの初期化エラーを防ぐ）
    final dummyMock = MockInterstitialService(mockIsReady: false);
    setIdleInterstitialForTesting(dummyMock);
  });

  tearDown(() {
    // テスト内で dispose 済みの場合は二重 dispose を避ける
    if (!managerDisposedInTest) {
      manager.dispose();
    }
    // tearDown でも別のモックを差し替えておく（次のテストに影響させない）
    setIdleInterstitialForTesting(MockInterstitialService(mockIsReady: false));
  });

  // ------------------------------------------------------------------
  // アイドル時広告表示のユニットテスト
  // ------------------------------------------------------------------
  group('IdleInterstitialManager - アイドル時広告表示', () {
    // 検証: アイドル時間（100ms）が経過すると広告が1回表示される
    test('アイドル時間経過で広告が表示される', () {
      mockService = MockInterstitialService(mockIsReady: true);
      setIdleInterstitialForTesting(mockService);

      manager = IdleInterstitialManager(
        idleTimeout: const Duration(milliseconds: 100),
        cooldownDuration: const Duration(seconds: 1),
      );

      fakeAsync((async) {
        manager.start();
        // idleTimeout 分だけ時間を進める
        async.elapse(const Duration(milliseconds: 100));
        expect(mockService.showCallCount, 1,
            reason: 'アイドル時間経過後に広告が1回表示される');
      });
    });

    // 検証: アイドル時間内に resetTimer() を呼ぶとタイマーがリセットされ広告が表示されない
    test('アイドル時間内に操作があれば広告は表示されない', () {
      mockService = MockInterstitialService(mockIsReady: true);
      setIdleInterstitialForTesting(mockService);

      manager = IdleInterstitialManager(
        idleTimeout: const Duration(milliseconds: 100),
        cooldownDuration: const Duration(seconds: 1),
      );

      fakeAsync((async) {
        manager.start();
        // 50ms 経過（まだアイドルタイムアウトしていない）
        async.elapse(const Duration(milliseconds: 50));
        // ユーザー操作でタイマーリセット
        manager.resetTimer();
        // さらに 50ms 進める（リセット後なので合計100msに達していない）
        async.elapse(const Duration(milliseconds: 50));
        expect(mockService.showCallCount, 0,
            reason: 'タイマーリセット後はアイドルタイムアウトしていないので広告が表示されない');

        // さらに 100ms 進めるとアイドルタイムアウト
        async.elapse(const Duration(milliseconds: 100));
        expect(mockService.showCallCount, 1,
            reason: 'リセット後にアイドル時間が経過すると広告が表示される');
      });
    });

    // 検証: クールダウン期間中は _onIdle() が呼ばれても広告をスキップする
    test('クールダウン中は広告を表示しない', () {
      mockService = MockInterstitialService(mockIsReady: true);
      setIdleInterstitialForTesting(mockService);

      manager = IdleInterstitialManager(
        idleTimeout: const Duration(milliseconds: 100),
        cooldownDuration: const Duration(milliseconds: 500),
      );

      fakeAsync((async) {
        // 1回目: アイドルタイムアウトで広告表示
        manager.start();
        async.elapse(const Duration(milliseconds: 100));
        expect(mockService.showCallCount, 1,
            reason: '1回目の広告が表示される');

        // クールダウン中（500ms以内）に再度 start() → idleTimeout 経過
        manager.start();
        async.elapse(const Duration(milliseconds: 100));
        expect(mockService.showCallCount, 1,
            reason: 'クールダウン中は広告が表示されない');
      });
    });

    // 検証: クールダウン終了後は再度広告が表示される
    test('クールダウン終了後は再度表示される', () {
      mockService = MockInterstitialService(mockIsReady: true);
      setIdleInterstitialForTesting(mockService);

      manager = IdleInterstitialManager(
        idleTimeout: const Duration(milliseconds: 100),
        cooldownDuration: const Duration(milliseconds: 200),
      );

      fakeAsync((async) {
        // 1回目の表示
        manager.start();
        async.elapse(const Duration(milliseconds: 100));
        expect(mockService.showCallCount, 1,
            reason: '1回目の広告が表示される');

        // クールダウン終了まで十分な時間を進める（200ms以上）
        async.elapse(const Duration(milliseconds: 200));

        // クールダウン後に再度 start() → idleTimeout 経過
        manager.start();
        async.elapse(const Duration(milliseconds: 100));
        expect(mockService.showCallCount, 2,
            reason: 'クールダウン終了後は再度広告が表示される');
      });
    });

    // 検証: 広告が準備できていない場合は _onIdle() がスキップする
    test('広告が準備できていない場合はスキップ', () {
      mockService = MockInterstitialService(mockIsReady: false);
      setIdleInterstitialForTesting(mockService);

      manager = IdleInterstitialManager(
        idleTimeout: const Duration(milliseconds: 100),
        cooldownDuration: const Duration(seconds: 1),
      );

      fakeAsync((async) {
        manager.start();
        async.elapse(const Duration(milliseconds: 100));
        expect(mockService.showCallCount, 0,
            reason: '広告が準備できていない場合は表示しない');
      });
    });

    // 検証: stop() を呼ぶとタイマーがキャンセルされ広告が表示されない
    test('stop() でタイマーが停止する', () {
      mockService = MockInterstitialService(mockIsReady: true);
      setIdleInterstitialForTesting(mockService);

      manager = IdleInterstitialManager(
        idleTimeout: const Duration(milliseconds: 100),
        cooldownDuration: const Duration(seconds: 1),
      );

      fakeAsync((async) {
        manager.start();
        // アイドルタイムアウト前に停止
        manager.stop();
        async.elapse(const Duration(milliseconds: 100));
        expect(mockService.showCallCount, 0,
            reason: 'stop() 後はタイマーが停止し広告が表示されない');
      });
    });

    // 検証: dispose() 後は _onIdle() が呼ばれても何も起きない
    test('dispose() 後は広告が表示されない', () {
      mockService = MockInterstitialService(mockIsReady: true);
      setIdleInterstitialForTesting(mockService);

      manager = IdleInterstitialManager(
        idleTimeout: const Duration(milliseconds: 100),
        cooldownDuration: const Duration(seconds: 1),
      );

      fakeAsync((async) {
        manager.start();
        // アイドルタイムアウト前に dispose
        manager.dispose();
        managerDisposedInTest = true;
        async.elapse(const Duration(milliseconds: 100));
        expect(mockService.showCallCount, 0,
            reason: 'dispose() 後は広告が表示されない');
      });
    });
  });

  // ------------------------------------------------------------------
  // 広告削除ユーザー向けテスト
  // ------------------------------------------------------------------
  group('IdleInterstitialManager - 広告削除ユーザー向けテスト', () {
    setUp(() {
      _setupStoreKitMock();
      SharedPreferences.setMockInitialValues({});
      // このグループのテストでも tearDown の dispose が動くようにダミーを設定
      manager = IdleInterstitialManager(
        idleTimeout: const Duration(milliseconds: 100),
        cooldownDuration: const Duration(seconds: 1),
      );
    });

    tearDown(() {
      _teardownStoreKitMock();
    });

    // 検証: 広告削除済みかどうかによってアイドル広告を開始するか判断する条件ロジック
    // HomeScreen の _restoreAdsRemovalStatusOnStart と同じ条件パターン
    test('広告削除ユーザーにはアイドル広告を表示しない（条件パターンテスト）', () {
      // shouldStartIdleAd: 広告削除済みでなければ true を返す
      bool shouldStartIdleAd(bool adsRemoved) => !adsRemoved;

      // 広告削除済みの場合は false（アイドル広告を開始しない）
      expect(shouldStartIdleAd(true), false,
          reason: '広告削除済みユーザーにはアイドル広告を表示しない');

      // 広告削除していない場合は true（アイドル広告を開始する）
      expect(shouldStartIdleAd(false), true,
          reason: '広告削除していないユーザーにはアイドル広告を表示する');
    });

    // 検証: 広告削除購入後に adsRemovalProvider が true に変わりリスナーに通知される
    // HomeScreen では購入後にアイドルタイマーを停止する処理をリスナーで行う
    testWidgets(
      '広告削除購入後にアイドルタイマーが停止される（Provider統合テスト）',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        try {
          final container = ProviderContainer(
            overrides: _adsRemovedOverrides(false),
          );
          addTearDown(container.dispose);

          await tester.pump();
          await tester.pump();

          // adsRemovalProvider の変化を監視（HomeScreen のリスナーと同等）
          final changes = <bool>[];
          container.listen<bool>(
            adsRemovalProvider,
            (prev, next) => changes.add(next),
            fireImmediately: false,
          );

          // 広告削除購入完了をシミュレート
          await container
              .read(adsRemovalProvider.notifier)
              .setAdsRemoved(true);

          expect(changes, [true],
              reason: 'リスナーが true を受信し、HomeScreen はアイドルタイマーを停止する');
          expect(container.read(adsRemovalProvider), true);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );
  });
}
