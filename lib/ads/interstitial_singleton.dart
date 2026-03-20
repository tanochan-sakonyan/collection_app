import 'package:flutter/foundation.dart';
import 'package:mr_collection/ads/interstitial_service.dart';

// リリースモードのみ本番IDを使用
InterstitialService interstitial =
    InterstitialService(useProd: kReleaseMode);

@visibleForTesting
// テスト用にインタースティシャル広告のシングルトンを差し替える。
void setInterstitialForTesting(InterstitialService service) {
  interstitial = service;
}
