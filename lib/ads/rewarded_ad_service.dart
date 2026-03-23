import 'dart:async';
import 'dart:developer';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mr_collection/ads/ad_helper.dart';
import 'package:mr_collection/logging/analytics_ads_logger.dart';

/// リワード広告のライフサイクルを管理するサービス。
class RewardedAdService {
  RewardedAd? _ad;
  final bool useProd;

  RewardedAdService({required this.useProd});

  bool get isReady => _ad != null;

  /// リワード広告をロードする。
  Future<void> load() async {
    await RewardedAd.load(
      adUnitId: useProd ? AdHelper.rewardedProdId() : AdHelper.rewardedTestId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          log('Rewarded ad loaded');
          _ad = ad;
        },
        onAdFailedToLoad: (err) {
          log('Rewarded ad load failed: $err');
          _ad = null;
        },
      ),
    );
  }

  /// リワード広告を表示し、ユーザーがリワードを獲得するまで待つ。
  /// リワード獲得で true、それ以外（広告未準備・失敗）で false を返す。
  Future<bool> showAndWaitForReward() async {
    if (_ad == null) return false;

    final completer = Completer<bool>();
    bool rewarded = false;

    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        load(); // 次の広告をプリロード
        if (!completer.isCompleted) {
          completer.complete(rewarded);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        log('Rewarded ad show failed: $err');
        ad.dispose();
        _ad = null;
        load();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    AnalyticsAdsLogger.logRewardedAdShown();
    _ad!.show(onUserEarnedReward: (ad, reward) {
      rewarded = true;
    });
    _ad = null;

    return completer.future;
  }
}
