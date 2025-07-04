// lib/ads/interstitial_service.dart
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class InterstitialService {
  InterstitialAd? _interstitial;

  final bool useProd;

  InterstitialService({this.useProd = false});

  Future<void> load() async {
    await InterstitialAd.load(
      adUnitId: useProd
          ? AdHelper.interstitialProdId()
          : AdHelper.interstitialTestId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (err) {
          debugPrint('Interstitial failed: $err');
          _interstitial = null;
        },
      ),
    );
  }

  void show() {
    if (_interstitial == null) return;

    _interstitial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        load();
      },
    );

    _interstitial!.show();
    _interstitial = null;
  }
}
