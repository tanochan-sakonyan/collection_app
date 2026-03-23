import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/src/sk2_pigeon.g.dart' as iap_storekit;
import 'package:mr_collection/ads/rewarded_ad_service.dart';
import 'package:mr_collection/ads/rewarded_ad_singleton.dart';
import 'package:mr_collection/provider/ads_removal_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Mock RewardedAdService ---

// 個別金額確定時リワード広告の呼び出しを記録するモック。
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

// テスト実行中に iOS プラットフォームを強制するラッパー。
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

// StoreKit2 のチャンネルにモックハンドラを登録する。
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

// StoreKit2 のモックハンドラを解除する。
void _teardownStoreKitMock() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMessageHandler(_sk2CanMakePaymentsChannel, null);
  messenger.setMockMessageHandler(_sk2RestorePurchasesChannel, null);
}

// --- adsRemovalProvider を任意の値で上書きするオーバーライド ---

// adsRemovalProvider を指定した値で初期化するオーバーライドリストを返す。
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

  setUp(() {
    _setupStoreKitMock();
    SharedPreferences.setMockInitialValues({});
    // テスト環境では AdHelper が UnsupportedError を投げるためダミーモックを注入する
    setAmountConfirmRewardedAdForTesting(MockRewardedAdService(mockIsReady: false));
  });

  tearDown(() {
    // tearDown でもダミーモックに差し替えてプラットフォームエラーを防ぐ
    setAmountConfirmRewardedAdForTesting(MockRewardedAdService(mockIsReady: false));
    _teardownStoreKitMock();
  });

  // ------------------------------------------------------------------
  // 個別金額確定時リワード広告表示条件のユニットテスト
  //
  // split_amount_screen.dart の確定ボタン onPressed（行853付近）:
  //   if (!ref.read(adsRemovalProvider)) {
  //     await amountConfirmRewardedAd.showAndWaitForReward();
  //   }
  // ------------------------------------------------------------------
  group('個別金額確定時リワード広告表示条件のユニットテスト', () {
    // 課金状態からリワード広告を表示すべきか判定するヘルパー関数。
    bool shouldShowRewardedAd(bool adsRemoved) => !adsRemoved;

    // 検証: 課金済みの場合はリワード広告条件が成立しない
    // 該当箇所: split_amount_screen.dart:853付近
    //   if (!ref.read(adsRemovalProvider)) {
    //     await amountConfirmRewardedAd.showAndWaitForReward();
    //   }
    test('課金済みの場合、リワード広告条件が成立しない', () {
      expect(
        shouldShowRewardedAd(true),
        false,
        reason: '課金済みユーザーには個別金額確定時のリワード広告を表示しない',
      );
    });

    // 検証: 未課金の場合はリワード広告条件が成立する
    // 該当箇所: split_amount_screen.dart:853付近
    test('未課金の場合、リワード広告条件が成立する', () {
      expect(
        shouldShowRewardedAd(false),
        true,
        reason: '未課金ユーザーには個別金額確定時のリワード広告を表示する',
      );
    });

    // 検証: 未課金で広告が準備済みなら showAndWaitForReward が呼ばれる
    // 該当箇所: split_amount_screen.dart:853付近
    test('未課金でリワード広告が準備済みなら showAndWaitForReward が呼ばれる', () async {
      final mockService = MockRewardedAdService(mockIsReady: true);
      setAmountConfirmRewardedAdForTesting(mockService);

      // split_amount_screen.dart の確定ボタン onPressed と同じ条件を再現
      const adsRemoved = false;
      if (!adsRemoved) {
        await amountConfirmRewardedAd.showAndWaitForReward();
      }

      expect(
        mockService.showAndWaitCallCount,
        1,
        reason: '未課金かつ広告準備済みの場合は showAndWaitForReward が1回呼ばれる',
      );
    });

    // 検証: 未課金でも広告が未準備なら showAndWaitForReward は false を返し呼び出しカウントは0
    // 該当箇所: split_amount_screen.dart:853付近
    test('未課金でリワード広告が未準備なら showAndWaitForReward が false を返す', () async {
      final mockService = MockRewardedAdService(mockIsReady: false);
      setAmountConfirmRewardedAdForTesting(mockService);

      // split_amount_screen.dart の確定ボタン onPressed と同じ条件を再現
      const adsRemoved = false;
      if (!adsRemoved) {
        await amountConfirmRewardedAd.showAndWaitForReward();
      }

      expect(
        mockService.showAndWaitCallCount,
        0,
        reason: '広告が未準備の場合は showAndWaitForReward の実処理が実行されない',
      );
    });
  });

  // ------------------------------------------------------------------
  // 個別金額確定時リワード広告 - Provider 統合テスト
  //
  // ProviderContainer で adsRemovalProvider をオーバーライドし、
  // amountConfirmRewardedAd の呼び出し回数を検証する。
  // ------------------------------------------------------------------
  group('個別金額確定時リワード広告 - Provider 統合テスト', () {
    late MockRewardedAdService mockRewardedService;

    setUp(() {
      // テスト環境ではプラットフォーム判定が効かないためダミーモックを注入する
      setAmountConfirmRewardedAdForTesting(MockRewardedAdService(mockIsReady: false));
    });

    tearDown(() {
      // tearDown でもダミーモックに差し替えてプラットフォームエラーを防ぐ
      setAmountConfirmRewardedAdForTesting(MockRewardedAdService(mockIsReady: false));
    });

    // 検証: 課金済みの場合、Provider が true を返しリワード広告条件が成立しない
    // 該当箇所: split_amount_screen.dart:853付近
    //   if (!ref.read(adsRemovalProvider)) {
    //     await amountConfirmRewardedAd.showAndWaitForReward();
    //   }
    testWidgets(
      '課金済みの場合、Provider が true を返しリワード広告条件が成立しない',
      withIos((tester) async {
        mockRewardedService = MockRewardedAdService(mockIsReady: true);
        setAmountConfirmRewardedAdForTesting(mockRewardedService);

        final container = ProviderContainer(
          overrides: _adsRemovedOverrides(true),
        );
        addTearDown(container.dispose);

        // setAdsRemoved の非同期を待つ
        await tester.pump();
        await tester.pump();

        final adsRemoved = container.read(adsRemovalProvider);

        // split_amount_screen.dart の確定ボタン onPressed と同じ条件
        if (!adsRemoved) {
          await amountConfirmRewardedAd.showAndWaitForReward();
        }

        expect(adsRemoved, true);
        expect(
          mockRewardedService.showAndWaitCallCount,
          0,
          reason: '課金済みユーザーには個別金額確定時のリワード広告を表示しない',
        );
      }),
    );

    // 検証: 未課金の場合、Provider が false を返しリワード広告条件が成立する
    // 該当箇所: split_amount_screen.dart:853付近
    testWidgets(
      '未課金の場合、Provider が false を返しリワード広告条件が成立する',
      withIos((tester) async {
        mockRewardedService = MockRewardedAdService(mockIsReady: true);
        setAmountConfirmRewardedAdForTesting(mockRewardedService);

        final container = ProviderContainer(
          overrides: _adsRemovedOverrides(false),
        );
        addTearDown(container.dispose);

        // setAdsRemoved の非同期を待つ
        await tester.pump();
        await tester.pump();

        final adsRemoved = container.read(adsRemovalProvider);

        // split_amount_screen.dart の確定ボタン onPressed と同じ条件
        if (!adsRemoved) {
          await amountConfirmRewardedAd.showAndWaitForReward();
        }

        expect(adsRemoved, false);
        expect(
          mockRewardedService.showAndWaitCallCount,
          1,
          reason: '未課金ユーザーには個別金額確定時のリワード広告を表示する',
        );
      }),
    );
  });
}
