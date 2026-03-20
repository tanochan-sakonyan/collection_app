import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// in_app_purchase_android の内部ファイルを直接参照して pigeon コーデックを取得する。
// InAppPurchaseAndroidPlatform が初期化時に startConnection を呼ぶため、
// _PigeonCodec で正しくエンコードした PlatformBillingResult{ok} を返してエラーを防ぐ。
import 'package:in_app_purchase_android/src/messages.g.dart' as iap_android;
import 'package:mr_collection/provider/ads_removal_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _androidStartConnectionChannel =
    'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.startConnection';

ByteData? _encodedOkBillingResult;

ByteData? _getEncodedOkResponse() {
  _encodedOkBillingResult ??=
      iap_android.InAppPurchaseApi.pigeonChannelCodec.encodeMessage(<Object?>[
    iap_android.PlatformBillingResult(
      responseCode: iap_android.PlatformBillingResponse.ok,
      debugMessage: '',
    ),
  ]);
  return _encodedOkBillingResult;
}

void _setupAndroidIapMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
    _androidStartConnectionChannel,
    (message) async => _getEncodedOkResponse(),
  );
}

void _teardownAndroidIapMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(_androidStartConnectionChannel, null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _setupAndroidIapMock();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(_teardownAndroidIapMock);

  group('AdsRemovalNotifier - 初期状態', () {
    testWidgets('キャッシュなしの場合、初期状態は false', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(adsRemovalProvider), false);
    });

    testWidgets('ads_removed=true のキャッシュがある場合、ロード後に true になる',
        (tester) async {
      SharedPreferences.setMockInitialValues({'ads_removed': true});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // _loadFromPrefs の非同期完了を待つ
      container.read(adsRemovalProvider);
      await tester.pumpAndSettle();

      expect(container.read(adsRemovalProvider), true);
    });

    testWidgets('ads_removed=false のキャッシュがある場合、ロード後も false のまま',
        (tester) async {
      SharedPreferences.setMockInitialValues({'ads_removed': false});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(adsRemovalProvider);
      await tester.pumpAndSettle();

      expect(container.read(adsRemovalProvider), false);
    });
  });

  group('AdsRemovalNotifier - setAdsRemoved', () {
    testWidgets('setAdsRemoved(true) で state が true になる', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(adsRemovalProvider.notifier).setAdsRemoved(true);

      expect(container.read(adsRemovalProvider), true);
    });

    testWidgets('setAdsRemoved(true) で SharedPreferences に保存される',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(adsRemovalProvider.notifier).setAdsRemoved(true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('ads_removed'), true);
    });

    testWidgets('setAdsRemoved(false) で state が false になる', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(adsRemovalProvider.notifier).setAdsRemoved(false);

      expect(container.read(adsRemovalProvider), false);
    });

    testWidgets('setAdsRemoved(false) では SharedPreferences に書き込まれない',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(adsRemovalProvider.notifier).setAdsRemoved(false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('ads_removed'), isNull);
    });

    testWidgets(
        'setAdsRemoved(true) 後に新しい ProviderContainer を作成しても true が復元される',
        (tester) async {
      // 1回目: 状態を保存
      final container1 = ProviderContainer();
      await container1.read(adsRemovalProvider.notifier).setAdsRemoved(true);
      container1.dispose();

      // 2回目: 別のコンテナで _loadFromPrefs が true を読み込む
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);

      container2.read(adsRemovalProvider);
      await tester.pumpAndSettle();

      expect(container2.read(adsRemovalProvider), true);
    });
  });

  group('AdsRemovalNotifier - 状態変化のリスナー', () {
    testWidgets('setAdsRemoved(true) で登録済みリスナーに通知される', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final changes = <bool>[];
      container.listen<bool>(
        adsRemovalProvider,
        (prev, next) => changes.add(next),
        fireImmediately: false,
      );

      await container.read(adsRemovalProvider.notifier).setAdsRemoved(true);

      expect(changes, [true]);
    });

    testWidgets('キャッシュロード (ads_removed=true) でリスナーに通知される', (tester) async {
      SharedPreferences.setMockInitialValues({'ads_removed': true});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final changes = <bool>[];
      container.listen<bool>(
        adsRemovalProvider,
        (prev, next) => changes.add(next),
        fireImmediately: false,
      );

      container.read(adsRemovalProvider);
      await tester.pumpAndSettle();

      expect(changes, [true]);
    });
  });
}
