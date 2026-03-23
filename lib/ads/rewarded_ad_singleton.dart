import 'package:flutter/foundation.dart';
import 'package:mr_collection/ads/ad_helper.dart';
import 'package:mr_collection/ads/rewarded_ad_service.dart';

// 共有画面用リワード広告シングルトン
RewardedAdService rewardedAd = RewardedAdService(useProd: kReleaseMode);

@visibleForTesting
// テスト用に共有画面リワード広告のシングルトンを差し替える。
void setRewardedAdForTesting(RewardedAdService service) {
  rewardedAd = service;
}

// LINEグループ追加時用リワード広告シングルトン
RewardedAdService lineGroupRewardedAd = RewardedAdService(
  useProd: kReleaseMode,
  adUnitIdOverride: kReleaseMode
      ? AdHelper.lineGroupRewardedProdId()
      : AdHelper.lineGroupRewardedTestId(),
);

@visibleForTesting
// テスト用にLINEグループ追加時リワード広告のシングルトンを差し替える。
void setLineGroupRewardedAdForTesting(RewardedAdService service) {
  lineGroupRewardedAd = service;
}

// 個別金額確定時用リワード広告シングルトン
RewardedAdService amountConfirmRewardedAd = RewardedAdService(
  useProd: kReleaseMode,
  adUnitIdOverride: kReleaseMode
      ? AdHelper.amountConfirmRewardedProdId()
      : AdHelper.amountConfirmRewardedTestId(),
);

@visibleForTesting
// テスト用に個別金額確定時リワード広告のシングルトンを差し替える。
void setAmountConfirmRewardedAdForTesting(RewardedAdService service) {
  amountConfirmRewardedAd = service;
}
