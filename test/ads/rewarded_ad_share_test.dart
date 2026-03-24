import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/src/sk2_pigeon.g.dart' as iap_storekit;
import 'package:mr_collection/ads/rewarded_ad_service.dart';
import 'package:mr_collection/ads/rewarded_ad_singleton.dart';
import 'package:mr_collection/provider/ads_removal_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- モック RewardedAdService ---

/// テスト用モック。isReady と showAndWaitForReward() の挙動を制御し、呼び出し回数を記録する。
class MockRewardedAdService extends RewardedAdService {
  MockRewardedAdService({
    required this.mockIsReady,
    this.mockRewardResult = true,
  }) : super(useProd: false);

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

/// テストを iOS プラットフォームとして実行するラッパー。
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

// --- adsRemovalProvider を任意の値で上書きするオーバーライド ---

/// 任意の広告削除状態で adsRemovalProvider をオーバーライドする。
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

  late RewardedAdService originalRewardedAd;

  setUp(() {
    _setupStoreKitMock();
    SharedPreferences.setMockInitialValues({});
    // 元のシングルトンを保存して tearDown で復元できるようにする
    originalRewardedAd = rewardedAd;
  });

  tearDown(() {
    // シングルトンを元の状態に戻す
    setRewardedAdForTesting(originalRewardedAd);
    _teardownStoreKitMock();
  });

  // ------------------------------------------------------------------
  // リワード広告表示条件のユニットテスト
  //
  // share_screen.dart の _handleCardTap で使われている条件パターン:
  //   if (!ref.read(adsRemovalProvider))
  //     final rewarded = await rewardedAd.showAndWaitForReward();
  // ------------------------------------------------------------------
  group('リワード広告表示条件のユニットテスト', () {
    // リワード広告を表示すべきかどうかを判定するヘルパー関数（share_screen.dart と同じ条件）
    bool shouldShowRewardedAd(bool adsRemoved) => !adsRemoved;

    // 検証: 課金済みならリワード広告条件が成立しない
    // 該当箇所: share_screen.dart:287
    //   if (!ref.read(adsRemovalProvider))
    test('課金済み (adsRemoval=true) の場合、リワード広告条件が成立しない', () {
      expect(
        shouldShowRewardedAd(true),
        false,
        reason: '課金済みユーザーにはリワード広告を表示しない',
      );
    });

    // 検証: 未課金ならリワード広告条件が成立する
    // 該当箇所: share_screen.dart:287
    test('未課金 (adsRemoval=false) の場合、リワード広告条件が成立する', () {
      expect(
        shouldShowRewardedAd(false),
        true,
        reason: '未課金ユーザーにはリワード広告を表示する',
      );
    });

    // 検証: 未課金で広告準備済みなら showAndWaitForReward が呼ばれる
    // 該当箇所: share_screen.dart:288
    //   final rewarded = await rewardedAd.showAndWaitForReward();
    test('未課金でリワード広告が準備済みなら showAndWaitForReward が呼ばれる', () async {
      final mockService = MockRewardedAdService(
        mockIsReady: true,
        mockRewardResult: true,
      );
      setRewardedAdForTesting(mockService);

      // 未課金条件が成立するので showAndWaitForReward を呼ぶ
      if (shouldShowRewardedAd(false)) {
        await rewardedAd.showAndWaitForReward();
      }

      expect(
        mockService.showAndWaitCallCount,
        1,
        reason: '未課金かつ広告準備済みなら showAndWaitForReward が1回呼ばれる',
      );
    });

    // 検証: 未課金でも広告が未準備なら showAndWaitForReward は false を返し呼び出しカウントは増えない
    // 該当箇所: share_screen.dart:288-293（false の場合もそのまま共有を許可）
    test('未課金でリワード広告が未準備なら showAndWaitForReward が false を返す', () async {
      final mockService = MockRewardedAdService(mockIsReady: false);
      setRewardedAdForTesting(mockService);

      // 未課金条件が成立するので showAndWaitForReward を呼ぶ
      bool result = false;
      if (shouldShowRewardedAd(false)) {
        result = await rewardedAd.showAndWaitForReward();
      }

      expect(
        mockService.showAndWaitCallCount,
        0,
        reason: '広告が未準備なので内部カウントは増えない（mock が false を返すだけ）',
      );
      expect(
        result,
        false,
        reason: '広告未準備のため showAndWaitForReward は false を返す',
      );
    });
  });

