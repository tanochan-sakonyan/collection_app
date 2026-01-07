import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsAdsLogger {
  // バナー広告表示ログを送信する。
  static Future<void> logBannerAdShown() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'banner_ad_shown',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }

  // インターステイシャル広告表示ログを送信する。
  static Future<void> logInterstitialAdShown() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'interstitial_ad_shown',
      );
    } catch (error) {
      debugPrint('Analyticsログ送信に失敗しました: $error');
    }
  }
}
