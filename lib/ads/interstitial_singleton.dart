import 'package:flutter/foundation.dart';
import 'package:mr_collection/ads/interstitial_service.dart';

// リリースモードのみ本番IDを使用
final InterstitialService interstitial =
    InterstitialService(useProd: kReleaseMode);
