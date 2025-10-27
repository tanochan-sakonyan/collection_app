// lib/ads/interstitial_service.dart
import 'dart:async';
import 'dart:developer';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class InterstitialService {
  InterstitialAd? _ad;
  final bool useProd;

  InterstitialService({required this.useProd});

  bool get isReady => _ad != null;

  Future<void> load() async {
    await InterstitialAd.load(
      adUnitId: useProd
          ? AdHelper.interstitialProdId()
          : AdHelper.interstitialTestId(),
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
    _ad!.show();
    _ad = null;

    return completer.future;
  }
}
