// lib/ads/interstitial_service.dart
import 'dart:async';
import 'dart:developer';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mr_collection/logging/analytics_ads_logger.dart';
import 'ad_helper.dart';

class InterstitialService {
  InterstitialAd? _ad;
  final bool useProd;
  final String? adUnitIdOverride;

  InterstitialService({required this.useProd, this.adUnitIdOverride});

  bool get isReady => _ad != null;

  // 使用する広告ユニットIDを返す。
  String get _adUnitId =>
      adUnitIdOverride ??
      (useProd ? AdHelper.interstitialProdId() : AdHelper.interstitialTestId());

  Future<void> load() async {
    await InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          log('Interstitial loaded');
          _ad = ad;
        },
        onAdFailedToLoad: (err) {
          log('Interstitial load failed: $err');
          _ad = null;
        },
      ),
    );
  }

  Future<void> show() async {
    if (!isReady) {
      log('Interstitial not ready');
      return;
    }
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        log('Show failed: $err');
        ad.dispose();
        _ad = null;
        load();
      },
    );
    AnalyticsAdsLogger.logInterstitialAdShown();
    _ad!.show();
    _ad = null;
  }

  Future<void> showAndWait() async {
    if (_ad == null) return;

    final completer = Completer<void>();
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        load();
        completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _ad = null;
        load();
        completer.complete();
      },
    );
    AnalyticsAdsLogger.logInterstitialAdShown();
    _ad!.show();
    _ad = null;

    return completer.future;
  }
}
