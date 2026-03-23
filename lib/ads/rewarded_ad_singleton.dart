import 'package:flutter/foundation.dart';
import 'package:mr_collection/ads/rewarded_ad_service.dart';

// リリースモードのみ本番IDを使用
RewardedAdService rewardedAd = RewardedAdService(useProd: kReleaseMode);

@visibleForTesting
// テスト用にリワード広告のシングルトンを差し替える。
void setRewardedAdForTesting(RewardedAdService service) {
  rewardedAd = service;
}