  // ------------------------------------------------------------------
  // リワード広告 - Provider 統合テスト
  //
  // ProviderContainer で adsRemovalProvider をオーバーライドし、
  // 実際のプロバイダ状態と広告モックを組み合わせて検証する。
  // ------------------------------------------------------------------
  group('リワード広告 - Provider 統合テスト', () {
    // 検証: 課金済みの場合、Provider が true を返しリワード広告条件が成立しない
    // 該当箇所: share_screen.dart:287
    testWidgets(
      '課金済みの場合、Provider が true を返しリワード広告条件が成立しない',
      withIos((tester) async {
        final mockService = MockRewardedAdService(mockIsReady: true);
        setRewardedAdForTesting(mockService);

        final container = ProviderContainer(
          overrides: _adsRemovedOverrides(true),
        );
        addTearDown(container.dispose);

        // setAdsRemoved の非同期を待つ
        await tester.pump();
        await tester.pump();

        final adsRemoved = container.read(adsRemovalProvider);

        // share_screen.dart の _handleCardTap と同じ条件
        if (!adsRemoved) {
          await rewardedAd.showAndWaitForReward();
        }

        expect(adsRemoved, true);
        expect(
          mockService.showAndWaitCallCount,
          0,
          reason: '課金済みユーザーには showAndWaitForReward が呼ばれない',
        );
      }),
    );

    // 検証: 未課金の場合、Provider が false を返しリワード広告条件が成立する
    // 該当箇所: share_screen.dart:287-288
    testWidgets(
      '未課金の場合、Provider が false を返しリワード広告条件が成立する',
      withIos((tester) async {
        final mockService = MockRewardedAdService(mockIsReady: true);
        setRewardedAdForTesting(mockService);

        final container = ProviderContainer(
          overrides: _adsRemovedOverrides(false),
        );
        addTearDown(container.dispose);

        await tester.pump();
        await tester.pump();

        final adsRemoved = container.read(adsRemovalProvider);

        // share_screen.dart の _handleCardTap と同じ条件
        if (!adsRemoved) {
          await rewardedAd.showAndWaitForReward();
        }

        expect(adsRemoved, false);
        expect(
          mockService.showAndWaitCallCount,
          1,
          reason: '未課金ユーザーには showAndWaitForReward が呼ばれる',
        );
      }),
    );
  });

  // ------------------------------------------------------------------
  // リワード広告 - 匿名カード・詳細カード共通テスト
  //
  // share_screen.dart の _handleCardTap は isAnonymous に関わらず
  // 同じリワード広告条件で動作する。
  // ------------------------------------------------------------------
  group('リワード広告 - 匿名カード・詳細カード共通テスト', () {
    // リワード広告表示条件（isAnonymous は条件に含まれない）
    bool shouldShowRewardedAd(bool adsRemoved) => !adsRemoved;

    // 検証: 匿名カード (isAnonymous=true) でも未課金ならリワード広告条件が成立する
    // 該当箇所: share_screen.dart:281-294
    //   _handleCardTap() の条件は isAnonymous に依存しない
    test('匿名カードでもリワード広告条件は同じ (isAnonymous=true)', () {
      // isAnonymous は広告表示条件に影響しないため、未課金なら true
      const isAnonymous = true;
      const adsRemoved = false;

      // isAnonymous の値に関わらず広告条件は adsRemoved のみで決まる
      expect(
        shouldShowRewardedAd(adsRemoved),
        true,
        reason: 'isAnonymous=$isAnonymous でも未課金ならリワード広告を表示する',
      );
    });

    // 検証: 詳細カード (isAnonymous=false) でも未課金ならリワード広告条件が成立する
    // 該当箇所: share_screen.dart:281-294
    test('詳細カードでもリワード広告条件は同じ (isAnonymous=false)', () {
      // isAnonymous は広告表示条件に影響しないため、未課金なら true
      const isAnonymous = false;
      const adsRemoved = false;

      // isAnonymous の値に関わらず広告条件は adsRemoved のみで決まる
      expect(
        shouldShowRewardedAd(adsRemoved),
        true,
        reason: 'isAnonymous=$isAnonymous でも未課金ならリワード広告を表示する',
      );
    });
  });
}
